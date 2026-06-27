<script setup lang="ts">
import type { Product } from '~/types'

const route = useRoute()
const confirmOpen = ref(false)
const toast = useToast()

const { data: product, status } = await useFetch<Product>(() => `/api/products/${route.params.id}`, {
  lazy: true
})

function openSaveConfirm() {
  confirmOpen.value = true
}

function saveDraft() {
  toast.add({
    title: 'Draft saved',
    description: 'Product saved as draft',
    color: 'success'
  })
}

function confirmSave() {
  confirmOpen.value = false
  toast.add({
    title: 'Success',
    description: 'Product updated successfully',
    color: 'success'
  })
}
</script>

<template>
  <UDashboardPanel id="products-detail">
    <template #body>
      <div v-if="status === 'pending'" class="flex items-center justify-center py-24">
        <UIcon name="i-lucide-loader-circle" class="size-8 animate-spin text-muted" />
      </div>

      <ProductsProductForm
        v-else-if="product"
        mode="detail"
        :product="product"
        breadcrumb-current="Product Detail"
        submit-label="Save Changes"
        :cancel-to="'/products'"
        @save="openSaveConfirm"
        @draft="saveDraft"
      />

      <ConfigSaveConfirmModal
        v-model:open="confirmOpen"
        confirm-label="Save Changes"
        @confirm="confirmSave"
      />
    </template>
  </UDashboardPanel>
</template>
