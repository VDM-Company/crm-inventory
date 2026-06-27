<script setup lang="ts">
import type { Product, ProductQuantityItem } from '~/types'

const route = useRoute()
const id = computed(() => route.params.id as string)

const { data: product, status: productStatus } = await useFetch<Product>(() => `/api/products/${id.value}`, {
  lazy: true
})

const { data: quantities, status: quantitiesStatus } = await useFetch<ProductQuantityItem[]>(() => `/api/products/${id.value}/quantities`, {
  lazy: true,
  default: () => []
})

const search = ref('')
const addModalOpen = ref(false)
const toast = useToast()

const items = ref<ProductQuantityItem[]>([])

watch(quantities, (value) => {
  if (value) {
    items.value = [...value]
  }
}, { immediate: true })

const totalSum = computed(() => items.value.length)

function onCreate(item: Omit<ProductQuantityItem, 'id'>) {
  const nextId = String(Math.max(0, ...items.value.map(i => Number(i.id))) + 1)

  items.value.unshift({
    id: nextId,
    ...item
  })

  toast.add({
    title: 'Quantity created',
    description: 'Product quantity added successfully',
    color: 'success'
  })
}

function onDelete(quantityId: string) {
  items.value = items.value.filter(item => item.id !== quantityId)

  toast.add({
    title: 'Deleted',
    description: 'Quantity item removed',
    color: 'success'
  })
}

function onDownloadCsv() {
  toast.add({
    title: 'Download CSV',
    description: 'CSV export is not available in demo mode',
    color: 'neutral'
  })
}

function onImportCsv() {
  toast.add({
    title: 'Import CSV',
    description: 'CSV import is not available in demo mode',
    color: 'neutral'
  })
}
</script>

<template>
  <UDashboardPanel id="products-manage-quantity">
    <template #body>
      <div
        v-if="productStatus === 'pending' || quantitiesStatus === 'pending'"
        class="flex items-center justify-center py-24"
      >
        <UIcon name="i-lucide-loader-circle" class="size-8 animate-spin text-muted" />
      </div>

      <div
        v-else-if="product"
        class="mx-auto flex w-full max-w-6xl flex-col gap-6"
      >
        <nav class="flex items-center gap-1.5 text-sm">
          <NuxtLink
            to="/products"
            class="text-muted hover:text-highlighted transition-colors"
          >
            Product
          </NuxtLink>
          <UIcon name="i-lucide-chevron-right" class="size-3.5 text-dimmed" />
          <NuxtLink
            :to="`/products/${id}`"
            class="text-muted hover:text-highlighted transition-colors"
          >
            Detail Product
          </NuxtLink>
          <UIcon name="i-lucide-chevron-right" class="size-3.5 text-dimmed" />
          <span class="font-medium text-primary">Manage Quantity</span>
        </nav>

        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
          <div class="flex items-start gap-3">
            <UButton
              icon="i-lucide-arrow-left"
              color="neutral"
              variant="ghost"
              square
              :to="`/products/${id}`"
            />

            <div class="space-y-1">
              <h1 class="text-lg font-semibold text-highlighted">
                Manage Quantity
              </h1>
              <p class="text-base text-muted">
                Manage inventory and stock levels for {{ product.name }}.
              </p>
            </div>
          </div>

          <div class="flex flex-wrap items-center gap-3">
            <UButton
              label="Download CSV"
              icon="i-lucide-download"
              color="neutral"
              variant="outline"
              @click="onDownloadCsv"
            />
            <UButton
              label="Import CSV"
              icon="i-lucide-upload"
              color="neutral"
              variant="outline"
              @click="onImportCsv"
            />
            <UButton
              label="Add Quantity"
              icon="i-lucide-plus"
              color="primary"
              @click="addModalOpen = true"
            />
          </div>
        </div>

        <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <UInput
            v-model="search"
            icon="i-lucide-search"
            placeholder="Search quantity..."
            class="w-full sm:max-w-sm"
          />

          <div class="flex flex-wrap items-center gap-3">
            <UBadge
              variant="subtle"
              color="neutral"
              class="text-xs"
            >
              Total Sum: {{ totalSum }} Items
            </UBadge>

            <UButton
              label="Filters"
              icon="i-lucide-list-filter"
              color="neutral"
              variant="outline"
            />
          </div>
        </div>

        <ProductsProductQuantityTable
          :data="items"
          :search="search"
          @delete="onDelete"
        />

        <ProductsAddProductQuantityModal
          v-model:open="addModalOpen"
          @create="onCreate"
        />
      </div>
    </template>
  </UDashboardPanel>
</template>
