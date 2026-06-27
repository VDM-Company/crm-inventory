<script setup lang="ts">
defineProps<{
  title: string
  description: string
  icon: string
  to?: string
}>()
</script>

<template>
  <UCard
    :ui="{
      root: 'shadow-sm',
      body: 'p-6 flex flex-col gap-6'
    }"
  >
    <div class="flex items-start justify-between gap-3">
      <div class="flex items-center justify-center size-12 rounded-lg bg-info/10 shrink-0">
        <UIcon :name="icon" class="size-8 text-info" />
      </div>

      <UButton
        label="View Detail"
        color="primary"
        size="sm"
        :to="to"
      />
    </div>

    <div class="space-y-3">
      <h3 class="text-2xl font-semibold text-highlighted">
        {{ title }}
      </h3>
      <p class="text-sm font-medium text-muted">
        {{ description }}
      </p>
    </div>
  </UCard>
</template>
