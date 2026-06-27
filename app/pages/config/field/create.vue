<script setup lang="ts">
import * as z from 'zod'
import type { CustomFieldType } from '~/types'

const conditionSchema = z.object({
  field: z.string().min(1, 'Field is required'),
  operator: z.string().min(1, 'Operator is required'),
  value: z.string().min(1, 'Value is required')
})

const schema = z.object({
  label: z.string().min(1, 'Field label is required'),
  fieldType: z.enum(['Text', 'Date', 'Number', 'Dropdown']),
  fieldLocation: z.string().min(1, 'Field location is required'),
  fieldSection: z.string().min(1, 'Field section is required'),
  description: z.string().optional(),
  markAsRequired: z.boolean(),
  conditionalVisibilityEnabled: z.boolean(),
  conditionalVisibility: z.array(conditionSchema)
}).superRefine((data, ctx) => {
  if (data.conditionalVisibilityEnabled && data.conditionalVisibility.length === 0) {
    ctx.addIssue({
      code: 'custom',
      message: 'Add at least one condition',
      path: ['conditionalVisibility']
    })
  }
})

type Schema = z.output<typeof schema>

const state = reactive<Schema>({
  label: '',
  fieldType: 'Text',
  fieldLocation: '',
  fieldSection: '',
  description: '',
  markAsRequired: false,
  conditionalVisibilityEnabled: false,
  conditionalVisibility: []
})

const confirmOpen = ref(false)
const toast = useToast()

const fieldTypeIcons: Record<CustomFieldType, string> = {
  Text: 'i-lucide-type',
  Date: 'i-lucide-calendar',
  Number: 'i-lucide-hash',
  Dropdown: 'i-lucide-chevron-down'
}

const fieldTypeOptions = [
  { label: 'Text', value: 'Text' },
  { label: 'Date', value: 'Date' },
  { label: 'Number', value: 'Number' },
  { label: 'Dropdown', value: 'Dropdown' }
]

const fieldLocationOptions = [
  { label: 'Create New Product Page', value: 'Create New Product Page' },
  { label: 'Product Activation', value: 'Product Activation' },
  { label: 'Delivery', value: 'Delivery' }
]

const fieldSectionOptions = [
  { label: 'Add Product Quantity Modal', value: 'Add Product Quantity Modal' },
  { label: 'Add Delivery', value: 'Add Delivery' }
]

watch(() => state.conditionalVisibilityEnabled, (enabled) => {
  if (!enabled) {
    state.conditionalVisibility = []
  }
})

function openSaveConfirm() {
  const payload = {
    ...state,
    conditionalVisibility: state.conditionalVisibilityEnabled
      ? state.conditionalVisibility
      : []
  }

  const result = schema.safeParse(payload)

  if (!result.success) {
    toast.add({
      title: 'Validation error',
      description: result.error.issues[0]?.message ?? 'Please fill in all required fields',
      color: 'error'
    })
    return
  }

  confirmOpen.value = true
}

function saveDraft() {
  toast.add({
    title: 'Draft saved',
    description: 'Custom field saved as draft',
    color: 'success'
  })
}

function confirmSave() {
  confirmOpen.value = false
  toast.add({
    title: 'Success',
    description: 'Custom field saved successfully',
    color: 'success'
  })
  navigateTo('/config/field')
}
</script>

<template>
  <UDashboardPanel id="config-field-create">
    <template #body>
      <div class="mx-auto flex w-full max-w-3xl flex-col gap-6 pb-24">
        <nav class="flex items-center gap-1.5 text-sm">
          <NuxtLink
            to="/config/field"
            class="text-muted hover:text-highlighted transition-colors"
          >
            Configuration
          </NuxtLink>
          <UIcon name="i-lucide-chevron-right" class="size-3.5 text-dimmed" />
          <span class="font-medium text-highlighted">Create Custom Field</span>
        </nav>

        <div class="flex items-start gap-3">
          <UButton
            icon="i-lucide-arrow-left"
            color="neutral"
            variant="ghost"
            square
            to="/config/field"
          />

          <div class="space-y-1">
            <h1 class="text-lg font-semibold text-highlighted">
              Create Custom Field
            </h1>
            <p class="text-sm text-muted">
              Create custom fields to customize based specifications.
            </p>
          </div>
        </div>

        <UForm
          :schema="schema"
          :state="state"
          class="space-y-6"
        >
          <UCard>
            <template #header>
              <h2 class="text-base font-semibold text-highlighted">
                Basic Information
              </h2>
            </template>

            <div class="space-y-4">
              <UFormField label="Custom Field Label" name="label" required>
                <UInput
                  v-model="state.label"
                  placeholder="Enter field label"
                  class="w-full"
                />
              </UFormField>

              <UFormField label="Field Type" name="fieldType" required>
                <div class="flex items-center gap-2">
                  <UBadge
                    variant="subtle"
                    color="neutral"
                    class="gap-1 shrink-0"
                  >
                    <UIcon :name="fieldTypeIcons[state.fieldType]" class="size-3" />
                    {{ state.fieldType }}
                  </UBadge>
                  <USelect
                    v-model="state.fieldType"
                    :items="fieldTypeOptions"
                    class="flex-1"
                  />
                </div>
              </UFormField>

              <UFormField label="Field Location" name="fieldLocation" required>
                <USelect
                  v-model="state.fieldLocation"
                  :items="fieldLocationOptions"
                  placeholder="Select field location"
                  class="w-full"
                />
              </UFormField>

              <UFormField label="Field Section" name="fieldSection" required>
                <USelect
                  v-model="state.fieldSection"
                  :items="fieldSectionOptions"
                  placeholder="Select field section"
                  class="w-full"
                />
              </UFormField>

              <UFormField label="Description" name="description">
                <UTextarea
                  v-model="state.description"
                  placeholder="Input description here"
                  class="w-full"
                  :rows="3"
                />
              </UFormField>

              <UFormField name="markAsRequired">
                <div class="space-y-2">
                  <div class="flex items-center justify-between gap-4">
                    <span class="text-sm font-medium text-highlighted">Mark as required</span>
                    <USwitch v-model="state.markAsRequired" />
                  </div>
                  <p class="text-sm text-muted">
                    If enabled, users cannot submit the form without filling this field.
                  </p>
                </div>
              </UFormField>

              <UFormField name="conditionalVisibilityEnabled">
                <div class="space-y-2">
                  <span class="text-sm font-medium text-highlighted">Conditional Visibility</span>
                  <div class="flex items-center gap-2">
                    <USwitch v-model="state.conditionalVisibilityEnabled" />
                    <span
                      v-if="state.conditionalVisibilityEnabled"
                      class="text-sm text-muted"
                    >
                      Yes
                    </span>
                  </div>
                </div>
              </UFormField>
            </div>
          </UCard>

          <ConfigConditionalVisibilitySection
            v-if="state.conditionalVisibilityEnabled"
            v-model:conditions="state.conditionalVisibility"
          />
        </UForm>
      </div>

      <div class="fixed inset-x-0 bottom-0 z-10 border-t border-default bg-default px-4 py-4 sm:px-8">
        <div class="mx-auto flex max-w-3xl items-center justify-end gap-3">
          <UButton
            label="Cancel"
            color="neutral"
            variant="outline"
            to="/config/field"
          />
          <UButton
            label="Save as Draft"
            color="neutral"
            variant="outline"
            @click="saveDraft"
          />
          <UButton
            label="Save Data"
            color="primary"
            @click="openSaveConfirm"
          />
        </div>
      </div>

      <ConfigSaveConfirmModal
        v-model:open="confirmOpen"
        @confirm="confirmSave"
      />
    </template>
  </UDashboardPanel>
</template>
