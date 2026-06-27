import type { AvatarProps } from '@nuxt/ui'

export type UserStatus = 'subscribed' | 'unsubscribed' | 'bounced'
export type SaleStatus = 'paid' | 'failed' | 'refunded'

export interface User {
  id: number
  name: string
  email: string
  avatar?: AvatarProps
  status: UserStatus
  location: string
}

export interface Mail {
  id: number
  unread?: boolean
  from: User
  subject: string
  body: string
  date: string
}

export interface Member {
  name: string
  username: string
  role: 'member' | 'owner'
  avatar: AvatarProps
}

export interface Stat {
  title: string
  icon: string
  value: number | string
  variation: number
  formatter?: (value: number) => string
}

export interface Sale {
  id: string
  date: string
  status: SaleStatus
  email: string
  amount: number
}

export interface Notification {
  id: number
  unread?: boolean
  sender: User
  body: string
  date: string
}

export type Period = 'daily' | 'weekly' | 'monthly'

export interface Range {
  start: Date
  end: Date
}

export type InventoryCategory = 'SIM' | 'Devices' | 'Gifts' | 'Supply'
export type InventoryStatus = 'active' | 'inactive'

export interface InventoryItem {
  id: string
  productName: string
  sku: string
  location: string
  stock: number
  trackedBy: string
  category: InventoryCategory
  status: InventoryStatus
}

export type MetricTrend = 'up' | 'down'

export interface InventoryMetric {
  title: string
  value: string
  variation: number
  trend: MetricTrend
  data: number[]
}

export interface LowStockItem {
  id: string
  name: string
  threshold: number
  current: number
}

export type IncomingStatus = 'in-transit' | 'processing' | 'scheduled'

export interface IncomingStockItem {
  id: string
  name: string
  threshold: number
  current: number
  date: string
  status: IncomingStatus
}

export type PhysicalInventoryCountStatus = 'pending-count' | 'matched' | 'discrepancy'

export interface PhysicalInventoryItem {
  id: string
  productName: string
  sku: string
  onHand: number
}

export type CustomFieldType = 'Text' | 'Date' | 'Number' | 'Dropdown'

export interface CustomFieldCondition {
  field: string
  operator: string
  value: string
}

export interface CustomField {
  id: string
  label: string
  fieldType: CustomFieldType
  fieldLocation: string
  section: string
  required: boolean
  visibility: boolean
  description?: string
  conditionalVisibility?: CustomFieldCondition[]
}

export type DeliveryOrderStatus = 'Draft' | 'Pending' | 'On Delivery' | 'Delivered'

export interface DeliveryOrderListItem {
  id: string
  reference: string
  destination: string
  scheduleDate: string
  status: DeliveryOrderStatus
}

export interface DeliveryOrderProduct {
  productName: string
  demand: number
  productCategory: string
  productStatus?: string
}

export type DeliveryOrderWorkflowStatus = 'Waiting' | 'Ready' | 'Draft'

export interface DeliveryOrderQuantityItem {
  id: string
  productName: string
  lotSerial: string
  demand: number
  quantity: number
  stock: number
}

export interface DeliveryOrder extends DeliveryOrderListItem {
  warehouseRef: string
  sourceLocation: string
  operationType: string
  shippingPolicy: string
  scheduleAt?: string
  workflowStatus?: DeliveryOrderWorkflowStatus
  products: DeliveryOrderProduct[]
  quantityItems?: DeliveryOrderQuantityItem[]
}

export type ReceiptStatus = DeliveryOrderStatus

export type ReceiptWorkflowStatus = DeliveryOrderWorkflowStatus

export interface ReceiptListItem {
  id: string
  reference: string
  destination: string
  scheduleDate: string
  status: ReceiptStatus
}

export interface ReceiptProduct {
  productName: string
  demand: number
  productCategory: string
  productStatus?: string
}

export interface ReceiptQuantityItem {
  id: string
  productName: string
  lotSerial: string
  demand: number
  quantity: number
  stock: number
}

export interface Receipt extends ReceiptListItem {
  warehouseRef: string
  sourceLocation: string
  operationType: string
  scheduleAt?: string
  notes?: string
  workflowStatus?: ReceiptWorkflowStatus
  products: ReceiptProduct[]
  quantityItems?: ReceiptQuantityItem[]
}

export type ProductStatus = 'Active' | 'Inactive'

export type ProductPricingStatus = 'Active' | 'Inactive'

export type ProductPricingType = 'Subscription' | 'One Time Payment'

export interface ProductListItem {
  id: string
  name: string
  reference: string
  category: string
  productType: string
  company: string
  trackedBy: string
  status: ProductStatus
}

export interface ProductPricing {
  id: string
  priceVersion: string
  monthlyFee: string
  initialFee: string
  status: ProductPricingStatus
  statusSince: string
  pricingType?: ProductPricingType
  pricingPlan?: string
  depositFee?: string
  activationMethod?: 'scheduled' | 'immediate'
  pricingActive?: boolean
}

export interface Product extends ProductListItem {
  sku: string
  notes?: string
  settingsCategory: string
  platform: string
  published: boolean
  trackInventory: boolean
  pricing: ProductPricing[]
  bundle?: ProductBundle
}

export interface ProductBundleItem {
  name: string
  sku: string
  quantity: number
}

export interface ProductBundleComponent {
  id: string
  name: string
  required?: boolean
  items: ProductBundleItem[]
}

export interface ProductBundle {
  totalQuantity: number
  components: ProductBundleComponent[]
}

export type ProductQuantityStatus = 'Ready' | 'Pending' | 'Draft'

export interface ProductQuantityItem {
  id: string
  location: string
  imei: string
  iccid: string
  msnNumber: string
  activationCode: string
  vendor: string
  status: ProductQuantityStatus
}
