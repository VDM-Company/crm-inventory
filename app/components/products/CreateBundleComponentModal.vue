<script setup lang="ts">
import type { ProductBundleComponent, ProductBundleItem } from '~/types'

const open = defineModel<boolean>('open', { default: false })

const props = defineProps<{
  component?: ProductBundleComponent | null
  productOptions: Array<{ label: string, value: string, name: string, sku: string }>
}>()

const emit = defineEmits<{
  save: [component: Omit<ProductBundleComponent, 'id'> & { id?: string }]
}>()

const name = ref('')
const required = ref('Yes')
const productRows = ref<string[]>([''])

const requiredOptions = [
  { label: 'Yes', value: 'Yes' },
  { label: 'No', value: 'No' }
]

const isValid = computed(() => {
  return name.value.trim() !== '' && productRows.value.some(row => row !== '')
})

function resetForm() {
  name.value = ''
  required.value = 'Yes'
  productRows.value = ['']
}

function loadComponent(component: ProductBundleComponent) {
  name.value = component.name.replace(/ Component$/, '')
  required.value = component.required ? 'Yes' : 'No'
  productRows.value = component.items.map((item) => {
    const match = props.productOptions.find(option => option.sku === item.sku)
    return match?.value ?? ''
  })

  if (!productRows.value.length) {
    productRows.value = ['']
  }
}

watch(open, (value) => {
  if (!value) {
    return
  }

  if (props.component) {
    loadComponent(props.component)
    return
  }

  resetForm()
})

function addProductRow() {
  productRows.value.push('')
}

function removeProductRow(index: number) {
  if (productRows.value.length === 1) {
    productRows.value[0] = ''
    return
  }

  productRows.value.splice(index, 1)
}

function save() {
  if (!isValid.value) {
    return
  }

  const existingItems = props.component?.items ?? []
  const items: ProductBundleItem[] = productRows.value
    .filter(row => row !== '')
    .map((row, index) => {
      const option = props.productOptions.find(item => item.value === row)

      return {
        name: option?.name ?? row,
        sku: option?.sku ?? row,
        quantity: existingItems[index]?.quantity ?? 1
      }
    })

  emit('save', {
    id: props.component?.id,
    name: name.value.trim().endsWith(' Component')
      ? name.value.trim()
      : `${name.value.trim()} Component`,
    required: required.value === 'Yes',
    items
  })

  open.value = false
}
</script>

<template>
  <UModal
    v-model:open="open"
    title="Create Component"
    :ui="{ content: 'max-w-md' }"
  >
    <template #body>
      <div class="space-y-4">
        <UFormField label="Component Name">
          <UInput
            v-model="name"
            placeholder="Input here"
            class="w-full"
          />
        </UFormField>

        <UFormField label="Required">
          <USelect
            v-model="required"
            :items="requiredOptions"
            class="w-full"
          />
        </UFormField>

        <div class="space-y-3">
          <p class="text-sm font-semibold text-highlighted">
            Add Product
          </p>

          <div
            v-for="(row, index) in productRows"
            :key="index"
            class="flex items-center gap-2"
          >
            <USelect
              v-model="productRows[index]"
              :items="productOptions"
              placeholder="Select product"
              class="w-full"
            />
            <UButton
              icon="i-lucide-trash-2"
              color="neutral"
              variant="outline"
              square
              @click="removeProductRow(index)"
            />
          </div>

          <UButton
            label="Add Product"
            icon="i-lucide-plus"
            color="primary"
            variant="outline"
            block
            @click="addProductRow"
          />
        </div>

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
