<script setup lang="ts">
import type { Product } from '~/types'

const route = useRoute()
const id = computed(() => route.params.id as string)
const confirmOpen = ref(false)
const toast = useToast()

const { data: product, status } = await useFetch<Product>(() => `/api/products/${id.value}`, {
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
  navigateTo(`/products/${id.value}`)
}
</script>

<template>
  <UDashboardPanel id="products-edit">
    <template #body>
      <div v-if="status === 'pending'" class="flex items-center justify-center py-24">
        <UIcon name="i-lucide-loader-circle" class="size-8 animate-spin text-muted" />
      </div>

      <ProductsProductForm
        v-else-if="product"
        mode="edit"
        :product="product"
        breadcrumb-current="Edit Product"
        submit-label="Save Changes"
        :cancel-to="`/products/${id}`"
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
