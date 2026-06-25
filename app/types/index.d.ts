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
