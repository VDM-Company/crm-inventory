<script setup lang="ts">
import type { BadgeProps } from '@nuxt/ui'
import type { IncomingStatus, IncomingStockItem } from '~/types'

const items: IncomingStockItem[] = [{
  id: '1',
  name: '500 units - iPhone 15 PM',
  threshold: 50,
  current: 8,
  date: '2024-10-24',
  status: 'in-transit'
}, {
  id: '2',
  name: '2,000 units - 5G SIM Packs',
  threshold: 100,
  current: 12,
  date: '2024-10-24',
  status: 'processing'
}, {
  id: '3',
  name: '100 units - iPad Air 5',
  threshold: 20,
  current: 4,
  date: '2024-10-24',
  status: 'scheduled'
}]

const statusMap: Record<IncomingStatus, { label: string, color: BadgeProps['color'] }> = {
  'in-transit': { label: 'In Transit', color: 'success' },
  'processing': { label: 'Processing', color: 'info' },
  'scheduled': { label: 'Scheduled', color: 'neutral' }
}

function month(date: string): string {
  return new Date(date).toLocaleString('en-US', { month: 'short' })
}

function day(date: string): number {
  return new Date(date).getDate()
}
</script>

<template>
  <UCard :ui="{ header: 'flex items-center justify-between', body: 'p-0 sm:p-0' }">
    <template #header>
      <h3 class="text-base font-semibold text-highlighted">
        Top Low-Stock Items
      </h3>

      <UButton
        label="View All"
        color="neutral"
        variant="outline"
        size="xs"
      />
    </template>

    <ul class="divide-y divide-default">
      <li
        v-for="item in items"
        :key="item.id"
        class="flex items-center gap-3 px-4 sm:px-6 py-3.5"
      >
        <div class="flex flex-col items-center justify-center shrink-0 size-10 rounded-lg border border-default">
          <span class="text-[10px] uppercase text-muted leading-none">{{ month(item.date) }}</span>
          <span class="text-sm font-semibold text-highlighted leading-none mt-0.5">{{ day(item.date) }}</span>
        </div>

        <div class="min-w-0 flex-1">
          <p class="text-sm font-medium text-highlighted truncate">
            {{ item.name }}
          </p>
          <p class="text-xs text-muted mt-1">
            Threshold: {{ item.threshold }} |
            <span class="text-error font-medium">Current: {{ item.current }}</span>
          </p>
        </div>

        <UBadge
          :color="statusMap[item.status].color"
          variant="subtle"
          class="shrink-0"
        >
          {{ statusMap[item.status].label }}
        </UBadge>
      </li>
    </ul>
  </UCard>
</template>
