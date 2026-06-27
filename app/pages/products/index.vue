<script setup lang="ts">
import type { ProductListItem } from '~/types'

const search = ref('')

const { data, status } = await useFetch<ProductListItem[]>('/api/products', {
  lazy: true,
  default: () => []
})
</script>

<template>
  <UDashboardPanel id="products">
    <template #body>
      <div class="flex flex-col gap-6">
        <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div class="space-y-1">
            <h1 class="text-lg font-semibold text-highlighted">
              Product
            </h1>
            <p class="text-base text-muted">
              Manage your product inventory and track stock levels.
            </p>
          </div>

          <div class="flex flex-wrap items-center gap-3 shrink-0">
            <UButton
              label="Product Return"
              icon="i-lucide-undo-2"
              color="neutral"
              variant="outline"
            />
            <UButton
              label="Download CSV"
              icon="i-lucide-download"
              color="neutral"
              variant="outline"
            />
            <UButton
              label="New Product"
              icon="i-lucide-plus"
              color="primary"
              to="/products/create"
            />
          </div>
        </div>

        <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <UInput
            v-model="search"
            icon="i-lucide-search"
            placeholder="Search product..."
            class="w-full sm:max-w-sm"
          />

          <UButton
            label="Filters"
            icon="i-lucide-list-filter"
            color="neutral"
            variant="outline"
          />
        </div>

        <ProductsTable
          :data="data"
          :loading="status === 'pending'"
          :search="search"
        />
      </div>
    </template>
  </UDashboardPanel>
</template>
