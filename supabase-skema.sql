-- LAN hos Larsen i Skive 2026: tabeller, adgangsregler og startdata.
-- Kopieret 1:1 fra migreringen lan_signup_schema i det gamle projekt (xynzvctgnrvhavsapoxn).
-- Kør hele filen én gang i SQL Editor i det nye projekt.

-- Tabeller
create table public.cook_slots (
  id text primary key,
  sort int not null,
  day_label text not null,
  cook_name text check (cook_name is null or char_length(cook_name) between 1 and 40),
  dish text check (dish is null or char_length(dish) <= 120),
  updated_at timestamptz not null default now()
);

create table public.sleep_spots (
  id text primary key,
  sort int not null,
  spot text not null,
  person_name text check (person_name is null or char_length(person_name) between 1 and 40),
  updated_at timestamptz not null default now()
);

create table public.ideas (
  id bigint generated always as identity primary key,
  category text not null check (category in ('Gaming','Andre aktiviteter','Udenfor','Ud af huset')),
  title text not null check (char_length(title) between 2 and 140),
  url text,
  added_by text check (added_by is null or char_length(added_by) <= 40),
  created_at timestamptz not null default now()
);

create table public.idea_votes (
  idea_id bigint not null references public.ideas(id) on delete cascade,
  voter text not null check (char_length(voter) between 1 and 40),
  created_at timestamptz not null default now(),
  primary key (idea_id, voter)
);

-- updated_at sættes automatisk
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger cook_slots_touch before update on public.cook_slots
  for each row execute function public.touch_updated_at();
create trigger sleep_spots_touch before update on public.sleep_spots
  for each row execute function public.touch_updated_at();

-- RLS
alter table public.cook_slots enable row level security;
alter table public.sleep_spots enable row level security;
alter table public.ideas enable row level security;
alter table public.idea_votes enable row level security;

-- Rettigheder: kun det siden skal bruge
revoke all on public.cook_slots, public.sleep_spots, public.ideas, public.idea_votes from anon, authenticated;
grant select on public.cook_slots, public.sleep_spots, public.ideas, public.idea_votes to anon;
grant update (cook_name, dish) on public.cook_slots to anon;
grant update (person_name) on public.sleep_spots to anon;
grant insert (category, title, added_by) on public.ideas to anon;
grant insert (idea_id, voter) on public.idea_votes to anon;
grant delete on public.idea_votes to anon;

-- Politikker (alle med linket må læse og skrive i de felter, de har adgang til)
create policy "Alle kan se kokke" on public.cook_slots for select to anon using (true);
create policy "Alle kan tage en aften" on public.cook_slots for update to anon using (true) with check (true);

create policy "Alle kan se sovepladser" on public.sleep_spots for select to anon using (true);
create policy "Alle kan skrive navn paa soveplads" on public.sleep_spots for update to anon using (true) with check (true);

create policy "Alle kan se ideer" on public.ideas for select to anon using (true);
create policy "Alle kan foreslaa ideer" on public.ideas for insert to anon with check (url is null);

create policy "Alle kan se stemmer" on public.idea_votes for select to anon using (true);
create policy "Alle kan stemme" on public.idea_votes for insert to anon with check (true);
create policy "Alle kan fjerne stemme" on public.idea_votes for delete to anon using (true);

-- Startdata
insert into public.cook_slots (id, sort, day_label, dish) values
  ('tor', 1, 'Torsdag aften', null),
  ('fre', 2, 'Fredag aften', null),
  ('lor', 3, 'Lørdag aften', 'Festmåltid, fx bøffer med tilbehør');

insert into public.sleep_spots (id, sort, spot) values
  ('sofa', 1, 'Sofa'),
  ('madras', 2, 'Madras (har vi)'),
  ('egen1', 3, 'Egen madras'),
  ('egen2', 4, 'Egen madras');

insert into public.ideas (category, title, url) values
  ('Gaming', 'Keys (push?)', null),
  ('Gaming', 'Rolle-byt: lave keys, hvor alle spiller en rolle, de normalt ikke spiller', null),
  ('Gaming', 'Achievement runs', null),
  ('Gaming', 'Turneringer: Fall Guys, Golf With Your Friends, Chained Together', null),
  ('Gaming', 'Nye spil: Jackbox Party Pack, R.E.P.O., PEAK', null),
  ('Andre aktiviteter', 'Brætspil og kortspil', null),
  ('Andre aktiviteter', 'Film', null),
  ('Andre aktiviteter', 'Julebryg-blindsmagning: hver tager to forskellige julebryg med', null),
  ('Udenfor', 'Fælles gåtur', null),
  ('Udenfor', 'Bålhygge', null),
  ('Ud af huset', 'Bowling i Bowl''n''Fun Skive', 'https://bowlnfun.dk/centre/skive/'),
  ('Ud af huset', 'Padel i Padelhall.dk Skive', 'https://www.padelhall.dk/');
