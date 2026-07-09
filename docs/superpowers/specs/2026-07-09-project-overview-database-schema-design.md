# CRM-Inventory — Project Overview & Database Schema Design

- **Date:** 2026-07-09
- **Status:** Approved design (documentation only — no implementation in this spec)
- **Target database:** PostgreSQL
- **Source of truth:** The implemented app (pages, types in `app/types/index.d.ts`, mock APIs in `server/api/` and `server/utils/`), which mirrors the CRM–Inventory Redesign Figma file.
- **Scope:** Core inventory domain only. Template pages (customers, inbox/mails, members, notifications) and authentication are out of scope.

## 1. Project Overview

CRM-Inventory is a Nuxt 4 dashboard for managing a telecom/device product catalog and its warehouse operations.

The core loop:

1. **Define products** — SIM cards, devices, WiFi bundles — with versioned pricing and optional bundle composition.
2. **Track stock** — serialized units (IMEI/ICCID) for devices and SIMs, quantity levels per location for bulk goods.
3. **Move stock** — in via receipts, out via delivery orders, each with demand lines and lot/serial quantity lines.
4. **Verify stock** — physical inventory counts; discrepancies raise adjustment requests that go through an approve/reject workflow with a visible history timeline.
5. **Configure** — pricing plans, pricing lists, and custom form fields with conditional visibility.

### Application structure

| Area | Pages | Backing endpoints |
|---|---|---|
| Dashboard | `/` (inventory metrics, low stock, incoming) | `server/api/inventory.ts` |
| Products | `/products`, `/products/create`, `/products/[id]`, `/products/[id]/edit`, `/products/[id]/manage-quantity` | `server/api/products*`, `server/utils/productsData.ts`, `productQuantitiesData.ts` |
| Operations | `/operations/physical-inventory`, `/operations/delivery-orders`, `/operations/receipts` | `server/api/physical-inventory.ts`, `delivery-orders*`, `receipts*` |
| Configuration | `/config/pricing-list`, `/config/pricing-plan`, `/config/field` | `server/api/fields.ts` |

All data is currently in-memory mock data; this schema is the blueprint for replacing it with a real database.

## 2. Entity Map

Arrow = "has many" unless noted.

```
categories ─┐
companies  ─┼──< products ──< product_pricing ──> pricing_plans
platforms  ─┘       │
                    ├──< bundle_components ──< bundle_items ──> products (component product)
                    ├──< stock_units ──> locations
                    └──< inventory_levels ──> locations

physical_inventory_counts ──> products
        └──< count_adjustments (request → approve/reject, doubles as history timeline)

delivery_orders ──< delivery_order_lines ──> products
        └──< delivery_order_quantity_lines ──> products

receipts ──< receipt_lines ──> products
        └──< receipt_quantity_lines ──> products

custom_fields (standalone; conditional visibility rules as JSONB)
```

### Key decisions

1. **`bundle_items` reference real products.** The mock data stores name + SKU strings; the schema upgrades this to a foreign key to `products`, since bundle items are picked from the product list in the UI.
2. **`inventory_levels` is separate from `stock_units`.** Quantity-counted goods (tote bags, cables) need one level row per location; serialized goods (SIMs, devices) get one `stock_units` row per physical unit. A product uses one or both depending on its `tracked_by` mode.
3. **Adjustment workflow lives in `count_adjustments`** — one row per adjustment request, carrying reason, requested count, status, and reviewer. The rows double as the History timeline shown in the UI.
4. **Delivery orders and receipts stay as separate table pairs** despite structural similarity — they are separate menus, their statuses may diverge, and merging them into a generic "stock moves" table would complicate the app for no current gain.
5. **User-creatable options are lookup tables, fixed sets are enums.** The UI has "+" create buttons for category, company, platform, and pricing plan — these must be tables. Status sets are fixed by the UI — these are enums.
6. **No `users` table.** Auth is out of scope; `reviewed_by` is a plain text column until an auth layer lands.

## 3. Conventions

- UUID primary keys (`gen_random_uuid()`).
- `snake_case` table and column names.
- `created_at` / `updated_at` (`timestamptz`, default `now()`) on every table.
- Foreign keys `ON DELETE RESTRICT` unless noted as cascade.
- Money as `numeric(12,0)` — JPY has no decimal places.
- Fixed status sets as PostgreSQL enum types.

## 4. Enum Types

| Enum | Values |
|---|---|
| `product_status` | `active`, `inactive`, `draft`, `discontinued` |
| `product_type` | `single`, `dual`, `bundling` |
| `tracked_by` | `unique_serial_number`, `batch_number`, `lot`, `quantity_count` |
| `pricing_type` | `subscription`, `one_time_payment` |
| `activation_method` | `scheduled`, `immediate` |
| `stock_unit_status` | `ready`, `pending`, `draft` |
| `count_status` | `pending_count`, `pending_approval`, `completed` |
| `adjustment_status` | `pending`, `approved`, `rejected` |
| `order_status` | `draft`, `pending`, `on_delivery`, `delivered` |
| `order_workflow_status` | `waiting`, `ready`, `draft` |
| `custom_field_type` | `text`, `date`, `number`, `dropdown` |

## 5. Tables

### 5.1 Lookup tables

Each of these has the same shape: `id` (uuid PK), `name` (text, unique, not null), `created_at`, `updated_at`.

| Table | Populated from / used by |
|---|---|
| `categories` | Product form "Category" select + create modal |
| `companies` | Product form "Company" select + create modal |
| `platforms` | Product form "Platform" select |
| `pricing_plans` | Add Pricing modal "Pricing Plan" select; `/config/pricing-plan` |
| `locations` | Stock locations (e.g. `WH/Stock`), inventory and order source locations |

### 5.2 Catalog

#### `products`

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `name` | text | not null |
| `sku` | text | not null, unique |
| `reference` | text | not null |
| `notes` | text | nullable |
| `product_type` | product_type | not null |
| `status` | product_status | not null, default `draft` |
| `tracked_by` | tracked_by | not null |
| `category_id` | uuid | FK → categories |
| `company_id` | uuid | FK → companies |
| `platform_id` | uuid | FK → platforms |
| `published` | boolean | not null, default false |
| `track_inventory` | boolean | not null, default true |

#### `product_pricing`

One row per price version (V.1, V.2, …) of a product.

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `product_id` | uuid | FK → products, cascade delete |
| `price_version` | text | not null; unique `(product_id, price_version)` |
| `pricing_plan_id` | uuid | FK → pricing_plans |
| `pricing_type` | pricing_type | not null |
| `monthly_fee` | numeric(12,0) | not null, default 0 |
| `initial_fee` | numeric(12,0) | not null, default 0 |
| `deposit_fee` | numeric(12,0) | not null, default 0 |
| `is_active` | boolean | not null, default false |
| `status_since` | date | not null |
| `activation_method` | activation_method | not null |
| `activation_start_date` | date | nullable; set only when `activation_method = 'scheduled'` |

#### `bundle_components`

Named groups within a bundle product (e.g. "Device Component", "SIM Card Component").

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `product_id` | uuid | FK → products (the bundle), cascade delete |
| `name` | text | not null |
| `required` | boolean | not null, default false |
| `position` | integer | not null, default 0 |

#### `bundle_items`

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `component_id` | uuid | FK → bundle_components, cascade delete |
| `product_id` | uuid | FK → products (the component product) |
| `quantity` | integer | not null, check > 0 |

"Total Bundle" and "Total Stock" badges in the UI are computed at read time, not stored.

### 5.3 Stock

#### `stock_units`

One row per serialized physical unit.

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `product_id` | uuid | FK → products |
| `location_id` | uuid | FK → locations |
| `imei` | text | nullable |
| `iccid` | text | nullable |
| `msn_number` | text | nullable |
| `activation_code` | text | nullable |
| `vendor` | text | nullable |
| `status` | stock_unit_status | not null, default `draft` |

#### `inventory_levels`

Stock level for quantity-counted goods.

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `product_id` | uuid | FK → products |
| `location_id` | uuid | FK → locations |
| `quantity` | integer | not null, default 0, check >= 0 |
| | | unique `(product_id, location_id)` |

### 5.4 Physical inventory

#### `physical_inventory_counts`

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `product_id` | uuid | FK → products |
| `location_id` | uuid | FK → locations, nullable |
| `on_hand` | integer | not null (snapshot at count creation) |
| `counted` | integer | nullable (null until a count is entered) |
| `status` | count_status | not null, default `pending_count` |

Note: the UI currently only has `pending_count` and `pending_approval`; `completed` is added for the state after an adjustment is approved or rejected, so finished counts leave the pending list.

#### `count_adjustments`

One row per adjustment request; rows double as the History timeline.

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `count_id` | uuid | FK → physical_inventory_counts, cascade delete |
| `requested_quantity` | integer | not null |
| `reason` | text | not null |
| `status` | adjustment_status | not null, default `pending` |
| `reviewed_by` | text | nullable (plain text until auth exists) |
| `reviewed_at` | timestamptz | nullable |

### 5.5 Operations

Delivery orders and receipts are mirrored structures.

#### `delivery_orders` / `receipts`

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `reference` | text | not null, unique |
| `warehouse_ref` | text | not null (e.g. `#WH/OUT/2026/0042`) |
| `destination` | text | not null |
| `source_location_id` | uuid | FK → locations |
| `operation_type` | text | not null |
| `shipping_policy` | text | **delivery_orders only** |
| `notes` | text | **receipts only**, nullable |
| `schedule_date` | date | not null |
| `scheduled_at` | timestamptz | nullable |
| `status` | order_status | not null, default `draft` |
| `workflow_status` | order_workflow_status | nullable |

#### `delivery_order_lines` / `receipt_lines`

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `order_id` / `receipt_id` | uuid | FK → parent, cascade delete |
| `product_id` | uuid | FK → products |
| `demand` | integer | not null, check > 0 |

#### `delivery_order_quantity_lines` / `receipt_quantity_lines`

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `order_id` / `receipt_id` | uuid | FK → parent, cascade delete |
| `product_id` | uuid | FK → products |
| `lot_serial` | text | not null, default `'N/A'` |
| `demand` | integer | not null |
| `quantity` | integer | not null, default 0 |

### 5.6 Configuration

#### `custom_fields`

| Column | Type | Constraints |
|---|---|---|
| `id` | uuid | PK |
| `label` | text | not null |
| `field_type` | custom_field_type | not null |
| `field_location` | text | not null (e.g. "Product Activation") |
| `section` | text | not null (e.g. "Add Product Quantity Modal") |
| `required` | boolean | not null, default false |
| `visible` | boolean | not null, default true |
| `description` | text | nullable |
| `conditional_visibility` | jsonb | nullable; array of `{ "field": string, "operator": string, "value": string }` rules |

## 6. Table Count Summary

- 5 lookup tables: `categories`, `companies`, `platforms`, `pricing_plans`, `locations`
- 15 domain tables: `products`, `product_pricing`, `bundle_components`, `bundle_items`, `stock_units`, `inventory_levels`, `physical_inventory_counts`, `count_adjustments`, `delivery_orders`, `delivery_order_lines`, `delivery_order_quantity_lines`, `receipts`, `receipt_lines`, `receipt_quantity_lines`, `custom_fields`
- 11 enum types

## 7. Mapping Notes (mock data → schema)

| Current mock shape | Schema treatment |
|---|---|
| `Product.category` / `company` / `platform` as strings | FKs to lookup tables |
| `ProductPricing.monthlyFee` as `"¥20.000 JYP"` strings | `numeric(12,0)`; formatting is a UI concern |
| `ProductBundle.totalQuantity` stored | Computed from `bundle_items.quantity` at read time |
| `ProductBundleItem.name`/`sku` strings | FK to `products` |
| `ProductQuantityItem` (IMEI/ICCID rows) | `stock_units` |
| `InventoryItem.stock` per location | `inventory_levels` |
| `DeliveryOrder.products` / `quantityItems` inline arrays | `*_lines` / `*_quantity_lines` tables |
| `CustomField.conditionalVisibility` array | JSONB column |

## 8. Out of Scope

- Authentication / `users` table (`reviewed_by` remains text until auth lands)
- Template-page entities: customers, mails, members, notifications
- ORM choice, migrations, and wiring API endpoints to the database (future specs)
