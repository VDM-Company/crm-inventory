<script setup lang="ts">
import type { Product } from '~/types'

const route = useRoute()
const id = computed(() => route.params.id as string)

const { data: product, status } = await useFetch<Product>(() => `/api/products/${id.value}`, {
  lazy: true
})
</script>

<template>
  <UDashboardPanel id="products-detail">
    <template #body>
      <div
        v-if="status === 'pending'"
        class="flex items-center justify-center py-24"
      >
        <UIcon name="i-lucide-loader-circle" class="size-8 animate-spin text-muted" />
      </div>

      <ProductsProductDetailView
        v-else-if="product"
        :product="product"
      />
    </template>
  </UDashboardPanel>
</template>
