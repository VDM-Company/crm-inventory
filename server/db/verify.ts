import { count, eq } from 'drizzle-orm'
import { client, db } from './index'
import { bundleComponents, bundleItems, categories, customFields, deliveryOrderLines, inventoryLevels, products, productPricing, stockUnits } from './schema'

function assert(condition: boolean, message: string) {
  if (!condition) {
    throw new Error(`Verification failed: ${message}`)
  }
}

async function verify() {
  const [productCount] = await db.select({ value: count() }).from(products)
  assert((productCount?.value ?? 0) === 7, `expected 7 products, got ${productCount?.value}`)

  const [categoryCount] = await db.select({ value: count() }).from(categories)
  assert((categoryCount?.value ?? 0) === 5, `expected 5 categories, got ${categoryCount?.value}`)

  const wifi = await db.query.products.findFirst({ where: eq(products.sku, 'WIFI-001') })
  assert(wifi !== undefined, 'WIFI-001 product missing')
  assert(wifi!.productType === 'bundling', 'WIFI-001 should be a bundling product')

  const pricingRows = await db.select().from(productPricing).where(eq(productPricing.productId, wifi!.id))
  assert(pricingRows.length === 2, `expected 2 pricing versions, got ${pricingRows.length}`)
  assert(pricingRows.some(row => row.activationStartDate === '2026-06-01'), 'scheduled pricing should have start date')

  const [bundleItemCount] = await db.select({ value: count() }).from(bundleItems)
  assert((bundleItemCount?.value ?? 0) === 4, `expected 4 bundle items, got ${bundleItemCount?.value}`)

  const [unitCount] = await db.select({ value: count() }).from(stockUnits)
  assert((unitCount?.value ?? 0) === 10, `expected 10 stock units, got ${unitCount?.value}`)

  const [levelCount] = await db.select({ value: count() }).from(inventoryLevels)
  assert((levelCount?.value ?? 0) === 2, `expected 2 inventory levels, got ${levelCount?.value}`)

  const [lineCount] = await db.select({ value: count() }).from(deliveryOrderLines)
  assert((lineCount?.value ?? 0) === 1, `expected 1 delivery order line, got ${lineCount?.value}`)

  const [fieldCount] = await db.select({ value: count() }).from(customFields)
  assert((fieldCount?.value ?? 0) === 4, `expected 4 custom fields, got ${fieldCount?.value}`)

  const component = await db.select().from(bundleComponents).limit(1)
  assert(component.length === 1, 'expected at least one bundle component')

  let constraintHeld = false
  try {
    await db.insert(bundleItems).values({
      componentId: component[0]!.id,
      productId: wifi!.id,
      quantity: 0
    })
  } catch {
    constraintHeld = true
  }
  assert(constraintHeld, 'bundle_items quantity > 0 check should reject quantity 0')

  console.log('All verifications passed')
}

verify()
  .catch((error) => {
    console.error(error)
    process.exitCode = 1
  })
  .finally(() => client.end())
