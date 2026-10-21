# Cloud sync with Supabase

Fuel Ledger works fully offline. Optionally it can sync with a Supabase project that you own, so the same records follow you across phones and survive a reinstall. Nothing is sent until you sign in and tap **Sync now**, and there is no background sync.

## Set it up

1. **Create the project.** In Supabase, create a project (an EU region is a sensible choice). The free plan is enough for a logbook; Pro adds daily backups and keeps the project from pausing after a week without activity.
2. **Create the tables.** Open **SQL Editor**, paste the contents of [`supabase/schema.sql`](supabase/schema.sql) and run it. It creates four tables with row level security, so each signed-in user sees only their own rows.
3. **Create a Google sign-in.** In Google Cloud Console, create a project, configure the OAuth consent screen (External, add your own Google account as a test user), then **Credentials > Create credentials > OAuth client ID > Web application**. Under *Authorized redirect URIs* add `https://<your-project-ref>.supabase.co/auth/v1/callback`. Copy the client ID and secret.
4. **Enable Google in Supabase.** **Authentication > Sign In / Providers > Google**: enable it and paste the client ID and secret.
5. **Allow the app's return link.** **Authentication > URL Configuration > Redirect URLs**: add `com.fcastaldi.fuelledger://auth-callback`.
6. **Give the app the project.** Create `supabase.properties` in the repository root (it is ignored by Git):

   ```properties
   url=https://<your-project-ref>.supabase.co
   anonKey=<the anon public key from Project Settings > API>
   ```

   Use the `anon` key only. Never put the `service_role` key in the app or in this file.
7. **Rebuild** with `build_apk.bat` and install the APK.
8. **Sign in and sync.** In the app, **Settings > Cloud sync > Sign in with Google**, then **Migrate and sync**. The first sync uploads everything saved on the phone.
9. **Close the door.** After your first sign-in, turn off **Allow new users to sign up** under Authentication > Sign In / Providers. Otherwise any Google account could create a user in your project (it would see none of your data, but it would use your quota).

## How the sync works

- Every record has a UUID that identifies it on every phone. The numeric ids stay local.
- A sync reads the whole cloud, merges it into the phone, then uploads what the cloud lacks or holds in an older version. Nothing is remembered between syncs, so a sync that is interrupted or repeated is harmless.
- When the same record changed in both places, the newest change wins, judged by the phone's clock. A deletion counts as a change made when it happened, so editing a record after another phone deleted it brings it back.
- Deleted records stay in the cloud marked as deleted, so the other phones learn about the deletion.
- **Restore on a new phone:** install the app, sign in and tap **Sync now**. The phone is empty, so everything comes down.
- **Two phones with the same data entered separately** (not through sync) end up with both copies, because there is no way to tell they were the same fill-up. Sync one phone first, then install and sync the other.
- A CSV import replaces the phone's records with new ones. The next sync removes the replaced records from the cloud and uploads the imported ones.
- Phones with clocks far off can make their edits win or lose unfairly. Keep automatic time on.

## Privacy

Records (vehicle names and plates, odometer readings, fuel and costs, reminders) are stored in your Supabase project, in the region you chose, under your control. The app sends them only when you tap Sync now. The sign-in session is kept in the app's private storage and is removed when you sign out. Signing out does not delete data on the phone or in the cloud; to remove the cloud copy, delete the rows or the project in Supabase.
