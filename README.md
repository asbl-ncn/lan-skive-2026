# LAN hos Larsen i Skive

Fælles side til LAN torsdag 12. til søndag 15. november 2026.

**Siden:** https://asbl-ncn.github.io/lan-skive-2026/

Her kan man se pakkelisten, skrive sig på en soveplads, tage en aften i madplanen og stemme på aktiviteter. Der er intet login: alle med linket kan læse og skrive.

## Filer

- `index.html`: hele siden. Den er statisk og hostes på GitHub Pages fra `main`.
- `supabase-skema.sql`: tabeller, adgangsregler og startdata til databasen bag siden.

## Database

Kokke, sovepladser, idéer og stemmer gemmes i et Supabase-projekt på gratisplanen.

Skal databasen genskabes:

1. Opret et nyt Supabase-projekt.
2. Kør `supabase-skema.sql` i SQL Editor.
3. Ret `SB_URL` og `SB_KEY` øverst i scriptet i `index.html` til det nye projekts URL og publishable key.

Gratisprojekter sættes på pause efter cirka en uges inaktivitet. Klik **Restore** i Supabase-dashboardet for at starte det igen.
