<script setup lang="ts">
const open = defineModel<boolean>('open', { default: false })

const emit = defineEmits<{
  request: [reason: string]
}>()

const reasonOptions = [
  { label: 'Counting mistake', value: 'Counting mistake' },
  { label: 'Damaged goods', value: 'Damaged goods' },
  { label: 'Theft or loss', value: 'Theft or loss' },
  { label: 'Supplier error', value: 'Supplier error' },
  { label: 'System error', value: 'System error' }
]

const reason = ref('Counting mistake')

watch(open, (value) => {
  if (value) {
    reason.value = 'Counting mistake'
  }
})

function request() {
  emit('request', reason.value)
  open.value = false
}
</script>

<template>
  <UModal
    v-model:open="open"
    title="Reasoning"
    description="Select reason based real condition."
    :ui="{ content: 'max-w-md' }"
  >
    <template #body>
      <div class="space-y-4">
        <UFormField label="Reason for the Inventory Disparency?">
          <USelect
            v-model="reason"
            :items="reasonOptions"
            class="w-full"
          />
        </UFormField>

        <UButton
          label="Request Adjustment Approval"
          color="primary"
          block
          @click="request"
        />
      </div>
    </template>
  </UModal>
</template>
