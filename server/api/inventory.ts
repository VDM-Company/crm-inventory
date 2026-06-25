import type { InventoryItem, InventoryCategory } from '~/types'

const blueprint: Array<Pick<InventoryItem, 'productName' | 'category' | 'trackedBy'>> = [
  { productName: 'iPhone 14 Pro (Silver)', category: 'Devices', trackedBy: 'Unique Serial Number' },
  { productName: 'Galaxy S23 Ultra', category: 'Devices', trackedBy: 'Unique Serial Number' },
  { productName: 'iPad Air 5', category: 'Devices', trackedBy: 'Unique Serial Number' },
  { productName: 'AirPods Pro (2nd Gen)', category: 'Devices', trackedBy: 'Unique Serial Number' },
  { productName: 'Pixel Watch 2', category: 'Devices', trackedBy: 'Unique Serial Number' },
  { productName: 'Docomo SIM Card', category: 'SIM', trackedBy: 'Batch Number' },
  { productName: '5G SIM Pack', category: 'SIM', trackedBy: 'Batch Number' },
  { productName: 'eSIM Activation Code', category: 'SIM', trackedBy: 'Unique Serial Number' },
  { productName: 'Prepaid Data SIM', category: 'SIM', trackedBy: 'Batch Number' },
  { productName: 'Branded Tote Bag', category: 'Gifts', trackedBy: 'Quantity Count' },
  { productName: 'Gift Card ¥5,000', category: 'Gifts', trackedBy: 'Unique Serial Number' },
  { productName: 'Welcome Kit Box', category: 'Gifts', trackedBy: 'Quantity Count' },
  { productName: 'USB-C Cable (2m)', category: 'Supply', trackedBy: 'Quantity Count' },
  { productName: 'Power Bank 10,000mAh', category: 'Supply', trackedBy: 'Quantity Count' },
  { productName: 'Screen Protector', category: 'Supply', trackedBy: 'Quantity Count' },
  { productName: 'Phone Case (Clear)', category: 'Supply', trackedBy: 'Quantity Count' }
]

const locations = [
  'SIM Cards',
  'Smartphones',
  'Internet Plan',
  'Laptops',
  'Cloud Storage',
  'Wearables',
  'Mobile Insurance',
  'Accessories',
  'System Update'
]

const items: InventoryItem[] = Array.from({ length: 48 }, (_, i) => {
  const base = blueprint[i % blueprint.length] as Pick<InventoryItem, 'productName' | 'category' | 'trackedBy'>

  return {
    id: (i + 1).toString(),
    productName: base.productName,
    sku: (2415515616 + i).toString().padStart(12, '0'),
    location: locations[i % locations.length] as string,
    stock: ((i * 37) % 190) + 10,
    trackedBy: base.trackedBy,
    category: base.category as InventoryCategory,
    status: i % 9 === 0 ? 'inactive' : 'active'
  }
})

export default eventHandler(async () => {
  return items
})
