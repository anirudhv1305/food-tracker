-- Deletes a tally only after returning its meals to the untallied pool.
-- Meal records are retained, so consumption history and billing stay auditable.
create or replace function public.delete_tally(group_id uuid)
returns void
language plpgsql
security invoker
as $$
begin
  if not exists (select 1 from public.tally_groups where id = group_id and user_id = auth.uid()) then
    raise exception 'Tally group not found';
  end if;

  update public.meals
  set tally_group_id = null, status = 'untallied', updated_at = now()
  where tally_group_id = group_id and user_id = auth.uid();

  delete from public.tally_groups where id = group_id and user_id = auth.uid();
end;
$$;

-- The existing UI action is retained for compatibility and now uses the
-- deletion workflow; meals are restored before the group is removed.
create or replace function public.reopen_tally(group_id uuid)
returns void
language plpgsql
security invoker
as $$
begin
  perform public.delete_tally(group_id);
end;
$$;
