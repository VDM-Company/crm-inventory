<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'
import type { DeliveryOrderListItem, DeliveryOrderStatus } from '~/types'

const props = defineProps<{
  data: DeliveryOrderListItem[]
  loading?: boolean
}>()

const UBadge = resolveComponent('UBadge')
const UButton = resolveComponent('UButton')

const page = ref(1)
const pageSize = 10

const paged = computed(() => {
  const start = (page.value - 1) * pageSize
  return props.data.slice(start, start + pageSize)
})

const statusMap: Record<DeliveryOrderStatus, { label: string, color: 'neutral' | 'warning' | 'info' | 'primary' }> = {
  'Draft': { label: 'Draft', color: 'neutral' },
  'Pending': { label: 'Pending', color: 'warning' },
  'On Delivery': { label: 'On Delivery', color: 'info' },
  'Delivered': { label: 'Delivered', color: 'primary' }
}

const columns: TableColumn<DeliveryOrderListItem>[] = [{
  accessorKey: 'reference',
  header: 'Reference',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('reference'))
}, {
  accessorKey: 'destination',
  header: 'Destination',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('destination'))
}, {
  accessorKey: 'scheduleDate',
  header: 'Schedule Date',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('scheduleDate'))
}, {
  accessorKey: 'status',
  header: 'Status',
  cell: ({ row }) => {
    const status = row.getValue('status') as DeliveryOrderStatus
    const config = statusMap[status]

    return h(UBadge, {
      variant: 'subtle',
      color: config.color,
      class: 'text-xs'
    }, () => config.label)
  }
}, {
  id: 'action',
  header: 'Action',
  cell: ({ row }) => h('div', { class: 'flex items-center gap-1' }, [
    h(UButton, {
      label: 'View Detail',
      color: 'neutral',
      variant: 'outline',
      size: 'xs',
      to: `/operations/delivery-orders/${row.original.id}`
    }),
    h(UButton, {
      icon: 'i-lucide-history',
      color: 'neutral',
      variant: 'outline',
      size: 'xs',
      square: true
    })
  ])
}]
</script>

<template>
  <UCard
    :ui="{
      root: 'overflow-hidden',
      body: 'p-0 sm:p-0'
    }"
  >
    <UTable
      :data="paged"
      :columns="columns"
      :loading="loading"
      class="shrink-0"
      :ui="{
        base: 'table-fixed border-separate border-spacing-0',
        thead: '[&>tr]:bg-elevated [&>tr]:after:content-none',
        tbody: '[&>tr]:last:[&>td]:border-b-0',
        th: 'py-3.5 first:rounded-tl-xl last:rounded-tr-xl border-b border-default',
        td: 'border-b border-default py-4'
      }"
    />

    <div class="flex items-center justify-between gap-3 px-4 py-4 border-t border-default">
      <p class="text-sm text-muted">
        {{ paged.length }} of {{ data.length }} row(s) showed.
      </p>

      <UPagination
        :default-page="page"
        :items-per-page="pageSize"
        :total="data.length"
        @update:page="(p: number) => page = p"
      />
    </div>
  </UCard>
</template>
