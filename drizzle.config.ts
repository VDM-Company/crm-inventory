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
