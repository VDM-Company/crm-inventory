<script setup lang="ts">
import type { CustomField } from '~/types'

const search = ref('')

const { data, status } = await useFetch<CustomField[]>('/api/fields', {
  lazy: true,
  default: () => []
})

const fields = ref<CustomField[]>([])

watch(data, (value) => {
  if (value) {
    fields.value = [...value]
  }
}, { immediate: true })

const toast = useToast()

function onDeleteField(id: string) {
  fields.value = fields.value.filter(field => field.id !== id)

  toast.add({
    title: 'Deleted',
    description: 'Custom field removed',
    color: 'success'
  })
}
</script>

<template>
  <UDashboardPanel id="config-field">
    <template #header>
      <AppHeader
        title="Configuration"
        subtitle="Configure the quantity field based on your specific requirements."
      >
        <template #right>
          <UButton
            label="Create New Custom Field"
            icon="i-lucide-plus"
            color="primary"
            to="/config/field/create"
          />
        </template>
      </AppHeader>
    </template>

    <template #body>
      <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <UInput
          v-model="search"
          icon="i-lucide-search"
          placeholder="Search field…"
          class="w-full sm:w-64"
        />

        <UButton
          label="Filters"
          icon="i-lucide-list-filter"
          color="neutral"
          variant="outline"
          class="shrink-0"
        />
      </div>

      <ConfigFieldTable
        :data="fields"
        :loading="status === 'pending'"
        :search="search"
        @delete="onDeleteField"
      />
    </template>
  </UDashboardPanel>
</template>
