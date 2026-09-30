# Food Tracker

Mobile-first React PWA for recording meals, manually grouping any three meals into a ₹200 tally, and tracking monthly bills and payments.

## Run locally

1. Create a Supabase project.
2. In Supabase SQL Editor, run `supabase/migrations/001_food_tracker.sql`.
3. Copy `.env.example` to `.env.local` and set:

   ```text
   VITE_SUPABASE_URL=https://your-project.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key
   ```

4. Run `npm install` then `npm run dev`.

## Verify and deploy

Run `npm test`, `npm run lint`, and `npm run build`.

For Vercel, import this repository, set the two `VITE_SUPABASE_*` environment variables, and deploy. `vercel.json` supplies the SPA rewrite. The app includes a web manifest and offline app-shell service worker; install it from the browser menu on Android or iOS.

## Billing rules

Meals retain a `price_snapshot`, so future price changes do not alter history. Finalized tally groups contain exactly three selected meals and prevent direct edits until explicitly reopened. Untallied breakfast, lunch, and dinner on the same date are treated as one full-day price. A cross-month tally is apportioned between each month by its number of meals in that month, so the combined monthly total always equals the finalized tally value.
