<script setup lang="ts">
import type { DropdownMenuItem } from '@nuxt/ui'
import type { InventoryMetric } from '~/types'

const metrics: InventoryMetric[] = [{
  title: 'Total Available Inventory',
  value: '2,420',
  variation: 40,
  trend: 'up',
  data: [10, 12, 9, 13, 12, 17, 15, 21, 24]
}, {
  title: 'Total Item Stock',
  value: '1,210',
  variation: -10,
  trend: 'down',
  data: [25, 22, 24, 18, 19, 14, 16, 12, 9]
}, {
  title: 'Total Revenue',
  value: '¥1.000.000',
  variation: 20,
  trend: 'up',
  data: [12, 14, 13, 11, 16, 15, 20, 19, 24]
}]

const menuItems: DropdownMenuItem[][] = [[{
  label: 'View details',
  icon: 'i-lucide-eye'
}, {
  label: 'Export',
  icon: 'i-lucide-download'
}]]
</script>

<template>
  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
    <UCard
      v-for="metric in metrics"
      :key="metric.title"
      :ui="{ root: 'overflow-visible', body: 'p-6' }"
    >
      <div class="flex items-start justify-between gap-2">
        <p class="text-sm font-medium text-highlighted">
          {{ metric.title }}
        </p>

        <UDropdownMenu :items="menuItems" :content="{ align: 'end' }">
          <UButton
            icon="i-lucide-ellipsis-vertical"
            color="neutral"
            variant="ghost"
            size="xs"
            square
            class="-me-1.5 -mt-1.5"
          />
        </UDropdownMenu>
      </div>

      <div class="mt-4 flex items-end justify-between gap-3">
        <div class="space-y-2">
          <p class="text-3xl font-semibold text-highlighted tracking-tight">
            {{ metric.value }}
          </p>

          <div class="flex items-center gap-1.5 text-sm">
            <UIcon
              :name="metric.trend === 'up' ? 'i-lucide-arrow-up' : 'i-lucide-arrow-down'"
              class="size-4"
              :class="metric.trend === 'up' ? 'text-success' : 'text-error'"
            />
            <span
              class="font-medium"
              :class="metric.trend === 'up' ? 'text-success' : 'text-error'"
            >
              {{ metric.variation > 0 ? '+' : '' }}{{ metric.variation }}%
            </span>
            <span class="text-muted">vs last month</span>
          </div>
        </div>

        <DashboardSparkline
          :data="metric.data"
          :color="metric.trend === 'up' ? 'var(--ui-success)' : 'var(--ui-error)'"
        />
      </div>
    </UCard>
  </div>
</template>
