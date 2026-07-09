<script setup lang="ts">
const open = defineModel<boolean>('open', { default: false })

defineProps<{
  title: string
}>()

const emit = defineEmits<{
  save: [name: string]
}>()

const name = ref('')

watch(open, (value) => {
  if (value) {
    name.value = ''
  }
})

function save() {
  const trimmed = name.value.trim()

  if (!trimmed) {
    return
  }

  emit('save', trimmed)
  open.value = false
}
</script>

<template>
  <UModal
    v-model:open="open"
    :title="title"
    :ui="{ content: 'max-w-md' }"
  >
    <template #body>
      <div class="space-y-4">
        <UFormField label="Name">
          <UInput
            v-model="name"
            placeholder="Input here"
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
            :disabled="!name.trim()"
            @click="save"
          />
        </div>
      </div>
    </template>
  </UModal>
</template>
