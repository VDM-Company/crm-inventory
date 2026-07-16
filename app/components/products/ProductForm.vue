<script setup lang="ts">
import * as z from 'zod'
import type { Product, ProductBundleComponent, ProductPricing, ProductStatus } from '~/types'

const props = withDefaults(defineProps<{
  mode?: 'create' | 'edit'
  product?: Product | null
  cancelTo?: string
  submitLabel?: string
  breadcrumbCurrent?: string
}>(), {
  mode: 'create',
  product: null,
  cancelTo: '/products',
  submitLabel: 'Create New Product',
  breadcrumbCurrent: 'Create New Product'
})

const emit = defineEmits<{
  save: []
  draft: []
}>()

const schema = z.object({
  name: z.string().min(1, 'Product name is required'),
  sku: z.string().min(1, 'SKU is required'),
  reference: z.string().min(1, 'Reference is required'),
  productType: z.string().min(1, 'Product type is required'),
  settingsCategory: z.string().min(1, 'Category is required'),
  company: z.string().min(1, 'Company is required'),
  status: z.string().min(1, 'Product status is required'),
  platform: z.string().min(1, 'Platform is required'),
  trackedBy: z.string().min(1, 'Tracked by is required')
})

interface FormState {
  name: string
  sku: string
  reference: string
  productType: string
  notes: string
  settingsCategory: string
  company: string
  status: ProductStatus
  platform: string
  published: boolean
  trackInventory: boolean
  trackedBy: string
}

const state = reactive<FormState>({
  name: '',
  sku: '',
  reference: '',
  productType: '',
  notes: '',
  settingsCategory: '',
  company: '',
  status: 'Active',
  platform: '',
  published: true,
  trackInventory: true,
  trackedBy: ''
})

const pricing = ref<ProductPricing[]>([])
const bundleComponents = ref<ProductBundleComponent[]>([])
const pricingModalOpen = ref(false)
const bundleModalOpen = ref(false)
const editingBundleComponent = ref<ProductBundleComponent | null>(null)
const toast = useToast()

const productTypeOptions = [
  { label: 'Single', value: 'Single' },
  { label: 'Dual', value: 'Dual' },
  { label: 'Bundling', value: 'Bundling' }
]

const bundleProductOptions = [
  { label: 'Nec Device', value: 'nec', name: 'Nec Device', sku: 'nec_device_sku' },
  { label: 'X4 Device', value: 'x4', name: 'Nec Device', sku: 'x4_device_sku' },
  { label: 'Docomo 1GB', value: 'docomo', name: 'Docomo 1GB', sku: 'd_1gb_device_sku' },
  { label: 'Softbank 1GB', value: 'softbank', name: 'Softbank 1GB', sku: 's_1gb_device_sku' }
]

const categoryOptions = ref([
  { label: 'SIM Cards', value: 'SIM Cards' },
  { label: 'eSIMs', value: 'eSIMs' },
  { label: 'Devices', value: 'Devices' },
  { label: 'Accessories', value: 'Accessories' },
  { label: 'Packaging/Boxes', value: 'Packaging/Boxes' },
  { label: 'Booklet/Pamphlet', value: 'Booklet/Pamphlet' }
])

const companyOptions = ref([
  { label: 'VDM', value: 'VDM' },
  { label: 'Globiz', value: 'Globiz' },
  { label: 'Mashup', value: 'Mashup' }
])

const statusOptions = ref([
  { label: 'Active', value: 'Active' },
  { label: 'Inactive', value: 'Inactive' },
  { label: 'Draft', value: 'Draft' },
  { label: 'Discontinued', value: 'Discontinued' }
])

const statusColorMap: Record<ProductStatus, 'primary' | 'neutral' | 'error'> = {
  Active: 'primary',
  Inactive: 'neutral',
  Draft: 'neutral',
  Discontinued: 'error'
}

type CreateField = 'category' | 'company' | 'status'

const createModalOpen = ref(false)
const createField = ref<CreateField | null>(null)

const createModalTitle = computed(() => {
  if (createField.value === 'category') {
    return 'Create a new category'
  }

  if (createField.value === 'company') {
    return 'Create a new company'
  }

  if (createField.value === 'status') {
    return 'Create a new status'
  }

  return ''
})

function openCreateModal(field: CreateField) {
  createField.value = field
  createModalOpen.value = true
}

function onCreateOption(name: string) {
  if (createField.value === 'category') {
    categoryOptions.value.push({ label: name, value: name })
    state.settingsCategory = name
  } else if (createField.value === 'company') {
    companyOptions.value.push({ label: name, value: name })
    state.company = name
  } else if (createField.value === 'status') {
    statusOptions.value.push({ label: name, value: name as ProductStatus })
    state.status = name as ProductStatus
  }
}

const platformOptions = [
  { label: 'SK', value: 'SK' },
  { label: 'Docomo', value: 'Docomo' }
]

const trackedByOptions = [
  { label: 'Unique Serial Number', value: 'Unique Serial Number' },
  { label: 'Lot', value: 'Lot' }
]

const nextPriceVersion = computed(() => {
  const count = pricing.value.length
  return `V.${count + 1}`
})

function applyProduct(product: Product) {
  state.name = product.name
  state.sku = product.sku
  state.reference = product.reference
  state.productType = product.productType
  state.notes = product.notes ?? ''
  state.settingsCategory = product.settingsCategory
  state.company = product.company
  state.status = product.status
  state.platform = product.platform
  state.published = product.published
  state.trackInventory = product.trackInventory
  state.trackedBy = product.trackedBy
  pricing.value = [...product.pricing]
  bundleComponents.value = product.bundle
    ? product.bundle.components.map(component => ({
        ...component,
        items: component.items.map(item => ({ ...item }))
      }))
    : []
}

watch(() => props.product, (product) => {
  if (product) {
    applyProduct(product)
  }
}, { immediate: true })

function validateForm() {
  const result = schema.safeParse({
    name: state.name,
    sku: state.sku,
    reference: state.reference,
    productType: state.productType,
    settingsCategory: state.settingsCategory,
    company: state.company,
    status: state.status,
    platform: state.platform,
    trackedBy: state.trackedBy
  })

  if (!result.success) {
    toast.add({
      title: 'Validation error',
      description: result.error.issues[0]?.message ?? 'Please fill in all required fields',
      color: 'error'
    })
    return false
  }

  return true
}

function requestSave() {
  if (!validateForm()) {
    return
  }

  emit('save')
}

function requestDraft() {
  emit('draft')
}

function addPricing(payload: Omit<ProductPricing, 'id' | 'statusSince'> & { statusSince?: string }) {
  pricing.value.push({
    id: String(Date.now()),
    priceVersion: payload.priceVersion,
    monthlyFee: payload.monthlyFee,
    initialFee: payload.initialFee,
    status: payload.status,
    statusSince: payload.statusSince ?? 'Since Apr 24, 2026',
    pricingType: payload.pricingType,
    pricingPlan: payload.pricingPlan,
    depositFee: payload.depositFee,
    activationMethod: payload.activationMethod,
    activationStartDate: payload.activationStartDate,
    pricingActive: payload.pricingActive
  })
}

function openCreateBundleComponent() {
  editingBundleComponent.value = null
  bundleModalOpen.value = true
}

function openEditBundleComponent(component: ProductBundleComponent) {
  editingBundleComponent.value = component
  bundleModalOpen.value = true
}

function onSaveBundleComponent(payload: Omit<ProductBundleComponent, 'id'> & { id?: string }) {
  if (payload.id) {
    const index = bundleComponents.value.findIndex(component => component.id === payload.id)

    if (index >= 0) {
      bundleComponents.value[index] = {
        id: payload.id,
        name: payload.name,
        required: payload.required,
        items: payload.items
      }
    }

    return
  }

  bundleComponents.value.push({
    id: String(Date.now()),
    name: payload.name,
    required: payload.required,
    items: payload.items
  })
}

function onDeleteBundleComponent(id: string) {
  bundleComponents.value = bundleComponents.value.filter(component => component.id !== id)
}
</script>

<template>
  <div class="mx-auto flex w-full max-w-6xl flex-col gap-6 pb-24">
    <nav class="flex items-center gap-1.5 text-sm">
      <NuxtLink
        :to="cancelTo"
        class="text-muted hover:text-highlighted transition-colors"
      >
        Product
      </NuxtLink>
      <UIcon name="i-lucide-chevron-right" class="size-3.5 text-dimmed" />
      <span class="font-medium text-highlighted">{{ breadcrumbCurrent }}</span>
    </nav>

    <div class="flex items-start gap-3">
      <UButton
        icon="i-lucide-arrow-left"
        color="neutral"
        variant="ghost"
        square
        :to="cancelTo"
      />

      <div class="space-y-1">
        <h1 class="text-lg font-semibold text-highlighted">
          {{ breadcrumbCurrent }}
        </h1>
        <p class="text-sm text-muted">
          {{ mode === 'edit' ? 'Update product data and information' : 'Create new product for tracking the data and information' }}
        </p>
      </div>
    </div>

    <div class="grid grid-cols-1 gap-6 lg:grid-cols-[1fr_320px]">
      <div class="space-y-6">
        <UCard>
          <template #header>
            <p class="text-base font-semibold text-highlighted">
              Core Identification
            </p>
          </template>

          <div class="space-y-4">
            <UFormField label="Product Name" required>
              <UInput
                v-model="state.name"
                placeholder="input here"
                class="w-full"
              />
            </UFormField>

            <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
              <UFormField label="SKU" required>
                <UInput
                  v-model="state.sku"
                  placeholder="input here"
                  class="w-full"
                />
              </UFormField>

              <UFormField label="No Reference" required>
                <UInput
                  v-model="state.reference"
                  placeholder="input here"
                  class="w-full"
                />
              </UFormField>
            </div>

            <UFormField label="Product Type" required>
              <USelect
                v-model="state.productType"
                :items="productTypeOptions"
                placeholder="Select one"
                class="w-full"
              />
            </UFormField>

            <UFormField>
              <template #label>
                <span>Notes </span>
                <span class="text-dimmed font-normal">(Optional)</span>
              </template>
              <UTextarea
                v-model="state.notes"
                placeholder="input here"
                :rows="3"
                class="w-full"
              />
            </UFormField>

            <UFormField>
              <template #label>
                <span>Image </span>
                <span class="text-dimmed font-normal">(Optional)</span>
              </template>
              <div class="flex flex-col items-center justify-center gap-2 rounded-xl border border-dashed border-default px-6 py-10 text-center">
                <UIcon name="i-lucide-image-plus" class="size-8 text-dimmed" />
                <p class="text-sm font-medium text-highlighted">
                  Upload product image
                </p>
                <p class="text-xs text-muted">
                  PNG, JPG up to 5MB
                </p>
                <UButton
                  label="Browse File"
                  color="neutral"
                  variant="outline"
                  size="sm"
                />
              </div>
            </UFormField>
          </div>
        </UCard>

        <UCard>
          <template #header>
            <p class="text-base font-semibold text-highlighted">
              Inventory
            </p>
          </template>

          <div class="space-y-4">
            <div class="flex items-center justify-between gap-4 rounded-xl border border-default p-3">
              <div>
                <p class="text-base font-medium text-highlighted">
                  Track Inventory
                </p>
                <p class="text-sm text-muted">
                  Enable stock tracking for this product
                </p>
              </div>
              <USwitch v-model="state.trackInventory" />
            </div>

            <UFormField label="Tracked By" required>
              <USelect
                v-model="state.trackedBy"
                :items="trackedByOptions"
                placeholder="Select one"
                class="w-full"
              />
            </UFormField>
          </div>
        </UCard>

        <ProductsBundleFormSection
          v-model:components="bundleComponents"
          @create="openCreateBundleComponent"
          @edit="openEditBundleComponent"
          @delete="onDeleteBundleComponent"
        />

        <UCard>
          <template #header>
            <div class="flex items-center justify-between gap-3">
              <p class="text-base font-semibold text-highlighted">
                Pricing
              </p>
              <UButton
                label="Add Price Set"
                icon="i-lucide-plus"
                color="neutral"
                variant="outline"
                size="sm"
                @click="pricingModalOpen = true"
              />
            </div>
          </template>

          <ProductsProductPricingTable :data="pricing" />
        </UCard>
      </div>

      <UCard class="h-fit">
        <template #header>
          <p class="text-base font-semibold text-highlighted">
            Settings
          </p>
        </template>

        <div class="space-y-4">
          <UFormField label="Category" required>
            <div class="flex items-center gap-2">
              <USelect
                v-model="state.settingsCategory"
                :items="categoryOptions"
                placeholder="Select one"
                class="w-full"
              />
              <UButton
                icon="i-lucide-plus"
                color="neutral"
                variant="outline"
                square
                @click="openCreateModal('category')"
              />
            </div>
          </UFormField>

          <UFormField label="Company" required>
            <div class="flex items-center gap-2">
              <USelect
                v-model="state.company"
                :items="companyOptions"
                placeholder="Select one"
                class="w-full"
              />
              <UButton
                icon="i-lucide-plus"
                color="neutral"
                variant="outline"
                square
                @click="openCreateModal('company')"
              />
            </div>
          </UFormField>

          <UFormField label="Product Status" required>
            <div class="flex items-center gap-2">
              <USelect
                v-model="state.status"
                :items="statusOptions"
                placeholder="Select one"
                class="w-full"
              >
                <template #item="{ item }">
                  <UBadge
                    variant="subtle"
                    :color="statusColorMap[item.value as ProductStatus]"
                    class="text-[10px]"
                  >
                    {{ item.label }}
                  </UBadge>
                </template>
              </USelect>
              <UButton
                icon="i-lucide-plus"
                color="neutral"
                variant="outline"
                square
                @click="openCreateModal('status')"
              />
            </div>
          </UFormField>

          <UFormField label="Platform" required>
            <div class="flex items-center gap-2">
              <USelect
                v-model="state.platform"
                :items="platformOptions"
                placeholder="Select one"
                class="w-full"
              />
              <UButton
                icon="i-lucide-plus"
                color="neutral"
                variant="outline"
                square
              />
            </div>
          </UFormField>

          <div class="flex items-center justify-between gap-4 rounded-xl border border-default p-3">
            <div>
              <p class="text-base font-medium text-highlighted">
                Published
              </p>
              <p class="text-sm text-muted">
                Product visible to customers
              </p>
            </div>
            <USwitch v-model="state.published" />
          </div>
        </div>
      </UCard>
    </div>

    <div class="fixed inset-x-0 bottom-0 z-10 border-t border-default bg-default px-4 py-4 sm:px-8">
      <div class="mx-auto flex max-w-6xl items-center justify-end gap-3">
        <UButton
          label="Cancel"
          color="neutral"
          variant="outline"
          :to="cancelTo"
        />
        <UButton
          label="Save as Draft"
          color="neutral"
          variant="outline"
          @click="requestDraft"
        />
        <UButton
          :label="submitLabel"
          color="primary"
          @click="requestSave"
        />
      </div>
    </div>

    <ProductsAddPricingModal
      v-model:open="pricingModalOpen"
      :next-version="nextPriceVersion"
      @save="addPricing"
    />

    <ProductsCreateSelectOptionModal
      v-model:open="createModalOpen"
      :title="createModalTitle"
      @save="onCreateOption"
    />

    <ProductsCreateBundleComponentModal
      v-model:open="bundleModalOpen"
      :component="editingBundleComponent"
      :product-options="bundleProductOptions"
      @save="onSaveBundleComponent"
    />
  </div>
</template>
