-- Automatically finalize a full-day tally whenever all three meal types exist
-- for one calendar date. Cross-date tallies remain a manual user action.
create or replace function public.auto_tally_full_day()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  completed_meal_ids uuid[];
  tally_price numeric(10,2);
  new_group_id uuid;
begin
  select array_agg(id order by meal_type)
  into completed_meal_ids
  from meals
  where user_id = new.user_id
    and meal_date = new.meal_date
    and tally_group_id is null
    and status = 'untallied';

  if coalesce(array_length(completed_meal_ids, 1), 0) <> 3 then
    return new;
  end if;

  select full_day_price
  into tally_price
  from meal_prices
  where user_id = new.user_id and effective_from <= new.meal_date
  order by effective_from desc, created_at desc
  limit 1;

  insert into tally_groups (user_id, amount, meal_count, status)
  values (new.user_id, coalesce(tally_price, 200), 3, 'active')
  returning id into new_group_id;

  update meals
  set tally_group_id = new_group_id, status = 'tallied', updated_at = now()
  where id = any(completed_meal_ids);

  return new;
end;
$$;

drop trigger if exists meals_auto_tally_full_day on public.meals;
create trigger meals_auto_tally_full_day
after insert on public.meals
for each row execute procedure public.auto_tally_full_day();

-- One-time backfill: automatically tally existing complete, untallied days.
do $$
declare
  day_record record;
  tally_price numeric(10,2);
  new_group_id uuid;
begin
  for day_record in
    select user_id, meal_date, array_agg(id order by meal_type) as meal_ids
    from meals
    where tally_group_id is null and status = 'untallied'
    group by user_id, meal_date
    having count(*) = 3
  loop
    select full_day_price into tally_price
    from meal_prices
    where user_id = day_record.user_id and effective_from <= day_record.meal_date
    order by effective_from desc, created_at desc
    limit 1;

    insert into tally_groups (user_id, amount, meal_count, status)
    values (day_record.user_id, coalesce(tally_price, 200), 3, 'active')
    returning id into new_group_id;

    update meals
    set tally_group_id = new_group_id, status = 'tallied', updated_at = now()
    where id = any(day_record.meal_ids);
  end loop;
end;
$$;
