<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'
import type { ProductQuantityItem, ProductQuantityStatus } from '~/types'

const props = defineProps<{
  data: ProductQuantityItem[]
  loading?: boolean
  search: string
}>()

const emit = defineEmits<{
  delete: [id: string]
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
    item.location.toLowerCase().includes(query)
    || item.imei.toLowerCase().includes(query)
    || item.iccid.toLowerCase().includes(query)
    || item.msnNumber.toLowerCase().includes(query)
    || item.activationCode.toLowerCase().includes(query)
    || item.vendor.toLowerCase().includes(query)
  )
})

watch(() => props.search, () => {
  page.value = 1
})

const paged = computed(() => {
  const start = (page.value - 1) * pageSize
  return filtered.value.slice(start, start + pageSize)
})

const statusColor: Record<ProductQuantityStatus, 'primary' | 'warning' | 'neutral'> = {
  Ready: 'primary',
  Pending: 'warning',
  Draft: 'neutral'
}

const columns: TableColumn<ProductQuantityItem>[] = [{
  accessorKey: 'location',
  header: 'Location',
  cell: ({ row }) => h('span', { class: 'text-dimmed' }, row.getValue('location'))
}, {
  accessorKey: 'imei',
  header: 'Imei',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('imei'))
}, {
  accessorKey: 'iccid',
  header: 'ICCID',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('iccid'))
}, {
  accessorKey: 'msnNumber',
  header: 'MSN Number',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('msnNumber'))
}, {
  accessorKey: 'activationCode',
  header: 'Activation code',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('activationCode'))
}, {
  accessorKey: 'vendor',
  header: 'Vendor',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('vendor'))
}, {
  accessorKey: 'status',
  header: 'Status',
  cell: ({ row }) => {
    const status = row.getValue('status') as ProductQuantityStatus

    return h(UBadge, {
      variant: 'subtle',
      color: statusColor[status],
      class: 'text-[10px]'
    }, () => status)
  }
}, {
  id: 'action',
  header: 'Action',
  cell: ({ row }) => h(UButton, {
    label: 'Delete',
    icon: 'i-lucide-trash-2',
    color: 'error',
    variant: 'outline',
    size: 'xs',
    onClick: () => emit('delete', row.original.id)
  })
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
        base: 'table-fixed border-separate border-spacing-0 min-w-[1100px]',
        thead: '[&>tr]:bg-elevated [&>tr]:after:content-none',
        tbody: '[&>tr]:last:[&>td]:border-b-0',
        th: 'py-3.5 first:rounded-tl-xl last:rounded-tr-xl border-b border-default',
        td: 'border-b border-default py-4'
      }"
    />

    <div class="flex items-center justify-between gap-3 px-4 py-4 border-t border-default">
      <p class="text-sm text-muted">
        0 of {{ filtered.length }} row(s) selected.
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
