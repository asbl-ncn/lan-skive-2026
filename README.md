# LAN hos Larsen i Skive

Fælles side til LAN torsdag 12. til søndag 15. november 2026.

**Siden:** https://asbl-ncn.github.io/lan-skive-2026/

Her kan man se pakkelisten, skrive sig på en soveplads, tage en aften i madplanen og stemme på aktiviteter. Der er intet login: alle med linket kan læse og skrive.

## Filer

- `index.html`: hele siden. Den er statisk og hostes på GitHub Pages fra `main`.
- `supabase-skema.sql`: tabeller, adgangsregler og startdata til databasen bag siden.
- `supabase-admin.sql`: adminkode, så værten kan fjerne idéer fra siden.

## Admin

Værten kan fjerne idéer under Aktiviteter:

1. Kør `supabase-admin.sql` i SQL Editor. Skift `SKRIV-DIN-KODE-HER` til din egen kode, men kun i SQL Editor og ikke i filen her.
2. Klik **🔑 Vært? Lås admin op** nederst på siden og skriv koden.
3. Hver idé får nu en 🗑️. Tryk én gang og derefter på "Fjern?" for at bekræfte.

Koden gemmes som bcrypt-hash i databasen og kun i din egen browser. Klik **Lås igen** for at slå admin fra på enheden.

## Database

Kokke, sovepladser, idéer og stemmer gemmes i et Supabase-projekt på gratisplanen.

Skal databasen genskabes:

1. Opret et nyt Supabase-projekt.
2. Kør `supabase-skema.sql` i SQL Editor.
3. Ret `SB_URL` og `SB_KEY` øverst i scriptet i `index.html` til det nye projekts URL og publishable key.

Gratisprojekter sættes på pause efter cirka en uges inaktivitet. Klik **Restore** i Supabase-dashboardet for at starte det igen.
