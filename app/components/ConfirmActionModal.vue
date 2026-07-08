<script setup lang="ts">
const open = defineModel<boolean>('open', { default: false })

const props = withDefaults(defineProps<{
  title: string
  description?: string
  confirmLabel?: string
  confirmColor?: 'primary' | 'error'
  icon?: string
  iconColor?: 'info' | 'error' | 'warning' | 'primary'
}>(), {
  confirmLabel: 'Confirm',
  confirmColor: 'primary',
  icon: 'i-lucide-info',
  iconColor: 'info'
})

const emit = defineEmits<{
  confirm: []
}>()

const iconBgClass = computed(() => ({
  info: 'bg-info',
  error: 'bg-error',
  warning: 'bg-warning',
  primary: 'bg-primary'
}[props.iconColor]))
</script>

<template>
  <UModal
    v-model:open="open"
    :ui="{ content: 'max-w-sm' }"
  >
    <template #body>
      <div class="flex flex-col items-center gap-3 px-2 py-1 text-center">
        <div
          class="flex items-center justify-center size-12 rounded-full"
          :class="iconBgClass"
        >
          <UIcon :name="icon" class="size-6 text-white" />
        </div>

        <div class="space-y-1">
          <p class="text-base font-semibold text-highlighted">
            {{ title }}
          </p>
          <p
            v-if="description"
            class="text-xs text-muted"
          >
            {{ description }}
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
            :color="confirmColor"
            @click="emit('confirm')"
          />
        </div>
      </div>
    </template>
  </UModal>
</template>
