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
