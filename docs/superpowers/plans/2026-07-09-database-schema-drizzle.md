# Database Schema (Drizzle + PostgreSQL) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved database schema (`docs/superpowers/specs/2026-07-09-project-overview-database-schema-design.md`) as Drizzle ORM schema files with a generated migration and seed data derived from the current mock APIs.

**Architecture:** Drizzle ORM schema modules live in `server/db/schema/`, split by domain (lookups, catalog, stock, operations, config). `drizzle-kit` generates SQL migrations into `server/db/migrations/`. A local PostgreSQL runs via Docker Compose. A seed script populates the database from the existing mock data shapes. **No API endpoints are wired to the database in this plan** — `server/api/*` keeps serving mock data.

**Tech Stack:** PostgreSQL 17 (Docker), drizzle-orm, drizzle-kit, postgres (postgres.js driver), tsx (script runner). Node 22, pnpm 11.8.0.

## Global Constraints

- Target database: PostgreSQL (spec section "Target database").
- UUID primary keys via `gen_random_uuid()`; `snake_case` names; `created_at`/`updated_at` `timestamptz NOT NULL DEFAULT now()` on every table (spec section 3).
- Money columns are `numeric(12,0)` (spec section 3).
- FKs are `ON DELETE RESTRICT` (Drizzle/Postgres default `NO ACTION` is acceptable) unless the spec marks cascade (spec section 5).
- The 11 enum types and 20 tables must match spec sections 4–5 exactly — no extra columns, no renames.
- ESLint stylistic rules apply to all TS files: single quotes, no trailing commas, 1tbs braces (`pnpm lint` must pass).
- `pnpm typecheck` must pass after every task.
- No test framework exists in this repo; verification is via `pnpm typecheck`, `drizzle-kit generate` output inspection, applied migration, and a `db:verify` script with hard assertions.
- Do not modify any file under `server/api/` or `app/`.

---

### Task 1: Local Postgres + Drizzle tooling

**Files:**
- Create: `docker-compose.yml`
- Create: `.env.example`
- Create: `drizzle.config.ts`
- Create: `server/db/index.ts`
- Modify: `package.json` (scripts + deps via pnpm)
- Modify: `.gitignore` (ensure `.env` ignored)

**Interfaces:**
- Consumes: nothing.
- Produces: `db` export from `server/db/index.ts` (type `PostgresJsDatabase<typeof schema>`), `DATABASE_URL` convention `postgres://crm:crm@localhost:5432/crm_inventory`, pnpm scripts `db:generate`, `db:migrate`, `db:seed`, `db:verify`.

- [ ] **Step 1: Install dependencies**

```bash
pnpm add drizzle-orm postgres
pnpm add -D drizzle-kit tsx
```

Expected: packages added to `package.json`, install succeeds.

- [ ] **Step 2: Create `docker-compose.yml`**

```yaml
services:
  db:
    image: postgres:17
    environment:
      POSTGRES_USER: crm
      POSTGRES_PASSWORD: crm
      POSTGRES_DB: crm_inventory
    ports:
      - '5432:5432'
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

- [ ] **Step 3: Create `.env.example` and ensure `.env` is git-ignored**

`.env.example`:

```bash
DATABASE_URL=postgres://crm:crm@localhost:5432/crm_inventory
```

Copy it for local use: `cp .env.example .env`

Check `.gitignore` contains a `.env` entry; if not, append:

```
.env
```

- [ ] **Step 4: Create `drizzle.config.ts`**

```ts
import { defineConfig } from 'drizzle-kit'

try {
  process.loadEnvFile()
} catch {
  // .env is optional; DATABASE_URL may come from the environment
}

export default defineConfig({
  dialect: 'postgresql',
  schema: './server/db/schema/index.ts',
  out: './server/db/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL ?? 'postgres://crm:crm@localhost:5432/crm_inventory'
  }
})
```

- [ ] **Step 5: Create `server/db/index.ts`**

```ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const connectionString = process.env.DATABASE_URL ?? 'postgres://crm:crm@localhost:5432/crm_inventory'

export const client = postgres(connectionString)
export const db = drizzle(client, { schema })
```

Note: this file imports `./schema`, created in Tasks 2–6. It will not typecheck until Task 2 creates `server/db/schema/index.ts`; that is fine — commit it in this task, run typecheck from Task 2 onward.

- [ ] **Step 6: Add pnpm scripts to `package.json`**

In the `scripts` block add (keep existing scripts unchanged):

```json
"db:generate": "drizzle-kit generate",
"db:migrate": "drizzle-kit migrate",
"db:seed": "tsx server/db/seed.ts",
"db:verify": "tsx server/db/verify.ts"
```

- [ ] **Step 7: Start Postgres and confirm it accepts connections**

```bash
docker compose up -d db
docker compose exec db pg_isready -U crm -d crm_inventory
```

Expected: `... accepting connections`

- [ ] **Step 8: Commit**

```bash
git add docker-compose.yml .env.example drizzle.config.ts server/db/index.ts package.json pnpm-lock.yaml .gitignore
git commit -m "chore(db): add postgres compose, drizzle tooling and db client"
```

---

### Task 2: Schema — enums, helpers, lookup tables

**Files:**
- Create: `server/db/schema/enums.ts`
- Create: `server/db/schema/helpers.ts`
- Create: `server/db/schema/lookups.ts`
- Create: `server/db/schema/index.ts`

**Interfaces:**
- Consumes: nothing.
- Produces: enum objects `productStatus`, `productType`, `trackedBy`, `pricingType`, `activationMethod`, `stockUnitStatus`, `countStatus`, `adjustmentStatus`, `orderStatus`, `orderWorkflowStatus`, `customFieldType`; `timestamps` column helper; tables `categories`, `companies`, `platforms`, `pricingPlans`, `locations` (each: `id`, `name`, timestamps).

- [ ] **Step 1: Create `server/db/schema/enums.ts`**

```ts
import { pgEnum } from 'drizzle-orm/pg-core'

export const productStatus = pgEnum('product_status', ['active', 'inactive', 'draft', 'discontinued'])
export const productType = pgEnum('product_type', ['single', 'dual', 'bundling'])
export const trackedBy = pgEnum('tracked_by', ['unique_serial_number', 'batch_number', 'lot', 'quantity_count'])
export const pricingType = pgEnum('pricing_type', ['subscription', 'one_time_payment'])
export const activationMethod = pgEnum('activation_method', ['scheduled', 'immediate'])
export const stockUnitStatus = pgEnum('stock_unit_status', ['ready', 'pending', 'draft'])
export const countStatus = pgEnum('count_status', ['pending_count', 'pending_approval', 'completed'])
export const adjustmentStatus = pgEnum('adjustment_status', ['pending', 'approved', 'rejected'])
export const orderStatus = pgEnum('order_status', ['draft', 'pending', 'on_delivery', 'delivered'])
export const orderWorkflowStatus = pgEnum('order_workflow_status', ['waiting', 'ready', 'draft'])
export const customFieldType = pgEnum('custom_field_type', ['text', 'date', 'number', 'dropdown'])
```

- [ ] **Step 2: Create `server/db/schema/helpers.ts`**

```ts
import { timestamp } from 'drizzle-orm/pg-core'

export const timestamps = {
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow()
}
```

- [ ] **Step 3: Create `server/db/schema/lookups.ts`**

```ts
import { pgTable, text, uuid } from 'drizzle-orm/pg-core'
import { timestamps } from './helpers'

function lookupColumns() {
  return {
    id: uuid('id').primaryKey().defaultRandom(),
    name: text('name').notNull().unique(),
    ...timestamps
  }
}

export const categories = pgTable('categories', lookupColumns())
export const companies = pgTable('companies', lookupColumns())
export const platforms = pgTable('platforms', lookupColumns())
export const pricingPlans = pgTable('pricing_plans', lookupColumns())
export const locations = pgTable('locations', lookupColumns())
```

- [ ] **Step 4: Create `server/db/schema/index.ts`** (will grow in later tasks)

```ts
export * from './enums'
export * from './lookups'
```

- [ ] **Step 5: Verify**

```bash
pnpm lint && pnpm typecheck
```

Expected: both pass.

- [ ] **Step 6: Commit**

```bash
git add server/db/schema
git commit -m "feat(db): add enums, timestamp helper and lookup tables"
```

---

### Task 3: Schema — catalog (products, pricing, bundles)

**Files:**
- Create: `server/db/schema/catalog.ts`
- Modify: `server/db/schema/index.ts`

**Interfaces:**
- Consumes: enums from `./enums`, `timestamps` from `./helpers`, `categories`/`companies`/`platforms`/`pricingPlans` from `./lookups`.
- Produces: tables `products`, `productPricing`, `bundleComponents`, `bundleItems`. Later tasks reference `products.id` and `locations.id`.

- [ ] **Step 1: Create `server/db/schema/catalog.ts`**

```ts
import { sql } from 'drizzle-orm'
import { boolean, check, date, integer, numeric, pgTable, text, unique, uuid } from 'drizzle-orm/pg-core'
import { activationMethod, pricingType, productStatus, productType, trackedBy } from './enums'
import { timestamps } from './helpers'
import { categories, companies, platforms, pricingPlans } from './lookups'

export const products = pgTable('products', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: text('name').notNull(),
  sku: text('sku').notNull().unique(),
  reference: text('reference').notNull(),
  notes: text('notes'),
  productType: productType('product_type').notNull(),
  status: productStatus('status').notNull().default('draft'),
  trackedBy: trackedBy('tracked_by').notNull(),
  categoryId: uuid('category_id').references(() => categories.id),
  companyId: uuid('company_id').references(() => companies.id),
  platformId: uuid('platform_id').references(() => platforms.id),
  published: boolean('published').notNull().default(false),
  trackInventory: boolean('track_inventory').notNull().default(true),
  ...timestamps
})

export const productPricing = pgTable('product_pricing', {
  id: uuid('id').primaryKey().defaultRandom(),
  productId: uuid('product_id').notNull().references(() => products.id, { onDelete: 'cascade' }),
  priceVersion: text('price_version').notNull(),
  pricingPlanId: uuid('pricing_plan_id').references(() => pricingPlans.id),
  pricingType: pricingType('pricing_type').notNull(),
  monthlyFee: numeric('monthly_fee', { precision: 12, scale: 0 }).notNull().default('0'),
  initialFee: numeric('initial_fee', { precision: 12, scale: 0 }).notNull().default('0'),
  depositFee: numeric('deposit_fee', { precision: 12, scale: 0 }).notNull().default('0'),
  isActive: boolean('is_active').notNull().default(false),
  statusSince: date('status_since').notNull(),
  activationMethod: activationMethod('activation_method').notNull(),
  activationStartDate: date('activation_start_date'),
  ...timestamps
}, table => [
  unique('product_pricing_product_version_unique').on(table.productId, table.priceVersion)
])

export const bundleComponents = pgTable('bundle_components', {
  id: uuid('id').primaryKey().defaultRandom(),
  productId: uuid('product_id').notNull().references(() => products.id, { onDelete: 'cascade' }),
  name: text('name').notNull(),
  required: boolean('required').notNull().default(false),
  position: integer('position').notNull().default(0),
  ...timestamps
})

export const bundleItems = pgTable('bundle_items', {
  id: uuid('id').primaryKey().defaultRandom(),
  componentId: uuid('component_id').notNull().references(() => bundleComponents.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => products.id),
  quantity: integer('quantity').notNull(),
  ...timestamps
}, table => [
  check('bundle_items_quantity_positive', sql`${table.quantity} > 0`)
])
```

- [ ] **Step 2: Add to `server/db/schema/index.ts`**

```ts
export * from './catalog'
```

- [ ] **Step 3: Verify**

```bash
pnpm lint && pnpm typecheck
```

Expected: both pass.

- [ ] **Step 4: Commit**

```bash
git add server/db/schema
git commit -m "feat(db): add catalog tables (products, pricing, bundles)"
```

---

### Task 4: Schema — stock and physical inventory

**Files:**
- Create: `server/db/schema/stock.ts`
- Modify: `server/db/schema/index.ts`

**Interfaces:**
- Consumes: `products` from `./catalog`, `locations` from `./lookups`, enums `stockUnitStatus`/`countStatus`/`adjustmentStatus`, `timestamps`.
- Produces: tables `stockUnits`, `inventoryLevels`, `physicalInventoryCounts`, `countAdjustments`.

- [ ] **Step 1: Create `server/db/schema/stock.ts`**

```ts
import { sql } from 'drizzle-orm'
import { check, integer, pgTable, text, timestamp, unique, uuid } from 'drizzle-orm/pg-core'
import { products } from './catalog'
import { adjustmentStatus, countStatus, stockUnitStatus } from './enums'
import { timestamps } from './helpers'
import { locations } from './lookups'

export const stockUnits = pgTable('stock_units', {
  id: uuid('id').primaryKey().defaultRandom(),
  productId: uuid('product_id').notNull().references(() => products.id),
  locationId: uuid('location_id').references(() => locations.id),
  imei: text('imei'),
  iccid: text('iccid'),
  msnNumber: text('msn_number'),
  activationCode: text('activation_code'),
  vendor: text('vendor'),
  status: stockUnitStatus('status').notNull().default('draft'),
  ...timestamps
})

export const inventoryLevels = pgTable('inventory_levels', {
  id: uuid('id').primaryKey().defaultRandom(),
  productId: uuid('product_id').notNull().references(() => products.id),
  locationId: uuid('location_id').notNull().references(() => locations.id),
  quantity: integer('quantity').notNull().default(0),
  ...timestamps
}, table => [
  unique('inventory_levels_product_location_unique').on(table.productId, table.locationId),
  check('inventory_levels_quantity_non_negative', sql`${table.quantity} >= 0`)
])

export const physicalInventoryCounts = pgTable('physical_inventory_counts', {
  id: uuid('id').primaryKey().defaultRandom(),
  productId: uuid('product_id').notNull().references(() => products.id),
  locationId: uuid('location_id').references(() => locations.id),
  onHand: integer('on_hand').notNull(),
  counted: integer('counted'),
  status: countStatus('status').notNull().default('pending_count'),
  ...timestamps
})

export const countAdjustments = pgTable('count_adjustments', {
  id: uuid('id').primaryKey().defaultRandom(),
  countId: uuid('count_id').notNull().references(() => physicalInventoryCounts.id, { onDelete: 'cascade' }),
  requestedQuantity: integer('requested_quantity').notNull(),
  reason: text('reason').notNull(),
  status: adjustmentStatus('status').notNull().default('pending'),
  reviewedBy: text('reviewed_by'),
  reviewedAt: timestamp('reviewed_at', { withTimezone: true }),
  ...timestamps
})
```

- [ ] **Step 2: Add to `server/db/schema/index.ts`**

```ts
export * from './stock'
```

- [ ] **Step 3: Verify**

```bash
pnpm lint && pnpm typecheck
```

Expected: both pass.

- [ ] **Step 4: Commit**

```bash
git add server/db/schema
git commit -m "feat(db): add stock and physical inventory tables"
```

---

### Task 5: Schema — operations (delivery orders and receipts)

**Files:**
- Create: `server/db/schema/operations.ts`
- Modify: `server/db/schema/index.ts`

**Interfaces:**
- Consumes: `products` from `./catalog`, `locations` from `./lookups`, enums `orderStatus`/`orderWorkflowStatus`, `timestamps`.
- Produces: tables `deliveryOrders`, `deliveryOrderLines`, `deliveryOrderQuantityLines`, `receipts`, `receiptLines`, `receiptQuantityLines`.

- [ ] **Step 1: Create `server/db/schema/operations.ts`**

```ts
import { sql } from 'drizzle-orm'
import { check, date, integer, pgTable, text, timestamp, uuid } from 'drizzle-orm/pg-core'
import { products } from './catalog'
import { orderStatus, orderWorkflowStatus } from './enums'
import { timestamps } from './helpers'
import { locations } from './lookups'

export const deliveryOrders = pgTable('delivery_orders', {
  id: uuid('id').primaryKey().defaultRandom(),
  reference: text('reference').notNull().unique(),
  warehouseRef: text('warehouse_ref').notNull(),
  destination: text('destination').notNull(),
  sourceLocationId: uuid('source_location_id').references(() => locations.id),
  operationType: text('operation_type').notNull(),
  shippingPolicy: text('shipping_policy'),
  scheduleDate: date('schedule_date').notNull(),
  scheduledAt: timestamp('scheduled_at', { withTimezone: true }),
  status: orderStatus('status').notNull().default('draft'),
  workflowStatus: orderWorkflowStatus('workflow_status'),
  ...timestamps
})

export const deliveryOrderLines = pgTable('delivery_order_lines', {
  id: uuid('id').primaryKey().defaultRandom(),
  orderId: uuid('order_id').notNull().references(() => deliveryOrders.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => products.id),
  demand: integer('demand').notNull(),
  ...timestamps
}, table => [
  check('delivery_order_lines_demand_positive', sql`${table.demand} > 0`)
])

export const deliveryOrderQuantityLines = pgTable('delivery_order_quantity_lines', {
  id: uuid('id').primaryKey().defaultRandom(),
  orderId: uuid('order_id').notNull().references(() => deliveryOrders.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => products.id),
  lotSerial: text('lot_serial').notNull().default('N/A'),
  demand: integer('demand').notNull(),
  quantity: integer('quantity').notNull().default(0),
  ...timestamps
})

export const receipts = pgTable('receipts', {
  id: uuid('id').primaryKey().defaultRandom(),
  reference: text('reference').notNull().unique(),
  warehouseRef: text('warehouse_ref').notNull(),
  destination: text('destination').notNull(),
  sourceLocationId: uuid('source_location_id').references(() => locations.id),
  operationType: text('operation_type').notNull(),
  notes: text('notes'),
  scheduleDate: date('schedule_date').notNull(),
  scheduledAt: timestamp('scheduled_at', { withTimezone: true }),
  status: orderStatus('status').notNull().default('draft'),
  workflowStatus: orderWorkflowStatus('workflow_status'),
  ...timestamps
})

export const receiptLines = pgTable('receipt_lines', {
  id: uuid('id').primaryKey().defaultRandom(),
  receiptId: uuid('receipt_id').notNull().references(() => receipts.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => products.id),
  demand: integer('demand').notNull(),
  ...timestamps
}, table => [
  check('receipt_lines_demand_positive', sql`${table.demand} > 0`)
])

export const receiptQuantityLines = pgTable('receipt_quantity_lines', {
  id: uuid('id').primaryKey().defaultRandom(),
  receiptId: uuid('receipt_id').notNull().references(() => receipts.id, { onDelete: 'cascade' }),
  productId: uuid('product_id').notNull().references(() => products.id),
  lotSerial: text('lot_serial').notNull().default('N/A'),
  demand: integer('demand').notNull(),
  quantity: integer('quantity').notNull().default(0),
  ...timestamps
})
```

- [ ] **Step 2: Add to `server/db/schema/index.ts`**

```ts
export * from './operations'
```

- [ ] **Step 3: Verify**

```bash
pnpm lint && pnpm typecheck
```

Expected: both pass.

- [ ] **Step 4: Commit**

```bash
git add server/db/schema
git commit -m "feat(db): add delivery order and receipt tables"
```

---

### Task 6: Schema — custom fields

**Files:**
- Create: `server/db/schema/config.ts`
- Modify: `server/db/schema/index.ts`

**Interfaces:**
- Consumes: enum `customFieldType`, `timestamps`.
- Produces: table `customFields` with `conditionalVisibility` typed as `Array<{ field: string, operator: string, value: string }>`.

- [ ] **Step 1: Create `server/db/schema/config.ts`**

```ts
import { boolean, jsonb, pgTable, text, uuid } from 'drizzle-orm/pg-core'
import { customFieldType } from './enums'
import { timestamps } from './helpers'

export interface CustomFieldConditionRule {
  field: string
  operator: string
  value: string
}

export const customFields = pgTable('custom_fields', {
  id: uuid('id').primaryKey().defaultRandom(),
  label: text('label').notNull(),
  fieldType: customFieldType('field_type').notNull(),
  fieldLocation: text('field_location').notNull(),
  section: text('section').notNull(),
  required: boolean('required').notNull().default(false),
  visible: boolean('visible').notNull().default(true),
  description: text('description'),
  conditionalVisibility: jsonb('conditional_visibility').$type<CustomFieldConditionRule[]>(),
  ...timestamps
})
```

- [ ] **Step 2: Add to `server/db/schema/index.ts`** (final state of the file)

```ts
export * from './enums'
export * from './lookups'
export * from './catalog'
export * from './stock'
export * from './operations'
export * from './config'
```

- [ ] **Step 3: Verify**

```bash
pnpm lint && pnpm typecheck
```

Expected: both pass.

- [ ] **Step 4: Commit**

```bash
git add server/db/schema
git commit -m "feat(db): add custom fields table"
```

---

### Task 7: Generate and apply the migration

**Files:**
- Create (generated): `server/db/migrations/0000_*.sql` + `server/db/migrations/meta/*`

**Interfaces:**
- Consumes: complete schema from Tasks 2–6.
- Produces: applied database with all 20 tables and 11 enums; migration files committed.

- [ ] **Step 1: Generate the migration**

```bash
pnpm db:generate
```

Expected: one new SQL file in `server/db/migrations/`, output listing 20 tables.

- [ ] **Step 2: Inspect the generated SQL against the spec**

Open the generated `0000_*.sql` and confirm:
- 11 `CREATE TYPE` statements (the enums from spec section 4)
- 20 `CREATE TABLE` statements
- `product_pricing` has the unique constraint on `(product_id, price_version)`
- `inventory_levels` has the unique constraint on `(product_id, location_id)` and the `quantity >= 0` check
- cascade deletes only on: `product_pricing.product_id`, `bundle_components.product_id`, `bundle_items.component_id`, `count_adjustments.count_id`, all `*_lines` parent FKs

- [ ] **Step 3: Apply the migration**

```bash
docker compose up -d db
pnpm db:migrate
```

Expected: exits 0.

- [ ] **Step 4: Verify tables exist in Postgres**

```bash
docker compose exec db psql -U crm -d crm_inventory -c '\dt'
```

Expected: 20 rows (plus drizzle's `__drizzle_migrations` in the `drizzle` schema).

- [ ] **Step 5: Commit**

```bash
git add server/db/migrations
git commit -m "feat(db): generate initial migration"
```

---

### Task 8: Seed and verify

**Files:**
- Create: `server/db/seed.ts`
- Create: `server/db/verify.ts`

**Interfaces:**
- Consumes: `db`/`client` from `server/db/index.ts`, all tables from `server/db/schema`.
- Produces: idempotent-enough seed (truncates then inserts); `db:verify` script that exits non-zero on failure.

Seed data notes (mapping mock data per spec section 7):
- Component products (Nec Device, X4 Device, Docomo 1GB, Softbank 1GB) do not exist in `server/utils/productsData.ts` as products, but bundle items must reference real products — the seed creates them.
- Mock physical-inventory product names (`Akari LED Panel 60x60` etc.) don't exist in the product mock; the seed creates counts against seeded products instead.
- Fee strings like `'¥20.000 JYP'` become numeric values (`20000`).

- [ ] **Step 1: Write `server/db/seed.ts`**

```ts
import { sql } from 'drizzle-orm'
import { client, db } from './index'
import {
  bundleComponents,
  bundleItems,
  categories,
  companies,
  countAdjustments,
  customFields,
  deliveryOrderLines,
  deliveryOrderQuantityLines,
  deliveryOrders,
  inventoryLevels,
  locations,
  physicalInventoryCounts,
  platforms,
  pricingPlans,
  products,
  productPricing,
  receiptLines,
  receipts,
  stockUnits
} from './schema'

async function seed() {
  await db.execute(sql`
    TRUNCATE TABLE
      count_adjustments, physical_inventory_counts,
      delivery_order_quantity_lines, delivery_order_lines, delivery_orders,
      receipt_quantity_lines, receipt_lines, receipts,
      inventory_levels, stock_units,
      bundle_items, bundle_components, product_pricing, products,
      custom_fields, categories, companies, platforms, pricing_plans, locations
    RESTART IDENTITY CASCADE
  `)


  const [wifi, smartphones, tablets, simCards, devices] = await db.insert(categories).values([
    { name: 'WIFI' },
    { name: 'Smartphones' },
    { name: 'Tablets' },
    { name: 'SIM Cards' },
    { name: 'Devices' }
  ]).returning()

  const [vdm, vds] = await db.insert(companies).values([
    { name: 'VDM' },
    { name: 'VDS' }
  ]).returning()

  const [sk] = await db.insert(platforms).values([
    { name: 'SK' },
    { name: 'Docomo' },
    { name: 'Softbank' }
  ]).returning()

  const [skSimPlan] = await db.insert(pricingPlans).values([
    { name: 'SK SIM Plan' },
    { name: 'VDM Data Plan' }
  ]).returning()

  const [whStock] = await db.insert(locations).values([
    { name: 'WH/Stock' },
    { name: 'Partner/Customer' }
  ]).returning()

  const [wifiProduct, necDevice, x4Device, docomo1gb, softbank1gb] = await db.insert(products).values([
    {
      name: 'internet Wifi 10GB',
      sku: 'WIFI-001',
      reference: '220041515125',
      productType: 'bundling',
      status: 'active',
      trackedBy: 'unique_serial_number',
      categoryId: wifi!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'Nec Device',
      sku: 'nec_device_sku',
      reference: '220041515126',
      productType: 'single',
      status: 'active',
      trackedBy: 'unique_serial_number',
      categoryId: devices!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'X4 Device',
      sku: 'x4_device_sku',
      reference: '220041515127',
      productType: 'single',
      status: 'active',
      trackedBy: 'unique_serial_number',
      categoryId: devices!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'Docomo 1GB',
      sku: 'd_1gb_device_sku',
      reference: '220041515128',
      productType: 'single',
      status: 'active',
      trackedBy: 'batch_number',
      categoryId: simCards!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'Softbank 1GB',
      sku: 's_1gb_device_sku',
      reference: '220041515129',
      productType: 'single',
      status: 'active',
      trackedBy: 'batch_number',
      categoryId: simCards!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'SIM CARD 001',
      sku: 'SIM-002',
      reference: '002415515617',
      productType: 'single',
      status: 'active',
      trackedBy: 'unique_serial_number',
      categoryId: smartphones!.id,
      companyId: vds!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'SIM CARD 002',
      sku: 'SIM-003',
      reference: '002415515618',
      productType: 'dual',
      status: 'inactive',
      trackedBy: 'lot',
      categoryId: tablets!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: false,
      trackInventory: false
    }
  ]).returning()

  await db.insert(productPricing).values([
    {
      productId: wifiProduct!.id,
      priceVersion: 'V.1',
      pricingPlanId: skSimPlan!.id,
      pricingType: 'subscription',
      monthlyFee: '20000',
      initialFee: '1000',
      depositFee: '1000',
      isActive: false,
      statusSince: '2026-04-24',
      activationMethod: 'immediate'
    },
    {
      productId: wifiProduct!.id,
      priceVersion: 'V.2',
      pricingPlanId: skSimPlan!.id,
      pricingType: 'subscription',
      monthlyFee: '20000',
      initialFee: '1000',
      depositFee: '1000',
      isActive: true,
      statusSince: '2026-04-24',
      activationMethod: 'scheduled',
      activationStartDate: '2026-06-01'
    }
  ])

  const [deviceComponent, simComponent] = await db.insert(bundleComponents).values([
    { productId: wifiProduct!.id, name: 'Device Component', required: false, position: 0 },
    { productId: wifiProduct!.id, name: 'SIM Card Component', required: true, position: 1 }
  ]).returning()

  await db.insert(bundleItems).values([
    { componentId: deviceComponent!.id, productId: necDevice!.id, quantity: 5 },
    { componentId: deviceComponent!.id, productId: x4Device!.id, quantity: 6 },
    { componentId: simComponent!.id, productId: docomo1gb!.id, quantity: 2 },
    { componentId: simComponent!.id, productId: softbank1gb!.id, quantity: 3 }
  ])

  await db.insert(stockUnits).values(Array.from({ length: 10 }, (_, i) => ({
    productId: wifiProduct!.id,
    locationId: whStock!.id,
    imei: String(2415515616 + i * 1000).padStart(12, '0'),
    iccid: String(245151616166 + i * 1000),
    msnNumber: String(81256677899 + i).padStart(12, '0'),
    activationCode: String(99921566 + i),
    vendor: ['VDM', 'VDN', 'VDO'][i % 3],
    status: 'ready' as const
  })))

  await db.insert(inventoryLevels).values([
    { productId: docomo1gb!.id, locationId: whStock!.id, quantity: 120 },
    { productId: softbank1gb!.id, locationId: whStock!.id, quantity: 80 }
  ])

  const [count] = await db.insert(physicalInventoryCounts).values([
    { productId: docomo1gb!.id, locationId: whStock!.id, onHand: 120, counted: 118, status: 'pending_approval' },
    { productId: softbank1gb!.id, locationId: whStock!.id, onHand: 80, status: 'pending_count' }
  ]).returning()

  await db.insert(countAdjustments).values([
    { countId: count!.id, requestedQuantity: 118, reason: 'Damaged during transport', status: 'pending' }
  ])

  const [order] = await db.insert(deliveryOrders).values([
    {
      reference: '001-224-241',
      warehouseRef: '#WH/OUT/2026/0042',
      destination: 'Partner/Customer',
      sourceLocationId: whStock!.id,
      operationType: 'Delivery Orders',
      shippingPolicy: 'When products are ready',
      scheduleDate: '2026-03-17',
      scheduledAt: new Date('2026-03-20T00:00:00Z'),
      status: 'draft',
      workflowStatus: 'waiting'
    }
  ]).returning()

  await db.insert(deliveryOrderLines).values([
    { orderId: order!.id, productId: docomo1gb!.id, demand: 50 }
  ])

  await db.insert(deliveryOrderQuantityLines).values([
    { orderId: order!.id, productId: docomo1gb!.id, lotSerial: 'N/A', demand: 50, quantity: 50 }
  ])

  const [receipt] = await db.insert(receipts).values([
    {
      reference: 'RCP-001-224',
      warehouseRef: '#WH/IN/2026/0042',
      destination: 'WH/Stock',
      sourceLocationId: whStock!.id,
      operationType: 'Receipts',
      scheduleDate: '2026-03-15',
      status: 'pending',
      workflowStatus: 'ready'
    }
  ]).returning()

  await db.insert(receiptLines).values([
    { receiptId: receipt!.id, productId: softbank1gb!.id, demand: 100 }
  ])

  await db.insert(customFields).values([
    { label: 'Activation Code', fieldType: 'text', fieldLocation: 'Product Activation', section: 'Add Product Quantity Modal', required: false, visible: true },
    { label: 'Batch Expiry', fieldType: 'date', fieldLocation: 'Delivery', section: 'Add Delivery', required: false, visible: true },
    { label: 'ICCID', fieldType: 'number', fieldLocation: 'Product Activation', section: 'Add Product Quantity Modal', required: false, visible: true },
    { label: 'Product Category', fieldType: 'dropdown', fieldLocation: 'Product Activation', section: 'Add Product Quantity Modal', required: false, visible: true }
  ])

  console.log('Seed complete')
}

seed()
  .catch((error) => {
    console.error(error)
    process.exitCode = 1
  })
  .finally(() => client.end())
```

- [ ] **Step 2: Run the seed**

```bash
pnpm db:seed
```

Expected: `Seed complete`, exit 0.

- [ ] **Step 3: Write `server/db/verify.ts`**

```ts
import { count, eq } from 'drizzle-orm'
import { client, db } from './index'
import { bundleComponents, bundleItems, categories, customFields, deliveryOrderLines, inventoryLevels, products, productPricing, stockUnits } from './schema'

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(`Verification failed: ${message}`)
  }
}

async function verify() {
  const [productCount] = await db.select({ value: count() }).from(products)
  assert((productCount?.value ?? 0) === 7, `expected 7 products, got ${productCount?.value}`)

  const [categoryCount] = await db.select({ value: count() }).from(categories)
  assert((categoryCount?.value ?? 0) === 5, `expected 5 categories, got ${categoryCount?.value}`)

  const wifi = await db.query.products.findFirst({ where: eq(products.sku, 'WIFI-001') })
  assert(wifi !== undefined, 'WIFI-001 product missing')
  assert(wifi!.productType === 'bundling', 'WIFI-001 should be a bundling product')

  const pricingRows = await db.select().from(productPricing).where(eq(productPricing.productId, wifi!.id))
  assert(pricingRows.length === 2, `expected 2 pricing versions, got ${pricingRows.length}`)
  assert(pricingRows.some(row => row.activationStartDate === '2026-06-01'), 'scheduled pricing should have start date')

  const [bundleItemCount] = await db.select({ value: count() }).from(bundleItems)
  assert((bundleItemCount?.value ?? 0) === 4, `expected 4 bundle items, got ${bundleItemCount?.value}`)

  const [unitCount] = await db.select({ value: count() }).from(stockUnits)
  assert((unitCount?.value ?? 0) === 10, `expected 10 stock units, got ${unitCount?.value}`)

  const [levelCount] = await db.select({ value: count() }).from(inventoryLevels)
  assert((levelCount?.value ?? 0) === 2, `expected 2 inventory levels, got ${levelCount?.value}`)

  const [lineCount] = await db.select({ value: count() }).from(deliveryOrderLines)
  assert((lineCount?.value ?? 0) === 1, `expected 1 delivery order line, got ${lineCount?.value}`)

  const [fieldCount] = await db.select({ value: count() }).from(customFields)
  assert((fieldCount?.value ?? 0) === 4, `expected 4 custom fields, got ${fieldCount?.value}`)

  const component = await db.select().from(bundleComponents).limit(1)
  assert(component.length === 1, 'expected at least one bundle component')

  let constraintHeld = false
  try {
    await db.insert(bundleItems).values({
      componentId: component[0]!.id,
      productId: wifi!.id,
      quantity: 0
    })
  } catch {
    constraintHeld = true
  }
  assert(constraintHeld, 'bundle_items quantity > 0 check should reject quantity 0')

  console.log('All verifications passed')
}

verify()
  .catch((error) => {
    console.error(error)
    process.exitCode = 1
  })
  .finally(() => client.end())
```

- [ ] **Step 4: Run verification**

```bash
pnpm db:verify
```

Expected: `All verifications passed`, exit 0.

- [ ] **Step 5: Re-run seed to confirm it is re-runnable**

```bash
pnpm db:seed && pnpm db:verify
```

Expected: both succeed (truncate makes the seed re-runnable).

- [ ] **Step 6: Final lint + typecheck**

```bash
pnpm lint && pnpm typecheck
```

Expected: both pass.

- [ ] **Step 7: Commit**

```bash
git add server/db/seed.ts server/db/verify.ts
git commit -m "feat(db): add seed and verification scripts"
```
