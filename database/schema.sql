-- =============================================================================
-- CRM / Inventory Dashboard — PostgreSQL schema
-- =============================================================================
-- Generated from the current application data model:
--   - app/types/index.d.ts          (shared TypeScript types)
--   - server/api/*.ts                (Nitro mock endpoints)
--   - server/utils/*.ts              (mock datasets backing the endpoints)
--
-- The app currently has NO database (see AGENTS.md — "Notable Gaps"); all data
-- returned by server/api/* is in-memory mock data. This script turns that mock
-- data model into a real Postgres schema, plus seed data equivalent to what the
-- app returns today, so the two stay in sync.
--
-- Run with:
--   psql "postgresql://USER:PASSWORD@HOST:PORT/DBNAME" -f database/schema.sql
--
-- The script is safe to re-run on a fresh database. It is NOT idempotent
-- against a database that already has data in these tables (re-running will
-- fail on unique constraints / duplicate seed rows). Drop the tables first
-- (see bottom of file for a commented-out DROP block) if you need to reset.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- Extensions
-- -----------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- -----------------------------------------------------------------------------
-- ENUM types
-- -----------------------------------------------------------------------------
DO $$ BEGIN
  CREATE TYPE user_status AS ENUM ('subscribed', 'unsubscribed', 'bounced');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE member_role AS ENUM ('member', 'owner');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE inventory_category AS ENUM ('SIM', 'Devices', 'Gifts', 'Supply');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE inventory_status AS ENUM ('active', 'inactive');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE incoming_status AS ENUM ('in-transit', 'processing', 'scheduled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE sale_status AS ENUM ('paid', 'failed', 'refunded');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE custom_field_type AS ENUM ('Text', 'Date', 'Number', 'Dropdown');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE product_status AS ENUM ('Active', 'Inactive', 'Draft', 'Discontinued');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE product_pricing_status AS ENUM ('Active', 'Inactive');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE product_pricing_type AS ENUM ('Subscription', 'One Time Payment');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE product_pricing_activation_method AS ENUM ('scheduled', 'immediate');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE product_quantity_status AS ENUM ('Ready', 'Pending', 'Draft');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Shared by Delivery Orders and Receipts (DeliveryOrderStatus / ReceiptStatus)
DO $$ BEGIN
  CREATE TYPE document_status AS ENUM ('Draft', 'Pending', 'On Delivery', 'Delivered');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Shared by Delivery Orders and Receipts (DeliveryOrderWorkflowStatus / ReceiptWorkflowStatus)
DO $$ BEGIN
  CREATE TYPE document_workflow_status AS ENUM ('Waiting', 'Ready', 'Draft');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- -----------------------------------------------------------------------------
-- Helper: keep updated_at fresh
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- 1. USERS  (customers — app/types User, server/api/customers.ts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS users (
  id          BIGSERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  avatar_url  TEXT,
  status      user_status NOT NULL DEFAULT 'subscribed',
  location    TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_users_updated_at ON users;
CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- =============================================================================
-- 2. MEMBERS  (team members, server/api/members.ts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS members (
  id          BIGSERIAL PRIMARY KEY,
  name        TEXT NOT NULL,
  username    TEXT NOT NULL UNIQUE,
  role        member_role NOT NULL DEFAULT 'member',
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================================================
-- 3. MAILS  (server/api/mails.ts)
-- -----------------------------------------------------------------------------
-- `from` in the mock is an embedded (partial) User, not a foreign key, so
-- sender fields are denormalized here to match the app's current shape.
-- =============================================================================
CREATE TABLE IF NOT EXISTS mails (
  id                  BIGSERIAL PRIMARY KEY,
  unread              BOOLEAN NOT NULL DEFAULT false,
  sender_name         TEXT NOT NULL,
  sender_email        TEXT,
  sender_avatar_url   TEXT,
  subject             TEXT NOT NULL,
  body                TEXT NOT NULL,
  sent_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_mails_sent_at ON mails(sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_mails_unread ON mails(unread) WHERE unread;

-- =============================================================================
-- 4. NOTIFICATIONS  (server/api/notifications.ts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS notifications (
  id                  BIGSERIAL PRIMARY KEY,
  unread              BOOLEAN NOT NULL DEFAULT false,
  sender_name         TEXT NOT NULL,
  sender_email        TEXT,
  sender_avatar_url   TEXT,
  body                TEXT NOT NULL,
  sent_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_sent_at ON notifications(sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(unread) WHERE unread;

-- =============================================================================
-- 5. INVENTORY ITEMS  (server/api/inventory.ts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS inventory_items (
  id            BIGSERIAL PRIMARY KEY,
  product_name  TEXT NOT NULL,
  sku           TEXT NOT NULL UNIQUE,
  location      TEXT NOT NULL,
  stock         INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  tracked_by    TEXT NOT NULL,
  category      inventory_category NOT NULL,
  status        inventory_status NOT NULL DEFAULT 'active',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_inventory_items_updated_at ON inventory_items;
CREATE TRIGGER trg_inventory_items_updated_at BEFORE UPDATE ON inventory_items
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_inventory_items_category ON inventory_items(category);
CREATE INDEX IF NOT EXISTS idx_inventory_items_status ON inventory_items(status);

-- =============================================================================
-- 6. PHYSICAL INVENTORY ITEMS  (server/api/physical-inventory.ts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS physical_inventory_items (
  id            BIGSERIAL PRIMARY KEY,
  product_name  TEXT NOT NULL,
  sku           TEXT NOT NULL UNIQUE,
  on_hand       INTEGER NOT NULL DEFAULT 0 CHECK (on_hand >= 0),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================================================
-- 7-9. DASHBOARD WIDGET TABLES
-- -----------------------------------------------------------------------------
-- LowStockItem / IncomingStockItem / Sale currently only exist as client-side
-- mock arrays (app/components/dashboard/LowStock.vue, Incoming.vue and
-- app/components/home/HomeSales.vue — the latter randomly generated on every
-- load). They are modeled here because the types are part of app/types, but
-- there is no server/api route backing them yet.
-- =============================================================================
CREATE TABLE IF NOT EXISTS low_stock_items (
  id              BIGSERIAL PRIMARY KEY,
  name            TEXT NOT NULL,
  threshold       INTEGER NOT NULL,
  current_stock   INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS incoming_stock_items (
  id              BIGSERIAL PRIMARY KEY,
  name            TEXT NOT NULL,
  threshold       INTEGER NOT NULL,
  current_stock   INTEGER NOT NULL,
  expected_date   DATE NOT NULL,
  status          incoming_status NOT NULL
);

CREATE TABLE IF NOT EXISTS sales (
  id              BIGSERIAL PRIMARY KEY,
  sold_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  status          sale_status NOT NULL,
  customer_email  TEXT,
  amount          NUMERIC(12, 2) NOT NULL CHECK (amount >= 0)
);

CREATE INDEX IF NOT EXISTS idx_sales_sold_at ON sales(sold_at DESC);

-- =============================================================================
-- 10. CUSTOM FIELDS  (server/api/fields.ts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS custom_fields (
  id              BIGSERIAL PRIMARY KEY,
  label           TEXT NOT NULL,
  field_type      custom_field_type NOT NULL,
  field_location  TEXT NOT NULL,
  section         TEXT NOT NULL,
  required        BOOLEAN NOT NULL DEFAULT false,
  visibility      BOOLEAN NOT NULL DEFAULT true,
  description     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- CustomFieldCondition[] (conditionalVisibility)
CREATE TABLE IF NOT EXISTS custom_field_conditions (
  id              BIGSERIAL PRIMARY KEY,
  custom_field_id BIGINT NOT NULL REFERENCES custom_fields(id) ON DELETE CASCADE,
  field           TEXT NOT NULL,
  operator        TEXT NOT NULL,
  value           TEXT NOT NULL,
  position        INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_custom_field_conditions_field_id ON custom_field_conditions(custom_field_id);

-- =============================================================================
-- 11. PRODUCTS  (server/api/products.ts, server/utils/productsData.ts,
--                server/utils/productQuantitiesData.ts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS products (
  id                  BIGSERIAL PRIMARY KEY,
  name                TEXT NOT NULL,
  reference           TEXT NOT NULL UNIQUE,
  category            TEXT NOT NULL,
  product_type        TEXT NOT NULL,
  company             TEXT NOT NULL,
  tracked_by          TEXT NOT NULL,
  status              product_status NOT NULL DEFAULT 'Active',
  sku                 TEXT NOT NULL UNIQUE,
  notes               TEXT,
  settings_category   TEXT NOT NULL,
  platform            TEXT NOT NULL,
  published           BOOLEAN NOT NULL DEFAULT false,
  track_inventory     BOOLEAN NOT NULL DEFAULT true,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);

-- ProductPricing[] — note: monthly_fee / initial_fee / deposit_fee / status_since
-- are kept as TEXT to match the current mock data, which stores pre-formatted
-- display strings (e.g. "¥20.000 JYP", "Since Apr 24, 2026") rather than
-- structured numeric/currency or date values.
CREATE TABLE IF NOT EXISTS product_pricing (
  id                      BIGSERIAL PRIMARY KEY,
  product_id              BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  price_version           TEXT NOT NULL,
  monthly_fee             TEXT NOT NULL,
  initial_fee             TEXT NOT NULL,
  status                  product_pricing_status NOT NULL DEFAULT 'Active',
  status_since            TEXT NOT NULL,
  pricing_type            product_pricing_type,
  pricing_plan            TEXT,
  deposit_fee             TEXT,
  activation_method       product_pricing_activation_method,
  activation_start_date   DATE,
  pricing_active          BOOLEAN,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_product_pricing_product_id ON product_pricing(product_id);

-- ProductBundle (1:1 with a product)
CREATE TABLE IF NOT EXISTS product_bundles (
  id              BIGSERIAL PRIMARY KEY,
  product_id      BIGINT NOT NULL UNIQUE REFERENCES products(id) ON DELETE CASCADE,
  total_quantity  INTEGER NOT NULL DEFAULT 0
);

-- ProductBundleComponent[]
CREATE TABLE IF NOT EXISTS product_bundle_components (
  id              BIGSERIAL PRIMARY KEY,
  bundle_id       BIGINT NOT NULL REFERENCES product_bundles(id) ON DELETE CASCADE,
  component_key   TEXT NOT NULL,
  name            TEXT NOT NULL,
  required        BOOLEAN NOT NULL DEFAULT false,
  position        INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_product_bundle_components_bundle_id ON product_bundle_components(bundle_id);

-- ProductBundleItem[]
CREATE TABLE IF NOT EXISTS product_bundle_items (
  id              BIGSERIAL PRIMARY KEY,
  component_id    BIGINT NOT NULL REFERENCES product_bundle_components(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  sku             TEXT NOT NULL,
  quantity        INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0)
);

CREATE INDEX IF NOT EXISTS idx_product_bundle_items_component_id ON product_bundle_items(component_id);

-- ProductQuantityItem[] (server/api/products/[id]/quantities.ts)
CREATE TABLE IF NOT EXISTS product_quantity_items (
  id                BIGSERIAL PRIMARY KEY,
  product_id        BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  location          TEXT NOT NULL,
  imei              TEXT,
  iccid             TEXT,
  msn_number        TEXT,
  activation_code   TEXT,
  vendor            TEXT,
  status            product_quantity_status NOT NULL DEFAULT 'Ready'
);

CREATE INDEX IF NOT EXISTS idx_product_quantity_items_product_id ON product_quantity_items(product_id);

-- =============================================================================
-- 12. DELIVERY ORDERS  (server/api/delivery-orders*.ts, deliveryOrdersData.ts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS delivery_orders (
  id                BIGSERIAL PRIMARY KEY,
  reference         TEXT NOT NULL UNIQUE,
  destination       TEXT NOT NULL,
  schedule_date     DATE NOT NULL,
  status            document_status NOT NULL DEFAULT 'Draft',
  warehouse_ref     TEXT NOT NULL,
  source_location   TEXT NOT NULL,
  operation_type    TEXT NOT NULL,
  shipping_policy   TEXT NOT NULL,
  schedule_at       DATE,
  workflow_status   document_workflow_status,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_delivery_orders_updated_at ON delivery_orders;
CREATE TRIGGER trg_delivery_orders_updated_at BEFORE UPDATE ON delivery_orders
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_delivery_orders_status ON delivery_orders(status);

-- DeliveryOrderProduct[]
CREATE TABLE IF NOT EXISTS delivery_order_products (
  id                  BIGSERIAL PRIMARY KEY,
  delivery_order_id   BIGINT NOT NULL REFERENCES delivery_orders(id) ON DELETE CASCADE,
  product_name        TEXT NOT NULL,
  demand              INTEGER NOT NULL DEFAULT 0,
  product_category    TEXT NOT NULL,
  product_status      TEXT
);

CREATE INDEX IF NOT EXISTS idx_delivery_order_products_order_id ON delivery_order_products(delivery_order_id);

-- DeliveryOrderQuantityItem[]
CREATE TABLE IF NOT EXISTS delivery_order_quantity_items (
  id                  BIGSERIAL PRIMARY KEY,
  delivery_order_id   BIGINT NOT NULL REFERENCES delivery_orders(id) ON DELETE CASCADE,
  product_name        TEXT NOT NULL,
  lot_serial          TEXT,
  demand              INTEGER NOT NULL DEFAULT 0,
  quantity            INTEGER NOT NULL DEFAULT 0,
  stock               INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_delivery_order_quantity_items_order_id ON delivery_order_quantity_items(delivery_order_id);

-- =============================================================================
-- 13. RECEIPTS  (server/api/receipts*.ts, receiptsData.ts)
-- =============================================================================
CREATE TABLE IF NOT EXISTS receipts (
  id                BIGSERIAL PRIMARY KEY,
  reference         TEXT NOT NULL UNIQUE,
  destination       TEXT NOT NULL,
  schedule_date     DATE NOT NULL,
  status            document_status NOT NULL DEFAULT 'Draft',
  warehouse_ref     TEXT NOT NULL,
  source_location   TEXT NOT NULL,
  operation_type    TEXT NOT NULL,
  schedule_at       DATE,
  notes             TEXT,
  workflow_status   document_workflow_status,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_receipts_updated_at ON receipts;
CREATE TRIGGER trg_receipts_updated_at BEFORE UPDATE ON receipts
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_receipts_status ON receipts(status);

-- ReceiptProduct[]
CREATE TABLE IF NOT EXISTS receipt_products (
  id                BIGSERIAL PRIMARY KEY,
  receipt_id        BIGINT NOT NULL REFERENCES receipts(id) ON DELETE CASCADE,
  product_name      TEXT NOT NULL,
  demand            INTEGER NOT NULL DEFAULT 0,
  product_category  TEXT NOT NULL,
  product_status    TEXT
);

CREATE INDEX IF NOT EXISTS idx_receipt_products_receipt_id ON receipt_products(receipt_id);

-- ReceiptQuantityItem[]
CREATE TABLE IF NOT EXISTS receipt_quantity_items (
  id                BIGSERIAL PRIMARY KEY,
  receipt_id        BIGINT NOT NULL REFERENCES receipts(id) ON DELETE CASCADE,
  product_name      TEXT NOT NULL,
  lot_serial        TEXT,
  demand            INTEGER NOT NULL DEFAULT 0,
  quantity          INTEGER NOT NULL DEFAULT 0,
  stock             INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_receipt_quantity_items_receipt_id ON receipt_quantity_items(receipt_id);

COMMIT;
