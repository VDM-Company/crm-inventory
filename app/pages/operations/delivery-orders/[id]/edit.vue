<script setup lang="ts">
import * as z from 'zod'
import type { DeliveryOrder, DeliveryOrderQuantityItem, DeliveryOrderWorkflowStatus } from '~/types'

const route = useRoute()
const id = computed(() => route.params.id as string)

const { data, status } = await useFetch<DeliveryOrder>(() => `/api/delivery-orders/${id.value}`, {
  lazy: true
})

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
  shippingPolicy: z.string().min(1, 'Shipping policy is required'),
  scheduleAt: z.string().optional(),
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
  shippingPolicy: string
  scheduleAt: string
  products: ProductLine[]
}

const state = reactive<FormState>({
  destination: '',
  sourceLocation: '',
  operationType: '',
  shippingPolicy: '',
  scheduleAt: '',
  products: [{
    productName: '',
    demand: '',
    productCategory: '',
    productStatus: ''
  }]
})

const quantityItems = ref<DeliveryOrderQuantityItem[]>([])
const workflowStatus = ref<DeliveryOrderWorkflowStatus>('Waiting')
const warehouseRef = ref('#WH/OUT/2026/0042')
const confirmOpen = ref(false)
const toast = useToast()
const formReady = ref(false)

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
  { label: 'Delivery Orders', value: 'Delivery Orders' }
]

const shippingPolicyOptions = [
  { label: 'When products are ready', value: 'When products are ready' },
  { label: 'As soon as possible', value: 'As soon as possible' }
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

const totalSum = computed(() => {
  if (quantityItems.value.length) {
    return quantityItems.value.reduce((sum, item) => sum + item.demand, 0)
  }

  return state.products.reduce((sum, product) => {
    const demand = Number(product.demand)
    return sum + (Number.isNaN(demand) ? 0 : demand)
  }, 0)
})

const showReadyAlert = computed(() => workflowStatus.value === 'Waiting')

const canSave = computed(() => schema.safeParse(state).success)

function populateForm(order: DeliveryOrder) {
  state.destination = order.destination
  state.sourceLocation = order.sourceLocation
  state.operationType = order.operationType
  state.shippingPolicy = order.shippingPolicy
  state.scheduleAt = order.scheduleAt ?? ''
  warehouseRef.value = order.warehouseRef
  workflowStatus.value = order.workflowStatus ?? 'Waiting'

  state.products = order.products.length
    ? order.products.map(product => ({
        productName: product.productName,
        demand: String(product.demand),
        productCategory: product.productCategory,
        productStatus: product.productStatus ?? ''
      }))
    : [{
        productName: '',
        demand: '',
        productCategory: '',
        productStatus: ''
      }]

  quantityItems.value = order.quantityItems?.length
    ? [...order.quantityItems]
    : order.products.map((product, index) => ({
        id: String(index + 1),
        productName: product.productName,
        lotSerial: 'N/A',
        demand: product.demand,
        quantity: product.demand,
        stock: 120
      }))

  formReady.value = true
}

watch(data, (order) => {
  if (order) {
    populateForm(order)
  }
}, { immediate: true })

function addProduct() {
  state.products.push({
    productName: '',
    demand: '',
    productCategory: '',
    productStatus: ''
  })
}

function markAsReady() {
  workflowStatus.value = 'Ready'
  toast.add({
    title: 'Marked as Ready',
    description: 'Delivery is ready to finalize',
    color: 'success'
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

function onDeleteQuantity(quantityId: string) {
  quantityItems.value = quantityItems.value.filter(item => item.id !== quantityId)

  toast.add({
    title: 'Deleted',
    description: 'Quantity item removed',
    color: 'success'
  })
}

function saveDraft() {
  toast.add({
    title: 'Draft saved',
    description: 'Delivery order saved as draft',
    color: 'success'
  })
}

function confirmSave() {
  confirmOpen.value = false
  toast.add({
    title: 'Success',
    description: 'Delivery order updated successfully',
    color: 'success'
  })
  navigateTo(`/operations/delivery-orders/${id.value}`)
}
</script>

<template>
  <UDashboardPanel id="delivery-orders-edit">
    <template #body>
      <div
        v-if="status === 'pending' || !formReady"
        class="flex items-center justify-center py-24"
      >
        <UIcon name="i-lucide-loader-circle" class="size-8 animate-spin text-muted" />
      </div>

      <template v-else>
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
              to="/operations/delivery-orders"
              class="text-muted hover:text-highlighted transition-colors"
            >
              Delivery
            </NuxtLink>
            <UIcon name="i-lucide-chevron-right" class="size-3.5 text-dimmed" />
            <span class="font-medium text-primary">Edit Delivery</span>
          </nav>

          <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="flex items-start gap-3">
              <UButton
                icon="i-lucide-arrow-left"
                color="neutral"
                variant="ghost"
                square
                :to="`/operations/delivery-orders/${id}`"
              />

              <div class="space-y-1">
                <h1 class="text-lg font-semibold text-highlighted">
                  Edit Delivery
                </h1>
                <p class="text-base text-muted">
                  Edit delivery for shipping items and products.
                </p>
              </div>
            </div>

            <div class="flex flex-wrap items-center gap-2">
              <UBadge color="neutral" variant="solid" class="rounded-md">
                {{ warehouseRef }}
              </UBadge>
              <UBadge color="neutral" variant="solid" class="rounded-md">
                Total Sum: {{ totalSum }} Product
              </UBadge>
              <UBadge
                :color="workflowStatus === 'Waiting' ? 'warning' : workflowStatus === 'Ready' ? 'info' : 'neutral'"
                variant="subtle"
                class="rounded-md"
              >
                Status: {{ workflowStatus }}
              </UBadge>
            </div>
          </div>

          <div
            v-if="showReadyAlert"
            class="flex flex-col gap-3 rounded-lg bg-info/10 p-4 sm:flex-row sm:items-center sm:justify-between"
          >
            <div class="flex items-center gap-2.5 text-info">
              <UIcon name="i-lucide-info" class="size-5 shrink-0" />
              <p class="text-sm font-medium">
                Mark this delivery as Ready to finalize the delivery
              </p>
            </div>
            <UButton
              label="Mark as Ready"
              color="info"
              class="shrink-0"
              @click="markAsReady"
            />
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

              <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
                <UFormField label="Shipping Policy" name="shippingPolicy" required>
                  <USelect
                    v-model="state.shippingPolicy"
                    :items="shippingPolicyOptions"
                    placeholder="Select one"
                    class="w-full"
                  />
                </UFormField>

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

            <UCard
              :ui="{
                root: 'overflow-hidden',
                body: 'p-0 sm:p-0'
              }"
            >
              <template #header>
                <h2 class="text-lg font-bold text-highlighted">
                  Quantity Management
                </h2>
              </template>

              <OperationsDeliveryQuantityTable
                :data="quantityItems"
                @delete="onDeleteQuantity"
              />
            </UCard>
          </UForm>
        </div>

        <div class="fixed inset-x-0 bottom-0 z-10 border-t border-default bg-default px-4 py-4 sm:px-8">
          <div class="mx-auto flex max-w-6xl items-center justify-end gap-3">
            <UButton
              label="Cancel"
              color="neutral"
              variant="outline"
              :to="`/operations/delivery-orders/${id}`"
            />
            <UButton
              label="Save as Draft"
              color="neutral"
              variant="outline"
              @click="saveDraft"
            />
            <UButton
              label="Save Delivery"
              color="primary"
              :disabled="!canSave"
              @click="openSaveConfirm"
            />
          </div>
        </div>

        <ConfigSaveConfirmModal
          v-model:open="confirmOpen"
          confirm-label="Save Delivery"
          @confirm="confirmSave"
        />
      </template>
    </template>
  </UDashboardPanel>
</template>
