import type { DeliveryOrder, DeliveryOrderListItem } from '~/types'

export const deliveryOrders: DeliveryOrder[] = [{
  id: '1',
  reference: '001-224-241',
  destination: 'Partner/Customer',
  scheduleDate: '17-03-2026',
  status: 'Draft',
  warehouseRef: '#WH/OUT/2026/0042',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'When products are ready',
  scheduleAt: '2026-03-20',
  workflowStatus: 'Waiting',
  products: [{
    productName: 'Docomo SIM CARD 50GB',
    demand: 50,
    productCategory: 'SIM Card',
    productStatus: 'Ready'
  }],
  quantityItems: [{
    id: '1',
    productName: 'Docomo SIM CARD 50GB',
    lotSerial: 'N/A',
    demand: 50,
    quantity: 50,
    stock: 120
  }]
}, {
  id: '2',
  reference: '003-456-789',
  destination: 'Tokyo Central',
  scheduleDate: '20-04-2026',
  status: 'Draft',
  warehouseRef: '#WH/OUT/2026/0043',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'When products are ready',
  products: []
}, {
  id: '3',
  reference: '004-123-456',
  destination: 'Osaka Branch',
  scheduleDate: '22-05-2026',
  status: 'Draft',
  warehouseRef: '#WH/OUT/2026/0044',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'As soon as possible',
  products: []
}, {
  id: '4',
  reference: '005-789-012',
  destination: 'Kyoto District',
  scheduleDate: '15-06-2026',
  status: 'Pending',
  warehouseRef: '#WH/OUT/2026/0045',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'When products are ready',
  products: []
}, {
  id: '5',
  reference: '006-234-567',
  destination: 'Nagoya Office',
  scheduleDate: '28-07-2026',
  status: 'Draft',
  warehouseRef: '#WH/OUT/2026/0046',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'When products are ready',
  products: []
}, {
  id: '6',
  reference: '007-890-123',
  destination: 'Fukuoka Station',
  scheduleDate: '30-08-2026',
  status: 'Pending',
  warehouseRef: '#WH/OUT/2026/0047',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'When products are ready',
  products: []
}, {
  id: '7',
  reference: '008-345-678',
  destination: 'Sapporo Hub',
  scheduleDate: '10-09-2026',
  status: 'On Delivery',
  warehouseRef: '#WH/OUT/2026/0048',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'When products are ready',
  products: []
}, {
  id: '8',
  reference: '009-678-901',
  destination: 'Hiroshima Base',
  scheduleDate: '05-10-2026',
  status: 'Delivered',
  warehouseRef: '#WH/OUT/2026/0049',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'When products are ready',
  products: []
}, {
  id: '9',
  reference: '010-234-890',
  destination: 'Sendai Office',
  scheduleDate: '25-11-2026',
  status: 'On Delivery',
  warehouseRef: '#WH/OUT/2026/0050',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'When products are ready',
  products: []
}, {
  id: '10',
  reference: '011-345-901',
  destination: 'Kobe Branch',
  scheduleDate: '12-12-2026',
  status: 'Delivered',
  warehouseRef: '#WH/OUT/2026/0051',
  sourceLocation: 'WH/Stock',
  operationType: 'Delivery Orders',
  shippingPolicy: 'When products are ready',
  products: []
}]

export function toListItem(order: DeliveryOrder): DeliveryOrderListItem {
  return {
    id: order.id,
    reference: order.reference,
    destination: order.destination,
    scheduleDate: order.scheduleDate,
    status: order.status
  }
}
