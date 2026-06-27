<script setup lang="ts">
const open = defineModel<boolean>('open', { default: false })

withDefaults(defineProps<{
  confirmLabel?: string
}>(), {
  confirmLabel: 'Save Data'
})

const emit = defineEmits<{
  confirm: []
}>()
</script>

<template>
  <UModal
    v-model:open="open"
    :ui="{ content: 'max-w-sm' }"
  >
    <template #body>
      <div class="flex flex-col items-center gap-3 px-2 py-1 text-center">
        <div class="flex items-center justify-center size-12 rounded-full bg-info/10">
          <UIcon name="i-lucide-info" class="size-6 text-info" />
        </div>

        <div class="space-y-1">
          <p class="text-base font-semibold text-highlighted">
            Are you sure want to save this data?
          </p>
          <p class="text-xs text-muted">
            Make sure you fill data correctly
          </p>
        </div>

        <div class="flex items-center gap-3 pt-2">
          <UButton
            label="Cancel"
            color="neutral"
            variant="outline"
            @click="open = false"
          />
          <UButton
            :label="confirmLabel"
            color="primary"
            @click="emit('confirm')"
          />
        </div>
      </div>
    </template>
  </UModal>
</template>
