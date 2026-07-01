<script setup lang="ts">
import type { ProductBundle, ProductBundleComponent } from '~/types'

defineProps<{
  bundle: ProductBundle
}>()

const emit = defineEmits<{
  delete: [id: string]
}>()

const { open: deleteConfirmOpen, request: requestDelete, confirm: confirmDelete } = useDeleteConfirm((id: string) => {
  emit('delete', id)
})

function componentTotal(component: ProductBundleComponent) {
  return component.items.reduce((sum, item) => sum + item.quantity, 0)
}
</script>

<template>
  <UCard>
    <template #header>
      <div class="flex w-full items-center justify-between gap-3">
        <h2 class="text-lg font-bold text-highlighted">
          Bundle
        </h2>
        <UBadge
          color="neutral"
          variant="solid"
          class="bg-inverted text-inverted"
        >
          Total Bundle: {{ bundle.totalQuantity }} Qty
        </UBadge>
      </div>
    </template>

    <div class="space-y-4">
      <div
        v-for="component in bundle.components"
        :key="component.id"
        class="rounded-2xl border border-default bg-elevated/50 p-4 space-y-3"
      >
        <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <div class="flex items-center gap-2">
            <p class="text-sm font-medium text-highlighted">
              {{ component.name }}
            </p>
            <UBadge
              v-if="component.required"
              variant="subtle"
              color="info"
              class="text-[10px]"
            >
              Required
            </UBadge>
          </div>

          <div class="flex flex-wrap items-center gap-3">
            <UBadge
              color="neutral"
              variant="solid"
              class="bg-inverted text-inverted"
            >
              Total Sum: {{ componentTotal(component) }} Qty
            </UBadge>
            <UButton
              label="Delete"
              icon="i-lucide-trash-2"
              color="neutral"
              variant="outline"
              size="sm"
              @click="requestDelete(component.id)"
            />
            <UButton
              label="Edit"
              icon="i-lucide-pencil"
              color="primary"
              variant="outline"
              size="sm"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
          <div
            v-for="(item, index) in component.items"
            :key="`${component.id}-${index}`"
            class="rounded-xl border border-default bg-default p-3 shadow-xs"
          >
            <div class="flex items-start justify-between gap-3">
              <p class="text-sm font-semibold text-highlighted">
                {{ item.name }}
              </p>
              <UBadge
                variant="subtle"
                color="info"
                class="text-[10px] shrink-0"
              >
                {{ item.quantity }} Qty
              </UBadge>
            </div>
            <div class="mt-2 rounded-md border border-default bg-elevated px-2 py-1">
              <p class="text-sm text-dimmed">
                {{ item.sku }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </UCard>

  <DeleteConfirmModal
    v-model:open="deleteConfirmOpen"
    @confirm="confirmDelete"
  />
</template>
