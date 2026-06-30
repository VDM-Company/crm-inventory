<script setup lang="ts">
const open = defineModel<boolean>('open', { default: false })

const props = defineProps<{
  initialValue?: number
}>()

const emit = defineEmits<{
  save: [value: number]
}>()

const qty = ref('')

const isValid = computed(() => qty.value !== '' && !Number.isNaN(Number(qty.value)))

watch(open, (value) => {
  if (value) {
    qty.value = props.initialValue !== undefined ? String(props.initialValue) : ''
  }
})

function save() {
  if (!isValid.value) {
    return
  }

  emit('save', Number(qty.value))
  open.value = false
}
</script>

<template>
  <UModal
    v-model:open="open"
    title="Input count"
    :ui="{ content: 'max-w-md' }"
  >
    <template #body>
      <div class="space-y-4">
        <UFormField label="Input Qty">
          <UInput
            v-model="qty"
            type="number"
            placeholder="e.g: 100"
            min="0"
            class="w-full"
          />
        </UFormField>

        <div class="flex items-center justify-end gap-3">
          <UButton
            label="Cancel"
            color="neutral"
            variant="outline"
            @click="open = false"
          />
          <UButton
            label="Save"
            color="primary"
            :disabled="!isValid"
            @click="save"
          />
        </div>
      </div>
    </template>
  </UModal>
</template>
