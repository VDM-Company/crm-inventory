<script setup lang="ts">
defineProps<{
  title?: string
  subtitle?: string
}>()
</script>

<template>
  <UDashboardNavbar
    :ui="{
      root: 'h-16 px-4 sm:px-8',
      title: 'flex flex-col items-start'
    }"
  >
    <template #title>
      <span class="text-lg font-semibold text-highlighted leading-tight">{{ title }}</span>
      <span
        v-if="subtitle"
        class="text-sm font-normal text-muted leading-tight"
      >{{ subtitle }}</span>
    </template>

    <template #right>
      <slot name="right" />
    </template>
  </UDashboardNavbar>
</template>
