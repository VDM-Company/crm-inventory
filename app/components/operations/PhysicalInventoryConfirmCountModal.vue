<script setup lang="ts">
const open = defineModel<boolean>('open', { default: false })

const props = defineProps<{
  onHand?: number
  counted?: number
}>()

const emit = defineEmits<{
  confirm: []
}>()

const difference = computed(() => {
  if (props.onHand === undefined || props.counted === undefined) {
    return 0
  }

  return Math.abs(props.counted - props.onHand)
})
</script>

<template>
  <UModal
    v-model:open="open"
    title="Confirm Count"
    description="Please make sure the data already done."
    :ui="{ content: 'max-w-md' }"
  >
    <template #body>
      <div class="divide-y divide-default">
        <div class="flex items-center justify-between py-3">
          <span class="text-muted">On hand</span>
          <span class="font-semibold text-highlighted">{{ onHand }}</span>
        </div>
        <div class="flex items-center justify-between py-3">
          <span class="text-muted">Counted</span>
          <span class="font-semibold text-highlighted">{{ counted }}</span>
        </div>
        <div class="flex items-center justify-between py-3">
          <span class="text-muted">Difference</span>
          <span class="font-semibold text-highlighted">{{ difference }}</span>
        </div>
        <div class="flex items-center justify-between py-3">
          <span class="text-muted">Status</span>
          <UBadge color="warning" variant="subtle">
            Pending Approval
          </UBadge>
        </div>
      </div>

      <div class="flex items-center gap-3 mt-4">
        <UButton
          label="Cancel"
          color="neutral"
          variant="outline"
          class="flex-1 justify-center"
          @click="open = false"
        />
        <UButton
          label="Confirm"
          color="primary"
          class="flex-1 justify-center"
          @click="emit('confirm')"
        />
      </div>
    </template>
  </UModal>
</template>
