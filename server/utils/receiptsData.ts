import type { Receipt, ReceiptListItem } from '~/types'

export const receipts: Receipt[] = [{
  id: '1',
  reference: '001-224-241',
  destination: 'Partner/Customer',
  scheduleDate: '17-03-2026',
  status: 'Draft',
  warehouseRef: '#WH/IN/2026/0042',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  scheduleAt: '2026-03-20',
  notes: 'Receipt of the first batch of NX-7200 series routers for the Q2 network rollout. Ensure that the serial numbers are checked against PO-2026-0312. Coordinate with the QC team before the equipment is moved to the racks.',
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
  reference: '002-334-512',
  destination: 'Tokyo Warehouse',
  scheduleDate: '20-04-2026',
  status: 'Draft',
  warehouseRef: '#WH/IN/2026/0043',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  products: []
}, {
  id: '3',
  reference: '003-445-623',
  destination: 'Osaka Branch',
  scheduleDate: '22-05-2026',
  status: 'Pending',
  warehouseRef: '#WH/IN/2026/0044',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  products: []
}, {
  id: '4',
  reference: '004-556-734',
  destination: 'Kyoto District',
  scheduleDate: '15-06-2026',
  status: 'Draft',
  warehouseRef: '#WH/IN/2026/0045',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  products: []
}, {
  id: '5',
  reference: '005-667-845',
  destination: 'Nagoya Office',
  scheduleDate: '28-07-2026',
  status: 'Pending',
  warehouseRef: '#WH/IN/2026/0046',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  products: []
}, {
  id: '6',
  reference: '006-778-956',
  destination: 'Fukuoka Station',
  scheduleDate: '30-08-2026',
  status: 'On Delivery',
  warehouseRef: '#WH/IN/2026/0047',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  products: []
}, {
  id: '7',
  reference: '007-889-067',
  destination: 'Sapporo Hub',
  scheduleDate: '10-09-2026',
  status: 'On Delivery',
  warehouseRef: '#WH/IN/2026/0048',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  products: []
}, {
  id: '8',
  reference: '008-990-178',
  destination: 'Hiroshima Base',
  scheduleDate: '05-10-2026',
  status: 'Delivered',
  warehouseRef: '#WH/IN/2026/0049',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  products: []
}, {
  id: '9',
  reference: '009-101-289',
  destination: 'Sendai Office',
  scheduleDate: '25-11-2026',
  status: 'On Delivery',
  warehouseRef: '#WH/IN/2026/0050',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  products: []
}, {
  id: '10',
  reference: '010-212-390',
  destination: 'Kobe Branch',
  scheduleDate: '12-12-2026',
  status: 'Delivered',
  warehouseRef: '#WH/IN/2026/0051',
  sourceLocation: 'WH/Stock',
  operationType: 'Receipts',
  products: []
}]

export function toReceiptListItem(receipt: Receipt): ReceiptListItem {
  return {
    id: receipt.id,
    reference: receipt.reference,
    destination: receipt.destination,
    scheduleDate: receipt.scheduleDate,
    status: receipt.status
  }
}
