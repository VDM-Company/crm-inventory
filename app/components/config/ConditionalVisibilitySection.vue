<script setup lang="ts">
import type { CustomFieldCondition } from '~/types'

const conditions = defineModel<CustomFieldCondition[]>('conditions', { default: () => [] })

const toast = useToast()

const fieldOptions = [
  { label: 'Product Type', value: 'Product Type' },
  { label: 'Product Status', value: 'Product Status' },
  { label: 'Category', value: 'Category' },
  { label: 'Company', value: 'Company' },
  { label: 'Platform', value: 'Platform' }
]

const operatorOptions = [
  { label: 'Is equal to', value: 'Is equal to' },
  { label: 'Is not equal to', value: 'Is not equal to' },
  { label: 'Contains', value: 'Contains' },
  { label: 'Does not contain', value: 'Does not contain' }
]

const canSaveCondition = computed(() =>
  conditions.value.length > 0
  && conditions.value.every(condition =>
    condition.field && condition.operator && condition.value
  )
)

function addCondition() {
  conditions.value.push({
    field: '',
    operator: '',
    value: ''
  })
}

function removeCondition(index: number) {
  conditions.value.splice(index, 1)
}

function saveCondition() {
  if (!canSaveCondition.value) {
    return
  }

  toast.add({
    title: 'Conditions saved',
    description: 'Conditional visibility rules saved',
    color: 'success'
  })
}
</script>

<template>
  <UCard>
    <template #header>
      <div class="flex w-full items-center justify-between gap-3">
        <div class="flex items-center gap-2">
          <h2 class="text-base font-semibold text-highlighted">
            Conditional Visibility
          </h2>
          <UBadge
            variant="subtle"
            color="neutral"
            class="text-[10px]"
          >
            Optional
          </UBadge>
        </div>

        <UButton
          label="Save Condition"
          color="neutral"
          variant="outline"
          size="sm"
          :disabled="!canSaveCondition"
          @click="saveCondition"
        />
      </div>
    </template>

    <div
      v-if="conditions.length === 0"
      class="flex flex-col items-center gap-3 py-8 text-center"
    >
      <div class="flex items-center justify-center size-12 rounded-full bg-elevated">
        <UIcon name="i-lucide-git-branch" class="size-6 text-dimmed" />
      </div>
      <p class="text-sm text-muted">
        No conditions added yet
      </p>
      <UButton
        label="Add First Condition"
        icon="i-lucide-plus"
        color="neutral"
        variant="outline"
        @click="addCondition"
      />
    </div>

    <div
      v-else
      class="space-y-3"
    >
      <div class="rounded-xl border border-dashed border-default bg-elevated/50 p-4 space-y-3">
        <div
          v-for="(condition, index) in conditions"
          :key="index"
          class="grid grid-cols-1 gap-3 rounded-xl border border-default bg-default p-4 md:grid-cols-[1fr_1fr_1fr_auto]"
        >
          <USelect
            v-model="condition.field"
            :items="fieldOptions"
            placeholder="Select one"
            class="w-full"
          />

          <USelect
            v-model="condition.operator"
            :items="operatorOptions"
            placeholder="Select one"
            class="w-full"
          />

          <UInput
            v-model="condition.value"
            placeholder="Enter Value..."
            class="w-full"
          />

          <UButton
            v-if="conditions.length > 1"
            icon="i-lucide-trash-2"
            color="neutral"
            variant="ghost"
            square
            class="self-center"
            @click="removeCondition(index)"
          />
        </div>
      </div>

      <UButton
        label="Add Another Condition"
        icon="i-lucide-plus"
        color="neutral"
        variant="outline"
        block
        @click="addCondition"
      />
    </div>
  </UCard>
</template>
