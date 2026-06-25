<script setup lang="ts">
defineProps<{
  collapsed?: boolean
}>()
</script>

<template>
  <div class="flex items-center gap-2 h-11 px-1.5">
    <img
      src="/vertex-logo-mark.svg"
      alt="Vertex Digital Marketing"
      class="size-8 shrink-0"
    >

    <div
      v-if="!collapsed"
      class="flex flex-col leading-none uppercase"
    >
      <span class="font-semibold text-lg tracking-[0.18em] text-[#ff1616]">Vertex</span>
      <span class="font-bold text-[8.5px] tracking-[0.12em] text-highlighted">Digital Marketing</span>
    </div>
  </div>
</template>
