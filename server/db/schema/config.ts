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
