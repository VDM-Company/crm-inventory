<script setup lang="ts">
const open = defineModel<boolean>('open', { default: false })

const props = withDefaults(defineProps<{
  onHand?: number
  counted?: number
  reason?: string
  notes?: string
}>(), {
  reason: 'Counting mistake',
  notes: 'I forgot to make a sycn between a on hand and counted'
})

const emit = defineEmits<{
  approve: []
  reject: []
}>()

const countedRequest = computed(() => {
  if (props.onHand === undefined) {
    return '-'
  }

  if (props.counted === undefined) {
    return String(props.onHand)
  }

  return `${props.onHand} to ${props.counted}`
})
</script>

<template>
  <UModal
    v-model:open="open"
    title="Detail Adjustment Request"
    description="Check detail data for approve the adjustment request."
    :ui="{ content: 'max-w-md' }"
  >
    <template #body>
      <div class="flex flex-col gap-4">
        <div class="flex flex-col gap-1">
          <p class="text-sm text-dimmed">
            Reason for adjustment
          </p>
          <p class="text-base font-semibold text-highlighted">
            {{ reason }}
          </p>
        </div>

        <div class="flex flex-col gap-1">
          <p class="text-sm text-dimmed">
            Counted Request
          </p>
          <p class="text-base font-semibold text-highlighted">
            {{ countedRequest }}
          </p>
        </div>

        <div class="flex flex-col gap-1">
          <p class="text-sm text-dimmed">
            Notes
          </p>
          <p class="text-base font-semibold text-highlighted">
            {{ notes }}
          </p>
        </div>

        <USeparator />

        <div class="flex items-center gap-4">
          <UButton
            label="Reject"
            color="error"
            variant="outline"
            class="flex-1 justify-center"
            @click="emit('reject')"
          />
          <UButton
            label="Approve"
            color="primary"
            class="flex-1 justify-center"
            @click="emit('approve')"
          />
        </div>
      </div>
    </template>
  </UModal>
</template>
