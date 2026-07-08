<script setup lang="ts">
const open = defineModel<boolean>('open', { default: false })

const emit = defineEmits<{
  approve: []
}>()
</script>

<template>
  <UModal
    v-model:open="open"
    :ui="{ content: 'max-w-sm' }"
  >
    <template #body>
      <div class="flex flex-col items-center gap-3 px-2 py-1 text-center">
        <div class="flex items-center justify-center size-12 rounded-full bg-info">
          <UIcon name="i-lucide-info" class="size-6 text-white" />
        </div>

        <div class="space-y-1">
          <p class="text-base font-semibold text-highlighted">
            Are you sure want to approve this request?
          </p>
          <p class="text-xs text-muted">
            Make sure your approve is valid by data.
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
            label="Approve"
            color="primary"
            @click="emit('approve')"
          />
        </div>
      </div>
    </template>
  </UModal>
</template>
