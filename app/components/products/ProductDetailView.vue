<script setup lang="ts">
import type { Product } from '~/types'

const props = defineProps<{
  product: Product
}>()

const emit = defineEmits<{
  delete: []
}>()

const route = useRoute()
const id = computed(() => route.params.id as string)

const toast = useToast()

function onDelete() {
  emit('delete')
  toast.add({
    title: 'Deleted',
    description: 'Product deleted successfully',
    color: 'success'
  })
  navigateTo('/products')
}

function displayValue(value?: string | null) {
  if (!value?.trim()) {
    return '-'
  }

  return value
}

const publishedLabel = computed(() => {
  if (props.product.published) {
    return 'Active'
  }

  return 'Inactive'
})

const trackingLabel = computed(() => {
  if (props.product.trackInventory) {
    return 'Track Inventory'
  }

  return 'Not tracked'
})
</script>

<template>
  <div class="mx-auto flex w-full max-w-6xl flex-col gap-6">
    <nav class="flex items-center gap-1.5 text-sm">
      <NuxtLink
        to="/products"
        class="text-muted hover:text-highlighted transition-colors"
      >
        Product
      </NuxtLink>
      <UIcon name="i-lucide-chevron-right" class="size-3.5 text-dimmed" />
      <span class="font-medium text-primary">Detail Product</span>
    </nav>

    <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
      <div class="flex items-start gap-3">
        <UButton
          icon="i-lucide-arrow-left"
          color="neutral"
          variant="ghost"
          square
          to="/products"
        />

        <div class="space-y-1">
          <h1 class="text-lg font-semibold text-highlighted">
            Detail Product
          </h1>
          <p class="text-base text-muted">
            See detail product information here
          </p>
        </div>
      </div>

      <div class="flex flex-wrap items-center gap-3">
        <UButton
          label="Delete"
          icon="i-lucide-trash-2"
          color="error"
          variant="outline"
          @click="onDelete"
        />
        <UButton
          label="Manage Quantity"
          icon="i-lucide-package"
          color="neutral"
          variant="outline"
          :to="`/products/${id}/manage-quantity`"
        />
        <UButton
          label="Edit"
          icon="i-lucide-pencil"
          color="neutral"
          variant="outline"
          :to="`/products/${id}/edit`"
        />
      </div>
    </div>

    <div class="grid grid-cols-1 gap-4 lg:grid-cols-[1fr_320px]">
      <UCard>
        <template #header>
          <h2 class="text-lg font-bold text-highlighted">
            Core Identification
          </h2>
        </template>

        <div class="space-y-4">
          <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Product Name
              </p>
              <p class="text-sm text-highlighted">
                {{ product.name }}
              </p>
            </div>
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                SKU
              </p>
              <p class="text-sm text-highlighted">
                {{ product.sku }}
              </p>
            </div>
          </div>

          <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                No Reference
              </p>
              <p class="text-sm text-highlighted">
                {{ product.reference }}
              </p>
            </div>
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Product Type
              </p>
              <p class="text-sm text-highlighted">
                {{ product.productType }}
              </p>
            </div>
          </div>

          <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
            <div class="space-y-2">
              <p class="text-sm font-medium text-highlighted">
                Notes (optional)
              </p>
              <p class="text-sm text-highlighted">
                {{ displayValue(product.notes) }}
              </p>
            </div>
            <div class="space-y-2">
              <p class="text-sm font-medium text-highlighted">
                Image (optional)
              </p>
              <p class="text-sm text-highlighted">
                -
              </p>
            </div>
          </div>
        </div>
      </UCard>

      <UCard class="h-fit">
        <template #header>
          <h2 class="text-lg font-bold text-highlighted">
            Settings
          </h2>
        </template>

        <div class="space-y-4">
          <div class="space-y-2">
            <p class="text-sm font-semibold text-highlighted">
              Category
            </p>
            <p class="text-sm text-highlighted">
              {{ product.settingsCategory }}
            </p>
          </div>
          <div class="space-y-2">
            <p class="text-sm font-semibold text-highlighted">
              Company
            </p>
            <p class="text-sm text-highlighted">
              {{ product.company }}
            </p>
          </div>
          <div class="space-y-2">
            <p class="text-sm font-semibold text-highlighted">
              Product Status
            </p>
            <UBadge
              variant="subtle"
              :color="product.status === 'Active' ? 'primary' : 'neutral'"
              class="text-[10px]"
            >
              {{ product.status }}
            </UBadge>
          </div>
          <div class="space-y-2">
            <p class="text-sm font-semibold text-highlighted">
              Platform
            </p>
            <p class="text-sm text-highlighted">
              {{ product.platform }}
            </p>
          </div>
          <div class="space-y-2">
            <p class="text-sm font-semibold text-highlighted">
              Published
            </p>
            <p class="text-sm text-highlighted">
              {{ publishedLabel }}
            </p>
          </div>
        </div>
      </UCard>
    </div>

    <UCard>
      <template #header>
        <h2 class="text-lg font-bold text-highlighted">
          Inventory
        </h2>
      </template>

      <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
        <div class="space-y-2">
          <p class="text-sm font-semibold text-highlighted">
            Tracking
          </p>
          <p class="text-sm text-highlighted">
            {{ trackingLabel }}
          </p>
        </div>
        <div class="space-y-2">
          <p class="text-sm font-semibold text-highlighted">
            Tracked By
          </p>
          <p class="text-sm text-highlighted">
            {{ product.trackedBy }}
          </p>
        </div>
      </div>
    </UCard>

    <ProductsProductBundleSection
      v-if="product.bundle"
      :bundle="product.bundle"
    />
  </div>
</template>
