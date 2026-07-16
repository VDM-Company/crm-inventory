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
