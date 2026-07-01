<script setup lang="ts">
import { h, resolveComponent } from 'vue'
import type { TableColumn } from '@nuxt/ui'
import type { CustomField, CustomFieldType } from '~/types'

const props = defineProps<{
  data: CustomField[]
  loading?: boolean
  search: string
}>()

const emit = defineEmits<{
  delete: [id: string]
}>()

const { open: deleteConfirmOpen, request: requestDelete, confirm: confirmDelete } = useDeleteConfirm((id: string) => {
  emit('delete', id)
})

const UBadge = resolveComponent('UBadge')
const UButton = resolveComponent('UButton')
const USwitch = resolveComponent('USwitch')

const fieldTypeIcons: Record<CustomFieldType, string> = {
  Text: 'i-lucide-type',
  Date: 'i-lucide-calendar',
  Number: 'i-lucide-hash',
  Dropdown: 'i-lucide-chevron-down'
}

const filtered = computed(() => {
  const query = props.search.trim().toLowerCase()

  if (!query) {
    return props.data
  }

  return props.data.filter(item =>
    item.label.toLowerCase().includes(query)
    || item.fieldType.toLowerCase().includes(query)
    || item.fieldLocation.toLowerCase().includes(query)
    || item.section.toLowerCase().includes(query)
  )
})

const columns: TableColumn<CustomField>[] = [{
  accessorKey: 'label',
  header: 'Field Label',
  cell: ({ row }) => h('span', { class: 'text-dimmed' }, row.getValue('label'))
}, {
  accessorKey: 'fieldType',
  header: 'Field Type',
  cell: ({ row }) => {
    const type = row.getValue('fieldType') as CustomFieldType

    return h(UBadge, {
      variant: 'subtle',
      color: 'neutral',
      class: 'text-[10px] gap-1'
    }, () => [
      h(resolveComponent('UIcon'), {
        name: fieldTypeIcons[type],
        class: 'size-3'
      }),
      type
    ])
  }
}, {
  accessorKey: 'fieldLocation',
  header: 'Field Location',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('fieldLocation'))
}, {
  accessorKey: 'section',
  header: 'Section',
  cell: ({ row }) => h('span', { class: 'text-muted' }, row.getValue('section'))
}, {
  accessorKey: 'required',
  header: 'Required',
  cell: ({ row }) => h(UBadge, {
    variant: 'subtle',
    color: 'neutral',
    class: 'text-[10px]'
  }, () => row.getValue('required') ? 'Yes' : 'No')
}, {
  id: 'visibility',
  header: 'Visibility',
  cell: ({ row }) => h('div', { class: 'flex items-center gap-2' }, [
    h(USwitch, {
      modelValue: row.original.visibility,
      size: 'sm',
      disabled: true
    }),
    h('span', { class: 'text-xs font-medium text-muted' }, row.original.visibility ? 'Yes' : 'No')
  ])
}, {
  id: 'action',
  header: 'Action',
  cell: ({ row }) => h('div', { class: 'flex items-center gap-1' }, [
    h(UButton, {
      icon: 'i-lucide-pencil',
      color: 'neutral',
      variant: 'outline',
      size: 'xs',
      square: true
    }),
    h(UButton, {
      icon: 'i-lucide-trash-2',
      color: 'neutral',
      variant: 'outline',
      size: 'xs',
      square: true,
      onClick: () => requestDelete(row.original.id)
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
      :data="filtered"
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
  </UCard>

  <DeleteConfirmModal
    v-model:open="deleteConfirmOpen"
    @confirm="confirmDelete"
  />
</template>
