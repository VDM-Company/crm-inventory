<script setup lang="ts">
const confirmOpen = ref(false)
const toast = useToast()

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
    description: 'Product created successfully',
    color: 'success'
  })
  navigateTo('/products')
}
</script>

<template>
  <UDashboardPanel id="products-create">
    <template #body>
      <ProductsProductForm
        mode="create"
        @save="openSaveConfirm"
        @draft="saveDraft"
      />

      <ConfigSaveConfirmModal
        v-model:open="confirmOpen"
        confirm-label="Create New Product"
        @confirm="confirmSave"
      />
    </template>
  </UDashboardPanel>
</template>
