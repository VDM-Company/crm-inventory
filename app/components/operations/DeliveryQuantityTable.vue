<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'
import type { DeliveryOrderQuantityItem } from '~/types'

defineProps<{
  data: DeliveryOrderQuantityItem[]
}>()

const UButton = resolveComponent('UButton')

const columns: TableColumn<DeliveryOrderQuantityItem>[] = [{
  accessorKey: 'productName',
  header: 'Product Name',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('productName'))
}, {
  accessorKey: 'lotSerial',
  header: 'Lot/Serial',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('lotSerial'))
}, {
  accessorKey: 'demand',
  header: 'Demand',
  cell: ({ row }) => h('span', { class: 'text-muted' }, String(row.getValue('demand')))
}, {
  accessorKey: 'quantity',
  header: 'Quantity',
  cell: ({ row }) => h('span', { class: 'text-muted' }, String(row.getValue('quantity')))
}, {
  accessorKey: 'stock',
  header: 'Stock',
  cell: ({ row }) => h('span', { class: 'text-muted' }, String(row.getValue('stock')))
}, {
  id: 'action',
  header: 'Action',
  cell: () => h('div', { class: 'flex items-center gap-1' }, [
    h(UButton, {
      label: 'Edit',
      icon: 'i-lucide-pencil',
      color: 'primary',
      size: 'xs'
    }),
    h(UButton, {
      label: 'Delete',
      icon: 'i-lucide-trash-2',
      color: 'neutral',
      variant: 'outline',
      size: 'xs'
    })
  ])
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
