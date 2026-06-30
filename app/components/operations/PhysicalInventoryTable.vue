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

const toast = useToast()

const counted = ref<Record<string, number | undefined>>({})
const pendingApproval = ref<Record<string, boolean>>({})
const page = ref(1)
const pageSize = 10

const inputModalOpen = ref(false)
const confirmModalOpen = ref(false)
const reasonModalOpen = ref(false)
const activeItem = ref<PhysicalInventoryItem | null>(null)

const activeCount = computed(() => {
  return activeItem.value ? counted.value[activeItem.value.id] : undefined
})

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
  return pendingApproval.value[item.id] ? 'pending-approval' : 'pending-count'
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

const statusMap: Record<PhysicalInventoryCountStatus, { label: string, color: 'warning' | 'info' }> = {
  'pending-count': { label: 'Pending Count', color: 'warning' },
  'pending-approval': { label: 'Pending Approval', color: 'info' }
}

function openInput(item: PhysicalInventoryItem) {
  activeItem.value = item
  inputModalOpen.value = true
}

function onSaveCount(value: number) {
  if (activeItem.value) {
    counted.value[activeItem.value.id] = value
  }
}

function openApply(item: PhysicalInventoryItem) {
  activeItem.value = item
  confirmModalOpen.value = true
}

function onConfirmCount() {
  confirmModalOpen.value = false
  reasonModalOpen.value = true
}

function onRequestApproval() {
  if (activeItem.value) {
    pendingApproval.value[activeItem.value.id] = true
  }

  reasonModalOpen.value = false

  toast.add({
    title: 'Inventory Count Updated!',
    description: 'Please check the update on the row!',
    color: 'success'
  })
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
    const value = counted.value[item.id]

    if (value === undefined) {
      return h(UButton, {
        label: 'Enter Value',
        color: 'neutral',
        variant: 'link',
        size: 'sm',
        class: 'p-0 text-muted hover:text-default',
        onClick: () => openInput(item)
      })
    }

    return h('span', { class: 'font-medium text-highlighted' }, String(value))
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
  cell: ({ row }) => {
    const item = row.original
    const buttons = [
      h(UButton, {
        label: 'History',
        icon: 'i-lucide-history',
        color: 'neutral',
        variant: 'outline',
        size: 'xs'
      })
    ]

    if (counted.value[item.id] !== undefined && !pendingApproval.value[item.id]) {
      buttons.push(h(UButton, {
        label: 'Apply',
        icon: 'i-lucide-check',
        color: 'primary',
        variant: 'solid',
        size: 'xs',
        onClick: () => openApply(item)
      }))
    }

    return h('div', { class: 'flex items-center gap-1' }, buttons)
  }
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

  <OperationsPhysicalInventoryInputCountModal
    v-model:open="inputModalOpen"
    :initial-value="activeCount"
    @save="onSaveCount"
  />

  <OperationsPhysicalInventoryConfirmCountModal
    v-model:open="confirmModalOpen"
    :on-hand="activeItem?.onHand"
    :counted="activeCount"
    @confirm="onConfirmCount"
  />

  <OperationsPhysicalInventoryReasonModal
    v-model:open="reasonModalOpen"
    @request="onRequestApproval"
  />
</template>
