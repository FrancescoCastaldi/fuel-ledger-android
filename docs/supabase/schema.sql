-- Fuel Ledger cloud schema for Supabase. Run it once in the SQL editor of your project.
--
-- Every record is identified by the uuid the app generates, so any phone can create records without coordinating ids.
-- `updated_at` is the time of the last change in epoch milliseconds, taken from the phone's clock. A deletion is not a
-- DELETE: it sets `deleted_at` (and `updated_at`) so the other phones learn about it on their next sync.
-- Data columns are nullable only so that a deletion can be written without them; live rows must be complete.

create table if not exists public.vehicles (
  uuid        uuid primary key,
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name        text,
  plate       text,
  fuel_type   text,
  initial_km  integer,
  odometer_spot text,
  range_spot    text,
  updated_at  bigint not null,
  deleted_at  bigint,
  constraint vehicles_complete check (
    deleted_at is not null
    or (name is not null and plate is not null and fuel_type is not null and initial_km is not null)
  )
);

-- Upgrading from 0.6: run these two lines once, before installing 0.7. Sync fails on unknown columns until they exist.
-- The columns are nullable, so rows written by 0.6 phones stay valid.
alter table public.vehicles add column if not exists odometer_spot text;
alter table public.vehicles add column if not exists range_spot text;

create table if not exists public.refuels (
  uuid             uuid primary key,
  user_id          uuid not null default auth.uid() references auth.users (id) on delete cascade,
  vehicle_uuid     uuid,
  date             date,
  odometer_km      integer,
  liters           double precision,
  price_per_liter  double precision,
  total_cost       double precision,
  is_full          boolean,
  note             text,
  range_before_km  integer,
  updated_at       bigint not null,
  deleted_at       bigint,
  constraint refuels_complete check (
    deleted_at is not null
    or (vehicle_uuid is not null and date is not null and odometer_km is not null and liters is not null
        and price_per_liter is not null and total_cost is not null and is_full is not null)
  )
);

create table if not exists public.expenses (
  uuid          uuid primary key,
  user_id       uuid not null default auth.uid() references auth.users (id) on delete cascade,
  vehicle_uuid  uuid,
  date          date,
  category      text,
  amount        double precision,
  odometer_km   integer,
  note          text,
  updated_at    bigint not null,
  deleted_at    bigint,
  constraint expenses_complete check (
    deleted_at is not null
    or (vehicle_uuid is not null and date is not null and category is not null and amount is not null)
  )
);

create table if not exists public.deadlines (
  uuid                  uuid primary key,
  user_id               uuid not null default auth.uid() references auth.users (id) on delete cascade,
  vehicle_uuid          uuid,
  type                  text,
  due_date              date,
  km_threshold          integer,
  km_interval           integer,
  notice_days           integer,
  renews_automatically  boolean,
  note                  text,
  updated_at            bigint not null,
  deleted_at            bigint,
  constraint deadlines_complete check (
    deleted_at is not null
    or (vehicle_uuid is not null and type is not null and due_date is not null
        and notice_days is not null and renews_automatically is not null)
  )
);

create index if not exists refuels_vehicle_idx   on public.refuels (vehicle_uuid);
create index if not exists expenses_vehicle_idx  on public.expenses (vehicle_uuid);
create index if not exists deadlines_vehicle_idx on public.deadlines (vehicle_uuid);

-- A write that is older than the stored row is dropped, so a phone that syncs late cannot undo a newer change.
-- The owner of a row can never change.
create or replace function public.fuel_ledger_keep_newest() returns trigger
language plpgsql as $$
begin
  if new.updated_at < old.updated_at then
    return null;
  end if;
  new.user_id := old.user_id;
  return new;
end;
$$;

create trigger vehicles_keep_newest   before update on public.vehicles   for each row execute function public.fuel_ledger_keep_newest();
create trigger refuels_keep_newest    before update on public.refuels    for each row execute function public.fuel_ledger_keep_newest();
create trigger expenses_keep_newest   before update on public.expenses   for each row execute function public.fuel_ledger_keep_newest();
create trigger deadlines_keep_newest  before update on public.deadlines  for each row execute function public.fuel_ledger_keep_newest();

-- Each signed-in user sees and changes only their own rows. The anon key alone gives access to nothing.
alter table public.vehicles  enable row level security;
alter table public.refuels   enable row level security;
alter table public.expenses  enable row level security;
alter table public.deadlines enable row level security;

create policy "own rows" on public.vehicles  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own rows" on public.refuels   for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own rows" on public.expenses  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "own rows" on public.deadlines for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
