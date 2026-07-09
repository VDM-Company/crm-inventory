import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'
import * as schema from './schema'

const connectionString = process.env.DATABASE_URL ?? 'postgres://crm:crm@localhost:5432/crm_inventory'

export const client = postgres(connectionString)
export const db = drizzle(client, { schema })
