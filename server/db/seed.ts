import { sql } from 'drizzle-orm'
import { client, db } from './index'
import {
  bundleComponents,
  bundleItems,
  categories,
  companies,
  countAdjustments,
  customFields,
  deliveryOrderLines,
  deliveryOrderQuantityLines,
  deliveryOrders,
  inventoryLevels,
  locations,
  physicalInventoryCounts,
  platforms,
  pricingPlans,
  products,
  productPricing,
  receiptLines,
  receipts,
  stockUnits
} from './schema'

async function seed() {
  await db.execute(sql`
    TRUNCATE TABLE
      count_adjustments, physical_inventory_counts,
      delivery_order_quantity_lines, delivery_order_lines, delivery_orders,
      receipt_quantity_lines, receipt_lines, receipts,
      inventory_levels, stock_units,
      bundle_items, bundle_components, product_pricing, products,
      custom_fields, categories, companies, platforms, pricing_plans, locations
    RESTART IDENTITY CASCADE
  `)

  const [wifi, smartphones, tablets, simCards, devices] = await db.insert(categories).values([
    { name: 'WIFI' },
    { name: 'Smartphones' },
    { name: 'Tablets' },
    { name: 'SIM Cards' },
    { name: 'Devices' }
  ]).returning()

  const [vdm, vds] = await db.insert(companies).values([
    { name: 'VDM' },
    { name: 'VDS' }
  ]).returning()

  const [sk] = await db.insert(platforms).values([
    { name: 'SK' },
    { name: 'Docomo' },
    { name: 'Softbank' }
  ]).returning()

  const [skSimPlan] = await db.insert(pricingPlans).values([
    { name: 'SK SIM Plan' },
    { name: 'VDM Data Plan' }
  ]).returning()

  const [whStock] = await db.insert(locations).values([
    { name: 'WH/Stock' },
    { name: 'Partner/Customer' }
  ]).returning()

  const [wifiProduct, necDevice, x4Device, docomo1gb, softbank1gb] = await db.insert(products).values([
    {
      name: 'internet Wifi 10GB',
      sku: 'WIFI-001',
      reference: '220041515125',
      productType: 'bundling',
      status: 'active',
      trackedBy: 'unique_serial_number',
      categoryId: wifi!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'Nec Device',
      sku: 'nec_device_sku',
      reference: '220041515126',
      productType: 'single',
      status: 'active',
      trackedBy: 'unique_serial_number',
      categoryId: devices!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'X4 Device',
      sku: 'x4_device_sku',
      reference: '220041515127',
      productType: 'single',
      status: 'active',
      trackedBy: 'unique_serial_number',
      categoryId: devices!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'Docomo 1GB',
      sku: 'd_1gb_device_sku',
      reference: '220041515128',
      productType: 'single',
      status: 'active',
      trackedBy: 'batch_number',
      categoryId: simCards!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'Softbank 1GB',
      sku: 's_1gb_device_sku',
      reference: '220041515129',
      productType: 'single',
      status: 'active',
      trackedBy: 'batch_number',
      categoryId: simCards!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'SIM CARD 001',
      sku: 'SIM-002',
      reference: '002415515617',
      productType: 'single',
      status: 'active',
      trackedBy: 'unique_serial_number',
      categoryId: smartphones!.id,
      companyId: vds!.id,
      platformId: sk!.id,
      published: true,
      trackInventory: true
    },
    {
      name: 'SIM CARD 002',
      sku: 'SIM-003',
      reference: '002415515618',
      productType: 'dual',
      status: 'inactive',
      trackedBy: 'lot',
      categoryId: tablets!.id,
      companyId: vdm!.id,
      platformId: sk!.id,
      published: false,
      trackInventory: false
    }
  ]).returning()

  await db.insert(productPricing).values([
    {
      productId: wifiProduct!.id,
      priceVersion: 'V.1',
      pricingPlanId: skSimPlan!.id,
      pricingType: 'subscription',
      monthlyFee: '20000',
      initialFee: '1000',
      depositFee: '1000',
      isActive: false,
      statusSince: '2026-04-24',
      activationMethod: 'immediate'
    },
    {
      productId: wifiProduct!.id,
      priceVersion: 'V.2',
      pricingPlanId: skSimPlan!.id,
      pricingType: 'subscription',
      monthlyFee: '20000',
      initialFee: '1000',
      depositFee: '1000',
      isActive: true,
      statusSince: '2026-04-24',
      activationMethod: 'scheduled',
      activationStartDate: '2026-06-01'
    }
  ])

  const [deviceComponent, simComponent] = await db.insert(bundleComponents).values([
    { productId: wifiProduct!.id, name: 'Device Component', required: false, position: 0 },
    { productId: wifiProduct!.id, name: 'SIM Card Component', required: true, position: 1 }
  ]).returning()

  await db.insert(bundleItems).values([
    { componentId: deviceComponent!.id, productId: necDevice!.id, quantity: 5 },
    { componentId: deviceComponent!.id, productId: x4Device!.id, quantity: 6 },
    { componentId: simComponent!.id, productId: docomo1gb!.id, quantity: 2 },
    { componentId: simComponent!.id, productId: softbank1gb!.id, quantity: 3 }
  ])

  await db.insert(stockUnits).values(Array.from({ length: 10 }, (_, i) => ({
    productId: wifiProduct!.id,
    locationId: whStock!.id,
    imei: String(2415515616 + i * 1000).padStart(12, '0'),
    iccid: String(245151616166 + i * 1000),
    msnNumber: String(81256677899 + i).padStart(12, '0'),
    activationCode: String(99921566 + i),
    vendor: ['VDM', 'VDN', 'VDO'][i % 3],
    status: 'ready' as const
  })))

  await db.insert(inventoryLevels).values([
    { productId: docomo1gb!.id, locationId: whStock!.id, quantity: 120 },
    { productId: softbank1gb!.id, locationId: whStock!.id, quantity: 80 }
  ])

  const [count] = await db.insert(physicalInventoryCounts).values([
    { productId: docomo1gb!.id, locationId: whStock!.id, onHand: 120, counted: 118, status: 'pending_approval' },
    { productId: softbank1gb!.id, locationId: whStock!.id, onHand: 80, status: 'pending_count' }
  ]).returning()

  await db.insert(countAdjustments).values([
    { countId: count!.id, requestedQuantity: 118, reason: 'Damaged during transport', status: 'pending' }
  ])

  const [order] = await db.insert(deliveryOrders).values([
    {
      reference: '001-224-241',
      warehouseRef: '#WH/OUT/2026/0042',
      destination: 'Partner/Customer',
      sourceLocationId: whStock!.id,
      operationType: 'Delivery Orders',
      shippingPolicy: 'When products are ready',
      scheduleDate: '2026-03-17',
      scheduledAt: new Date('2026-03-20T00:00:00Z'),
      status: 'draft',
      workflowStatus: 'waiting'
    }
  ]).returning()

  await db.insert(deliveryOrderLines).values([
    { orderId: order!.id, productId: docomo1gb!.id, demand: 50 }
  ])

  await db.insert(deliveryOrderQuantityLines).values([
    { orderId: order!.id, productId: docomo1gb!.id, lotSerial: 'N/A', demand: 50, quantity: 50 }
  ])

  const [receipt] = await db.insert(receipts).values([
    {
      reference: 'RCP-001-224',
      warehouseRef: '#WH/IN/2026/0042',
      destination: 'WH/Stock',
      sourceLocationId: whStock!.id,
      operationType: 'Receipts',
      scheduleDate: '2026-03-15',
      status: 'pending',
      workflowStatus: 'ready'
    }
  ]).returning()

  await db.insert(receiptLines).values([
    { receiptId: receipt!.id, productId: softbank1gb!.id, demand: 100 }
  ])

  await db.insert(customFields).values([
    { label: 'Activation Code', fieldType: 'text', fieldLocation: 'Product Activation', section: 'Add Product Quantity Modal', required: false, visible: true },
    { label: 'Batch Expiry', fieldType: 'date', fieldLocation: 'Delivery', section: 'Add Delivery', required: false, visible: true },
    { label: 'ICCID', fieldType: 'number', fieldLocation: 'Product Activation', section: 'Add Product Quantity Modal', required: false, visible: true },
    { label: 'Product Category', fieldType: 'dropdown', fieldLocation: 'Product Activation', section: 'Add Product Quantity Modal', required: false, visible: true }
  ])

  console.log('Seed complete')
}

seed()
  .catch((error) => {
    console.error(error)
    process.exitCode = 1
  })
  .finally(() => client.end())
