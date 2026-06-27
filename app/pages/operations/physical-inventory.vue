<script setup lang="ts">
import { format } from 'date-fns'
import type { PhysicalInventoryItem } from '~/types'

const search = ref('')
const lastUpdate = ref(new Date('2026-02-13T11:04:00'))

const { data, status, refresh } = await useFetch<PhysicalInventoryItem[]>('/api/physical-inventory', {
  lazy: true,
  default: () => []
})

const lastUpdateLabel = computed(() => {
  return `Last update: ${format(lastUpdate.value, 'd MMM h.mm a')}`
})

async function refreshData() {
  await refresh()
  lastUpdate.value = new Date()
}
</script>

<template>
  <UDashboardPanel id="physical-inventory">
    <template #header>
      <AppHeader
        title="Physical Inventory"
        subtitle="Check your inventory at the selected warehouse"
      />
    </template>

    <template #body>
      <div class="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
        <UInput
          v-model="search"
          icon="i-lucide-search"
          placeholder="Search SKU…"
          class="w-full sm:w-64"
        />

        <div class="flex flex-wrap items-center gap-3 lg:justify-end">
          <div class="flex items-center gap-2 text-sm font-medium text-muted">
            <UIcon name="i-lucide-calendar" class="size-5 shrink-0" />
            <span>{{ lastUpdateLabel }}</span>
          </div>

          <UButton
            label="Refresh Data"
            icon="i-lucide-refresh-cw"
            color="neutral"
            variant="outline"
            @click="refreshData"
          />

          <UButton
            label="Filters"
            icon="i-lucide-list-filter"
            color="neutral"
            variant="outline"
          />
        </div>
      </div>

      <OperationsPhysicalInventoryTable
        :data="data"
        :loading="status === 'pending'"
        :search="search"
      />
    </template>
  </UDashboardPanel>
</template>
