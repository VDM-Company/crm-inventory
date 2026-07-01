<script setup lang="ts">
withDefaults(defineProps<{
  count?: number
}>(), {
  count: 0
})

const open = ref(false)

async function onSubmit() {
  await new Promise(resolve => setTimeout(resolve, 1000))
  open.value = false
}
</script>

<template>
  <div>
    <div @click="open = true">
      <slot />
    </div>

    <DeleteConfirmModal
      v-model:open="open"
      :title="count > 1 ? `Are you sure want to delete ${count} customers?` : 'Are you sure want to delete this data?'"
      @confirm="onSubmit"
    />
  </div>
</template>
