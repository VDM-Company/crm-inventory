<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'
import type { ProductPricing } from '~/types'

defineProps<{
  data: ProductPricing[]
}>()

const UBadge = resolveComponent('UBadge')
const UButton = resolveComponent('UButton')

const columns: TableColumn<ProductPricing>[] = [{
  accessorKey: 'priceVersion',
  header: 'Price Version',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('priceVersion'))
}, {
  accessorKey: 'monthlyFee',
  header: 'Monthly Fee',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('monthlyFee'))
}, {
  accessorKey: 'initialFee',
  header: 'Initial Fee',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('initialFee'))
}, {
  id: 'status',
  header: 'Status',
  cell: ({ row }) => {
    const item = row.original
    const color = item.status === 'Active' ? 'primary' : 'neutral'

    return h('div', { class: 'space-y-1.5' }, [
      h(UBadge, {
        variant: 'subtle',
        color,
        class: 'text-[10px]'
      }, () => item.status),
      h('p', { class: 'text-xs text-dimmed' }, item.statusSince)
    ])
  }
}, {
  id: 'action',
  header: 'Action',
  cell: () => h(UButton, {
    label: 'Edit',
    icon: 'i-lucide-pencil',
    color: 'neutral',
    variant: 'outline',
    size: 'xs'
  })
}]
</script>

<template>
  <UTable
    :data="data"
    :columns="columns"
    class="shrink-0"
    :ui="{
      base: 'table-fixed border-separate border-spacing-0',
      thead: '[&>tr]:bg-elevated [&>tr]:after:content-none',
      tbody: '[&>tr]:last:[&>td]:border-b-0',
      th: 'py-3.5 first:rounded-tl-xl last:rounded-tr-xl border-b border-default',
      td: 'border-b border-default py-4'
    }"
  />
</template>
