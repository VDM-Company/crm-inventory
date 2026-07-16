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
