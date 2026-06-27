<script setup lang="ts">
import * as z from 'zod'

const productSchema = z.object({
  productName: z.string().min(1, 'Product name is required'),
  demand: z.coerce.number().min(1, 'Demand is required'),
  productCategory: z.string().min(1, 'Product category is required'),
  productStatus: z.string().optional()
})

const schema = z.object({
  destination: z.string().min(1, 'Destination is required'),
  sourceLocation: z.string().min(1, 'Source location is required'),
  operationType: z.string().min(1, 'Operation type is required'),
  scheduleAt: z.string().optional(),
  notes: z.string().optional(),
  products: z.array(productSchema).min(1, 'Add at least one product')
})

interface ProductLine {
  productName: string
  demand: string
  productCategory: string
  productStatus: string
}

interface FormState {
  destination: string
  sourceLocation: string
  operationType: string
  scheduleAt: string
  notes: string
  products: ProductLine[]
}

const state = reactive<FormState>({
  destination: '',
  sourceLocation: '',
  operationType: 'Receipts',
  scheduleAt: '',
  notes: '',
  products: [{
    productName: '',
    demand: '',
    productCategory: '',
    productStatus: ''
  }]
})

const confirmOpen = ref(false)
const draftConfirmOpen = ref(false)
const toast = useToast()
const warehouseRef = '#WH/IN/2026/0042'

const destinationOptions = [
  { label: 'Partner/Customer', value: 'Partner/Customer' },
  { label: 'Tokyo Warehouse', value: 'Tokyo Warehouse' },
  { label: 'Osaka Branch', value: 'Osaka Branch' }
]

const sourceLocationOptions = [
  { label: 'WH/Stock', value: 'WH/Stock' },
  { label: 'Tokyo Warehouse', value: 'Tokyo Warehouse' }
]

const operationTypeOptions = [
  { label: 'Receipts', value: 'Receipts' }
]

const productNameOptions = [
  { label: 'Docomo SIM CARD 50GB', value: 'Docomo SIM CARD 50GB' },
  { label: 'Softbank SIM CARD 20GB', value: 'Softbank SIM CARD 20GB' }
]

const productCategoryOptions = [
  { label: 'SIM Card', value: 'SIM Card' },
  { label: 'Accessories', value: 'Accessories' }
]

const productStatusOptions = [
  { label: 'Ready', value: 'Ready' },
  { label: 'Pending', value: 'Pending' }
]

const productCount = computed(() => {
  return state.products.filter(product => product.productName).length
})

const canSave = computed(() => schema.safeParse(state).success)

function addProduct() {
  state.products.push({
    productName: '',
    demand: '',
    productCategory: '',
    productStatus: ''
  })
}

function openSaveConfirm() {
  const result = schema.safeParse(state)

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

function openDraftConfirm() {
  draftConfirmOpen.value = true
}

function confirmDraft() {
  draftConfirmOpen.value = false
  toast.add({
    title: 'Draft saved',
    description: 'Receipt saved as draft',
    color: 'success'
  })
}

function confirmSave() {
  confirmOpen.value = false
  toast.add({
    title: 'Success',
    description: 'Receipt saved successfully',
    color: 'success'
  })
  navigateTo('/operations/receipts')
}
</script>

<template>
  <UDashboardPanel id="receipts-create">
    <template #body>
      <div class="mx-auto flex w-full max-w-6xl flex-col gap-6 pb-24">
        <nav class="flex items-center gap-1.5 text-sm">
          <NuxtLink
            to="/operations"
            class="text-muted hover:text-highlighted transition-colors"
          >
            Operations
          </NuxtLink>
          <UIcon name="i-lucide-chevron-right" class="size-3.5 text-dimmed" />
          <NuxtLink
            to="/operations/receipts"
            class="text-muted hover:text-highlighted transition-colors"
          >
            Receipts
          </NuxtLink>
          <UIcon name="i-lucide-chevron-right" class="size-3.5 text-dimmed" />
          <span class="font-medium text-primary">Create New Receipts</span>
        </nav>

        <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
          <div class="flex items-start gap-3">
            <UButton
              icon="i-lucide-arrow-left"
              color="neutral"
              variant="ghost"
              square
              to="/operations/receipts"
            />

            <div class="space-y-1">
              <h1 class="text-lg font-semibold text-highlighted">
                Create New Receipts
              </h1>
              <p class="text-base text-muted">
                Create new receipt for inbound shipments and products.
              </p>
            </div>
          </div>

          <div class="flex flex-wrap items-center gap-2">
            <UBadge color="neutral" variant="solid" class="rounded-md">
              {{ warehouseRef }}
            </UBadge>
            <UBadge color="neutral" variant="solid" class="rounded-md">
              Total Sum: {{ productCount }} Product
            </UBadge>
            <UBadge color="neutral" variant="subtle" class="rounded-md">
              Status: Draft
            </UBadge>
          </div>
        </div>

        <UForm
          :schema="schema"
          :state="state"
          class="space-y-6"
        >
          <UCard>
            <template #header>
              <h2 class="text-lg font-bold text-highlighted">
                General Information
              </h2>
            </template>

            <div class="grid grid-cols-1 gap-4 md:grid-cols-3">
              <UFormField label="Destination/Location" name="destination" required>
                <USelect
                  v-model="state.destination"
                  :items="destinationOptions"
                  placeholder="Select one"
                  class="w-full"
                />
              </UFormField>

              <UFormField label="Source Location" name="sourceLocation" required>
                <USelect
                  v-model="state.sourceLocation"
                  :items="sourceLocationOptions"
                  placeholder="Select one"
                  class="w-full"
                />
              </UFormField>

              <UFormField label="Operation Type" name="operationType" required>
                <USelect
                  v-model="state.operationType"
                  :items="operationTypeOptions"
                  placeholder="Select one"
                  class="w-full"
                />
              </UFormField>
            </div>
          </UCard>

          <UCard>
            <template #header>
              <h2 class="text-lg font-bold text-highlighted">
                Additional Information
              </h2>
            </template>

            <div class="space-y-4">
              <UFormField name="scheduleAt">
                <template #label>
                  <span>Schedule at </span>
                  <span class="text-dimmed font-normal">(Optional)</span>
                </template>
                <UInput
                  v-model="state.scheduleAt"
                  type="date"
                  icon="i-lucide-calendar"
                  placeholder="Pick a date"
                  class="w-full max-w-md"
                />
              </UFormField>

              <UFormField name="notes">
                <template #label>
                  <span>Notes </span>
                  <span class="text-dimmed font-normal">(Optional)</span>
                </template>
                <UTextarea
                  v-model="state.notes"
                  placeholder="Input notes here"
                  :rows="4"
                  class="w-full"
                />
              </UFormField>
            </div>
          </UCard>

          <UCard>
            <template #header>
              <div class="flex items-center justify-between gap-4">
                <h2 class="text-lg font-bold text-highlighted">
                  Product Information
                </h2>
                <UButton
                  label="Add Product"
                  icon="i-lucide-plus"
                  color="primary"
                  variant="outline"
                  @click="addProduct"
                />
              </div>
            </template>

            <div class="space-y-6">
              <div
                v-for="(product, index) in state.products"
                :key="index"
                class="grid grid-cols-1 gap-4 md:grid-cols-4"
              >
                <UFormField
                  :name="`products.${index}.productName`"
                  label="Product Name"
                  required
                >
                  <USelect
                    v-model="product.productName"
                    :items="productNameOptions"
                    placeholder="input here"
                    class="w-full"
                  />
                </UFormField>

                <UFormField
                  :name="`products.${index}.demand`"
                  label="Demand"
                  required
                >
                  <UInput
                    v-model="product.demand"
                    type="number"
                    min="1"
                    placeholder="input here"
                    class="w-full"
                  />
                </UFormField>

                <UFormField
                  :name="`products.${index}.productCategory`"
                  label="Product Category"
                  required
                >
                  <USelect
                    v-model="product.productCategory"
                    :items="productCategoryOptions"
                    placeholder="Select one"
                    class="w-full"
                  />
                </UFormField>

                <UFormField :name="`products.${index}.productStatus`">
                  <template #label>
                    <span>Set Product Status To </span>
                    <span class="text-dimmed font-normal">(Optional)</span>
                  </template>
                  <USelect
                    v-model="product.productStatus"
                    :items="productStatusOptions"
                    placeholder="Select one"
                    class="w-full"
                  />
                </UFormField>
              </div>
            </div>
          </UCard>
        </UForm>
      </div>

      <div class="fixed inset-x-0 bottom-0 z-10 border-t border-default bg-default px-4 py-4 sm:px-8">
        <div class="mx-auto flex max-w-6xl items-center justify-end gap-3">
          <UButton
            label="Cancel"
            color="neutral"
            variant="outline"
            to="/operations/receipts"
          />
          <UButton
            label="Save as Draft"
            color="neutral"
            variant="outline"
            @click="openDraftConfirm"
          />
          <UButton
            label="Save Receipt"
            color="primary"
            :disabled="!canSave"
            @click="openSaveConfirm"
          />
        </div>
      </div>

      <ConfigSaveConfirmModal
        v-model:open="draftConfirmOpen"
        confirm-label="Save as Draft"
        @confirm="confirmDraft"
      />

      <ConfigSaveConfirmModal
        v-model:open="confirmOpen"
        confirm-label="Save Receipt"
        @confirm="confirmSave"
      />
    </template>
  </UDashboardPanel>
</template>
