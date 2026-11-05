-- LAN hos Larsen i Skive 2026: adminkode, så værten kan fjerne idéer fra siden.
--
-- Sådan bruges filen:
--   1. Kopiér hele filen ind i SQL Editor i Supabase.
--   2. Skift SKRIV-DIN-KODE-HER (én linje længere nede) til din egen adminkode, mindst 8 tegn.
--      Ret det kun i SQL Editor, ikke i denne fil, så koden ikke havner i repoet.
--   3. Klik Run. Filen kan køres igen senere, hvis du vil skifte koden.
--
-- Koden gemmes kun som bcrypt-hash i et skema, som siden ikke kan læse.
-- Siden kalder to funktioner: admin_check (er koden rigtig?) og admin_delete_idea.

create extension if not exists pgcrypto with schema extensions;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists private.admin_secret (
  id boolean primary key default true check (id),
  code_hash text not null
);
revoke all on private.admin_secret from public, anon, authenticated;

do $$
declare
  kode text := 'SKRIV-DIN-KODE-HER';
begin
  if kode = 'SKRIV-DIN-KODE-HER' or length(kode) < 8 then
    raise exception 'Skift SKRIV-DIN-KODE-HER til din egen adminkode (mindst 8 tegn), før du kører filen.';
  end if;
  insert into private.admin_secret (id, code_hash)
  values (true, extensions.crypt(kode, extensions.gen_salt('bf')))
  on conflict (id) do update set code_hash = excluded.code_hash;
end $$;

-- Er koden rigtig? Forkerte forsøg tager et sekund, så gætteri går langsomt.
create or replace function public.admin_check(code text)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  ok boolean;
begin
  select exists (
    select 1 from private.admin_secret s
    where s.code_hash = extensions.crypt(coalesce(code, ''), s.code_hash)
  ) into ok;
  if not ok then
    perform pg_sleep(1);
  end if;
  return ok;
end;
$$;

-- Fjern en idé. Stemmerne på idéen forsvinder med den (on delete cascade).
create or replace function public.admin_delete_idea(code text, target bigint)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.admin_check(code) then
    raise exception 'Forkert adminkode' using errcode = '42501';
  end if;
  delete from public.ideas where id = target;
  return found;
end;
$$;

revoke all on function public.admin_check(text) from public;
revoke all on function public.admin_delete_idea(text, bigint) from public;
grant execute on function public.admin_check(text) to anon;
grant execute on function public.admin_delete_idea(text, bigint) to anon;

notify pgrst, 'reload schema';
