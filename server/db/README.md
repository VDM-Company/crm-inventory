# Database layer (Drizzle + PostgreSQL)

Schema, migrations, and seed scripts for the CRM-Inventory database.
The API endpoints in `server/api/` still serve mock data; wiring them to
this database is a separate, future piece of work.

## One-time setup

1. Install Docker (Docker Desktop, OrbStack, or colima).
2. `cp .env.example .env` (adjust `DATABASE_URL` if needed).
3. Start Postgres: `docker compose up -d db`
4. Apply migrations: `pnpm db:migrate`
5. Seed sample data: `pnpm db:seed`
6. Check everything: `pnpm db:verify`

## Scripts

| Command | What it does |
| --- | --- |
| `pnpm db:generate` | Generate a new SQL migration from schema changes |
| `pnpm db:migrate` | Apply pending migrations |
| `pnpm db:seed` | Truncate all tables and insert sample data (re-runnable) |
| `pnpm db:verify` | Assert seeded data and constraints are intact |

## Layout

- `schema/` — Drizzle table definitions, split by domain
- `migrations/` — generated SQL (do not edit by hand)
- `seed.ts` / `verify.ts` — sample data + assertions

Design spec: `docs/superpowers/specs/2026-07-09-project-overview-database-schema-design.md`
