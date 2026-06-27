<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'
import type { PhysicalInventoryCountStatus, PhysicalInventoryItem } from '~/types'

const props = defineProps<{
  data: PhysicalInventoryItem[]
  loading?: boolean
  search: string
}>()

const UBadge = resolveComponent('UBadge')
const UButton = resolveComponent('UButton')
const UInput = resolveComponent('UInput')

const counted = ref<Record<string, number | undefined>>({})
const page = ref(1)
const pageSize = 10

const filtered = computed(() => {
  const query = props.search.trim().toLowerCase()

  if (!query) {
    return props.data
  }

  return props.data.filter(item =>
    item.productName.toLowerCase().includes(query)
    || item.sku.toLowerCase().includes(query)
  )
})

watch(() => props.search, () => {
  page.value = 1
})

const paged = computed(() => {
  const start = (page.value - 1) * pageSize
  return filtered.value.slice(start, start + pageSize)
})

function getDifference(item: PhysicalInventoryItem): number | null {
  const value = counted.value[item.id]

  if (value === undefined || Number.isNaN(value)) {
    return null
  }

  return value - item.onHand
}

function getStatus(item: PhysicalInventoryItem): PhysicalInventoryCountStatus {
  const value = counted.value[item.id]

  if (value === undefined || Number.isNaN(value)) {
    return 'pending-count'
  }

  return value === item.onHand ? 'matched' : 'discrepancy'
}

function formatDifference(item: PhysicalInventoryItem): string {
  const difference = getDifference(item)

  if (difference === null) {
    return '-'
  }

  if (difference > 0) {
    return `+${difference}`
  }

  return difference.toString()
}

const statusMap: Record<PhysicalInventoryCountStatus, { label: string, color: 'warning' | 'success' | 'error' }> = {
  'pending-count': { label: 'Pending Count', color: 'warning' },
  'matched': { label: 'Matched', color: 'success' },
  'discrepancy': { label: 'Discrepancy', color: 'error' }
}

const columns: TableColumn<PhysicalInventoryItem>[] = [{
  accessorKey: 'productName',
  header: 'Product Name',
  cell: ({ row }) => h('span', { class: 'text-dimmed' }, row.getValue('productName'))
}, {
  accessorKey: 'sku',
  header: 'SKU Code',
  cell: ({ row }) => h('span', { class: 'text-dimmed' }, row.getValue('sku'))
}, {
  accessorKey: 'onHand',
  header: 'On hand',
  cell: ({ row }) => h('span', { class: 'text-muted' }, String(row.getValue('onHand')))
}, {
  id: 'counted',
  header: 'Counted',
  cell: ({ row }) => {
    const item = row.original

    return h(UInput, {
      'modelValue': counted.value[item.id] ?? '',
      'onUpdate:modelValue': (value: string | number) => {
        if (value === '' || value === null) {
          counted.value[item.id] = undefined
          return
        }

        counted.value[item.id] = Number(value)
      },
      'type': 'number',
      'placeholder': 'Enter Value',
      'size': 'sm',
      'class': 'min-w-28 font-medium',
      'min': 0
    })
  }
}, {
  id: 'difference',
  header: 'Difference',
  cell: ({ row }) => {
    const difference = getDifference(row.original)
    const className = difference === null
      ? 'text-muted'
      : difference === 0
        ? 'text-muted'
        : difference > 0
          ? 'text-success font-medium'
          : 'text-error font-medium'

    return h('span', { class: className }, formatDifference(row.original))
  }
}, {
  id: 'status',
  header: 'Status',
  cell: ({ row }) => {
    const statusValue = getStatus(row.original)
    const config = statusMap[statusValue]

    return h(UBadge, {
      variant: 'subtle',
      color: config.color,
      class: 'text-[10px]'
    }, () => config.label)
  }
}, {
  id: 'action',
  header: 'Action',
  cell: () => h('div', { class: 'flex items-center gap-1' }, [
    h(UButton, {
      label: 'View Detail',
      color: 'neutral',
      variant: 'outline',
      size: 'xs'
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
