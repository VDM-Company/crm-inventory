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
