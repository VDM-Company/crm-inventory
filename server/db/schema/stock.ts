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
