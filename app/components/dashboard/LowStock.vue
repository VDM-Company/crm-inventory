<script setup lang="ts">
import type { LowStockItem } from '~/types'

const items: LowStockItem[] = [{
  id: '1',
  name: 'iPhone 14 Pro (Silver)',
  threshold: 50,
  current: 8
}, {
  id: '2',
  name: 'Docomo SIM Card',
  threshold: 100,
  current: 12
}, {
  id: '3',
  name: 'USB-C Cable (2m)',
  threshold: 20,
  current: 4
}]
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
        class="flex items-center justify-between gap-3 px-4 sm:px-6 py-4"
      >
        <div class="min-w-0">
          <p class="text-sm font-medium text-highlighted truncate">
            {{ item.name }}
          </p>
          <p class="text-xs text-muted mt-1">
            Threshold: {{ item.threshold }} |
            <span class="text-error font-medium">Current: {{ item.current }}</span>
          </p>
        </div>

        <UButton
          label="Re-stock"
          color="primary"
          variant="outline"
          size="xs"
          class="shrink-0"
        />
      </li>
    </ul>
  </UCard>
</template>
