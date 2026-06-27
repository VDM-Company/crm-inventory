<script setup lang="ts">
import type { ProductQuantityItem, ProductQuantityStatus } from '~/types'

const open = defineModel<boolean>('open', { default: false })

const emit = defineEmits<{
  create: [item: Omit<ProductQuantityItem, 'id'>]
}>()

const location = ref('WH/Stock')
const imei = ref('')
const iccid = ref('')
const msnNumber = ref('')
const vendor = ref('VDM')
const status = ref<ProductQuantityStatus>('Ready')

const locationOptions = [
  { label: 'WH/Stock', value: 'WH/Stock' },
  { label: 'Tokyo Warehouse', value: 'Tokyo Warehouse' }
]

const vendorOptions = [
  { label: 'VDM', value: 'VDM' },
  { label: 'VDN', value: 'VDN' },
  { label: 'VDO', value: 'VDO' }
]

const statusOptions = [
  { label: 'Ready', value: 'Ready' },
  { label: 'Pending', value: 'Pending' },
  { label: 'Draft', value: 'Draft' }
]

const toast = useToast()

function resetForm() {
  location.value = 'WH/Stock'
  imei.value = ''
  iccid.value = ''
  msnNumber.value = ''
  vendor.value = 'VDM'
  status.value = 'Ready'
}

function createQuantity() {
  if (!imei.value.trim() || !iccid.value.trim() || !msnNumber.value.trim()) {
    toast.add({
      title: 'Validation error',
      description: 'Please fill in Imei, ICCID, and MSN Number',
      color: 'error'
    })
    return
  }

  emit('create', {
    location: location.value,
    imei: imei.value.trim(),
    iccid: iccid.value.trim(),
    msnNumber: msnNumber.value.trim(),
    activationCode: imei.value.trim().slice(-9),
    vendor: vendor.value,
    status: status.value
  })

  open.value = false
  resetForm()
}

watch(open, (value) => {
  if (!value) {
    resetForm()
  }
})
</script>

<template>
  <UModal
    v-model:open="open"
    :ui="{ content: 'max-w-md' }"
  >
    <template #body>
      <div class="space-y-4">
        <div class="flex items-start justify-between gap-3">
          <h2 class="text-lg font-semibold text-highlighted">
            Create product quantity
          </h2>
        </div>

        <UFormField label="Location">
          <USelect
            v-model="location"
            :items="locationOptions"
            class="w-full"
          />
        </UFormField>

        <UFormField label="Imei">
          <UInput
            v-model="imei"
            placeholder="002415515616"
            class="w-full"
          />
        </UFormField>

        <UFormField label="ICCID">
          <UInput
            v-model="iccid"
            placeholder="245151616166"
            class="w-full"
          />
        </UFormField>

        <UFormField label="MSN Number">
          <UInput
            v-model="msnNumber"
            placeholder="081256677899"
            class="w-full"
          />
        </UFormField>

        <UFormField label="Vendor">
          <USelect
            v-model="vendor"
            :items="vendorOptions"
            class="w-full"
          />
        </UFormField>

        <UFormField label="Status">
          <USelect
            v-model="status"
            :items="statusOptions"
            class="w-full"
          />
        </UFormField>

        <div class="flex items-center justify-end gap-3 pt-2">
          <UButton
            label="Cancel"
            color="neutral"
            variant="outline"
            @click="open = false"
          />
          <UButton
            label="Create"
            color="primary"
            @click="createQuantity"
          />
        </div>
      </div>
    </template>
  </UModal>
</template>
