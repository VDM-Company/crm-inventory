<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'
import type { InventoryItem } from '~/types'

const UBadge = resolveComponent('UBadge')
const UButton = resolveComponent('UButton')

const { data, status } = await useFetch<InventoryItem[]>('/api/inventory', {
  lazy: true,
  default: () => []
})

const tabs = [
  { label: 'All', value: 'all' },
  { label: 'SIM', value: 'SIM' },
  { label: 'Devices', value: 'Devices' },
  { label: 'Gifts', value: 'Gifts' },
  { label: 'Supply', value: 'Supply' }
]

const activeTab = ref('all')
const search = ref('')
const page = ref(1)
const pageSize = 10

const filtered = computed(() => {
  const query = search.value.trim().toLowerCase()

  return data.value.filter((item) => {
    const matchTab = activeTab.value === 'all' || item.category === activeTab.value
    const matchSearch = !query
      || item.productName.toLowerCase().includes(query)
      || item.sku.toLowerCase().includes(query)
      || item.location.toLowerCase().includes(query)

    return matchTab && matchSearch
  })
})

watch([activeTab, search], () => {
  page.value = 1
})

const paged = computed(() => {
  const start = (page.value - 1) * pageSize
  return filtered.value.slice(start, start + pageSize)
})

const columns: TableColumn<InventoryItem>[] = [{
  accessorKey: 'productName',
  header: 'Product Name',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('productName'))
}, {
  accessorKey: 'sku',
  header: 'SKU'
}, {
  accessorKey: 'location',
  header: 'Location'
}, {
  accessorKey: 'stock',
  header: 'Stock'
}, {
  accessorKey: 'trackedBy',
  header: 'Tracked By'
}, {
  accessorKey: 'status',
  header: 'Status',
  cell: ({ row }) => {
    const value = row.getValue('status') as string

    return h(UBadge, {
      class: 'capitalize',
      variant: 'subtle',
      color: value === 'active' ? 'success' : 'neutral'
    }, () => value)
  }
}, {
  id: 'action',
  header: 'Action',
  cell: () => h(UButton, {
    label: 'History',
    icon: 'i-lucide-history',
    color: 'neutral',
    variant: 'outline',
    size: 'xs'
  })
}]
</script>

<template>
  <div class="flex flex-col gap-4">
    <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
      <div class="flex gap-1 p-1 bg-elevated rounded-lg w-fit">
        <button
          v-for="tab in tabs"
          :key="tab.value"
          type="button"
          class="px-3 py-1 text-sm rounded-md transition-colors"
          :class="activeTab === tab.value
            ? 'bg-default text-highlighted shadow-sm'
            : 'text-muted hover:text-highlighted'"
          @click="activeTab = tab.value"
        >
          {{ tab.label }}
        </button>
      </div>

      <div class="flex items-center gap-2">
        <UInput
          v-model="search"
          icon="i-lucide-search"
          placeholder="Search items"
          class="w-full sm:w-56"
        />
        <UButton
          label="Filter"
          icon="i-lucide-list-filter"
          color="neutral"
          variant="outline"
        />
        <UButton
          label="Add Product"
          icon="i-lucide-plus"
          color="primary"
        />
      </div>
    </div>

    <h2 class="text-lg font-semibold text-highlighted">
      All Item Tracked
    </h2>

    <UTable
      :data="paged"
      :columns="columns"
      :loading="status === 'pending'"
      class="shrink-0"
      :ui="{
        base: 'table-fixed border-separate border-spacing-0',
        thead: '[&>tr]:bg-elevated/50 [&>tr]:after:content-none',
        tbody: '[&>tr]:last:[&>td]:border-b-0',
        th: 'py-3 first:rounded-l-lg last:rounded-r-lg border-y border-default first:border-l last:border-r',
        td: 'border-b border-default'
      }"
    />

    <div class="flex items-center justify-between gap-3 pt-1">
      <p class="text-sm text-muted">
        {{ paged.length }} of {{ filtered.length }} row(s) shown.
      </p>

      <UPagination
        :default-page="page"
        :items-per-page="pageSize"
        :total="filtered.length"
        @update:page="(p: number) => page = p"
      />
    </div>
  </div>
</template>
