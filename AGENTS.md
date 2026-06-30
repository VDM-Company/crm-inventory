# Project Context — Tech Stack Overview

CRM / Inventory dashboard built on the official **Nuxt UI Dashboard** template. It is a
full-stack Nuxt 4 single-page app with a Nitro server backend (currently serving mock data).

## Core Framework

| Concern | Choice | Version | Notes |
| --- | --- | --- | --- |
| Meta-framework | [Nuxt](https://nuxt.com) | `^4.4.8` | App in `app/`, server in `server/` |
| UI framework | [Vue](https://vuejs.org) | `^3.5.38` | Composition API, `<script setup>` |
| Language | TypeScript | `^6.0.3` | Strict, type-checked via `vue-tsc` |
| Package manager | pnpm | `11.8.0` | Pinned via `packageManager` field |
| Node | Node.js | `22` | Per CI matrix |

## UI & Styling

- **[@nuxt/ui](https://ui.nuxt.com) `^4.9.0`** — primary component library. App-shell
  components (`UDashboardPanel`, `UDashboardNavbar`, `UDashboardSidebar`, etc.), forms,
  tables, modals, toasts, command palette. Components are auto-imported (`U*` prefix).
- **[Tailwind CSS](https://tailwindcss.com) `^4.3.1`** — utility styling; global CSS at
  `app/assets/css/main.css`. Uses the new Tailwind v4 engine.
- **Theme config** in `app/app.config.ts` — primary color `green`, neutral `zinc`. Light/dark
  mode supported out of the box.
- **Icons** via Iconify: `@iconify-json/lucide` (UI icons, `i-lucide-*`) and
  `@iconify-json/simple-icons` (brand icons).

## Data, Tables & Charts

- **[@tanstack/table-core](https://tanstack.com/table) `^8.21.3`** — powers `UTable`
  (sorting, filtering, pagination, row selection, column visibility). See
  `app/pages/customers.vue` for the canonical usage pattern.
- **[Unovis](https://unovis.dev) (`@unovis/vue`, `@unovis/ts`) `^1.6.6`** — charts
  (e.g. `app/components/home/HomeChart.client.vue`).
- **[Zod](https://zod.dev) `^4.4.3`** — schema validation (e.g. forms like the customer add modal).
- **Dates**: [`date-fns`](https://date-fns.org) `^4.4.0` and
  [`@internationalized/date`](https://react-spectrum.adobe.com/internationalized/date/)
  `^3.12.2` for the date-range picker.

## State & Utilities

- **[@vueuse/core](https://vueuse.org) `^14.3.0`** + `@vueuse/nuxt` — composable utilities;
  e.g. `createSharedComposable` in `app/composables/useDashboard.ts` for global dashboard state
  and keyboard shortcuts (`defineShortcuts`).
- **[scule](https://github.com/unjs/scule)** — string casing helpers.

## Backend (Nitro)

- API routes live in `server/api/*.ts` using `eventHandler`. Endpoints: `customers`, `mails`,
  `members`, `notifications`. They currently return **in-memory mock data** (no database yet).
- Consumed on the client via Nuxt's `useFetch`.
- CORS enabled for `/api/**` via `routeRules` in `nuxt.config.ts`.

## Project Structure

```
app/
  app.config.ts        # Nuxt UI theme (colors)
  app.vue, error.vue   # Root + error boundary
  layouts/             # default dashboard layout
  pages/               # index, inbox, customers, settings/*
  components/          # home/, inbox/, customers/, settings/ + shared
  composables/         # useDashboard (shared state, shortcuts)
  types/index.d.ts     # User, Mail, Member, Sale, Notification, etc.
  utils/index.ts
server/
  api/                 # Nitro mock endpoints
nuxt.config.ts         # modules: @nuxt/eslint, @nuxt/ui, @vueuse/nuxt
```

## Conventions

- **Auto-imports**: components, composables, and Nuxt/Vue APIs are auto-imported — avoid manual imports for these.
- **Type alias**: `~/types` resolves to `app/types`.
- **ESLint** via `@nuxt/eslint` with stylistic rules: `commaDangle: 'never'`, `braceStyle: '1tbs'`.
- **Components** use `<script setup lang="ts">`; complex table cells are rendered with `h()` render functions.

## Tooling & CI

- Scripts: `dev`, `build`, `preview`, `lint`, `typecheck` (all via pnpm).
- **CI** (`.github/workflows/ci.yml`): on push, runs `pnpm lint` + `pnpm typecheck` on Node 22.
- **Renovate** (`renovate.json`) keeps dependencies up to date.

## Notable Gaps (current state)

- No database / ORM — all data is mocked in `server/api`.
- No authentication layer.
- No test framework configured.
- Despite the `crm-inventory` repo name, the codebase is still the base CRM dashboard template;
  inventory-specific features are not yet implemented.

## Cursor Cloud specific instructions

Single Nuxt service; no DB/auth/external dependencies. Dependencies are refreshed via `pnpm install`
on startup (its `postinstall` runs `nuxt prepare`). Standard commands live in `package.json` /
README: `pnpm dev` (dev server on `http://localhost:3000`), `pnpm lint`, `pnpm typecheck`,
`pnpm build`, `pnpm preview`.

Non-obvious caveats:
- All API data is in-memory mock (`server/api/*`); changes do not persist across restarts.
- Mutations are cosmetic: e.g. the "New customer" modal (`app/components/customers/AddModal.vue`)
  only fires a success toast and does not POST or append a row to the table. Verify such flows by
  the toast/UI feedback, not by expecting persisted data.
- The success toast is transient and short-lived, so screen recordings may miss it; capture a
  screenshot at the moment it appears for evidence.
