<script setup lang="ts">
import type { DeliveryOrderListItem } from '~/types'

const { data, status } = await useFetch<DeliveryOrderListItem[]>('/api/delivery-orders', {
  lazy: true,
  default: () => []
})
</script>

<template>
  <UDashboardPanel id="delivery-orders">
    <template #body>
      <div class="flex flex-col gap-6">
        <nav class="flex items-center gap-1.5 text-sm">
          <NuxtLink
            to="/operations"
            class="text-muted hover:text-highlighted transition-colors"
          >
            Operations
          </NuxtLink>
          <UIcon name="i-lucide-chevron-right" class="size-3.5 text-dimmed" />
          <span class="font-medium text-primary">Delivery</span>
        </nav>

        <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div class="flex items-start gap-3">
            <UButton
              icon="i-lucide-arrow-left"
              color="neutral"
              variant="ghost"
              square
              to="/operations"
            />

            <div class="space-y-1">
              <h1 class="text-lg font-semibold text-highlighted">
                Delivery Orders
              </h1>
              <p class="text-base text-muted">
                See list of delivery orders here.
              </p>
            </div>
          </div>

          <div class="flex flex-wrap items-center gap-3 shrink-0">
            <UButton
              label="Filters"
              icon="i-lucide-list-filter"
              color="neutral"
              variant="outline"
            />
            <UButton
              label="Create New Delivery"
              icon="i-lucide-plus"
              color="primary"
              to="/operations/delivery-orders/create"
            />
          </div>
        </div>

        <OperationsDeliveryOrdersTable
          :data="data"
          :loading="status === 'pending'"
        />
      </div>
    </template>
  </UDashboardPanel>
</template>
