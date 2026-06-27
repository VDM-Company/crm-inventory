<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'
import type { ProductListItem, ProductStatus } from '~/types'

const props = defineProps<{
  data: ProductListItem[]
  loading?: boolean
  search: string
}>()

const UBadge = resolveComponent('UBadge')
const UButton = resolveComponent('UButton')

const page = ref(1)
const pageSize = 10

const filtered = computed(() => {
  const query = props.search.trim().toLowerCase()

  if (!query) {
    return props.data
  }

  return props.data.filter(item =>
    item.name.toLowerCase().includes(query)
    || item.reference.toLowerCase().includes(query)
    || item.category.toLowerCase().includes(query)
    || item.company.toLowerCase().includes(query)
  )
})

watch(() => props.search, () => {
  page.value = 1
})

const paged = computed(() => {
  const start = (page.value - 1) * pageSize
  return filtered.value.slice(start, start + pageSize)
})

const statusMap: Record<ProductStatus, { color: 'primary' | 'neutral' }> = {
  Active: { color: 'primary' },
  Inactive: { color: 'neutral' }
}

const columns: TableColumn<ProductListItem>[] = [{
  accessorKey: 'name',
  header: 'Product Name',
  cell: ({ row }) => h('span', { class: 'text-dimmed' }, row.getValue('name'))
}, {
  accessorKey: 'reference',
  header: 'Reference',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('reference'))
}, {
  accessorKey: 'category',
  header: 'Category',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('category'))
}, {
  accessorKey: 'productType',
  header: 'Product Type',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('productType'))
}, {
  accessorKey: 'company',
  header: 'Company',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('company'))
}, {
  accessorKey: 'trackedBy',
  header: 'Tracked By',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('trackedBy'))
}, {
  accessorKey: 'status',
  header: 'Status',
  cell: ({ row }) => {
    const status = row.getValue('status') as ProductStatus
    const config = statusMap[status]

    return h(UBadge, {
      variant: 'subtle',
      color: config.color,
      class: 'text-[10px]'
    }, () => status)
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
      to: `/products/${row.original.id}`
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
        {{ paged.length }} of {{ filtered.length }} row(s) showed.
      </p>

      <UPagination
        :default-page="page"
        :items-per-page="pageSize"
        :total="filtered.length"
        @update:page="(p: number) => page = p"
      />
    </div>
  </UCard>
</template>
