import type { PhysicalInventoryItem } from '~/types'

const items: PhysicalInventoryItem[] = [{
  id: '1',
  productName: 'Akari LED Panel 60x60',
  sku: 'AKR-001',
  onHand: 100
}, {
  id: '2',
  productName: 'Bamboo Desk Lamp',
  sku: 'BDL-002',
  onHand: 75
}, {
  id: '3',
  productName: 'Smart Wi-Fi Speaker',
  sku: 'SWS-003',
  onHand: 150
}, {
  id: '4',
  productName: 'Ergonomic Office Chair',
  sku: 'EOC-004',
  onHand: 200
}, {
  id: '5',
  productName: 'Wireless Charging Pad',
  sku: 'WCP-005',
  onHand: 30
}, {
  id: '6',
  productName: 'Adjustable Laptop Stand',
  sku: 'ALS-006',
  onHand: 50
}, {
  id: '7',
  productName: 'Noise-Canceling Headphones',
  sku: 'NCH-007',
  onHand: 90
}, {
  id: '8',
  productName: 'Portable Bluetooth Projector',
  sku: 'PBP-008',
  onHand: 120
}, {
  id: '9',
  productName: 'Digital Smart Thermostat',
  sku: 'DST-009',
  onHand: 130
}, {
  id: '10',
  productName: 'Compact Air Purifier',
  sku: 'CAP-010',
  onHand: 60
}, {
  id: '11',
  productName: 'LED Ring Light',
  sku: 'LRL-011',
  onHand: 110
}]

export default eventHandler(async () => {
  return items
})
