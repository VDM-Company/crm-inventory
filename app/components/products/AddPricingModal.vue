<script setup lang="ts">
import { CalendarDate, getLocalTimeZone } from '@internationalized/date'
import { format } from 'date-fns'
import type { ProductPricing, ProductPricingType } from '~/types'

const open = defineModel<boolean>('open', { default: false })

const emit = defineEmits<{
  save: [pricing: Omit<ProductPricing, 'id' | 'statusSince'> & { statusSince?: string }]
}>()

const props = defineProps<{
  nextVersion: string
}>()

const pricingType = ref<ProductPricingType>('Subscription')
const pricingPlan = ref('SK SIM Plan')
const monthlyFee = ref('20000')
const initialFee = ref('1000')
const depositFee = ref('1000')
const activationMethod = ref<'scheduled' | 'immediate'>('immediate')
const startDate = shallowRef(new CalendarDate(2026, 6, 1))
const inputDate = useTemplateRef('inputDate')
const pricingActive = ref(true)

const pricingPlanOptions = [
  { label: 'SK SIM Plan', value: 'SK SIM Plan' },
  { label: 'VDM Data Plan', value: 'VDM Data Plan' }
]

function resetForm() {
  pricingType.value = 'Subscription'
  pricingPlan.value = 'SK SIM Plan'
  monthlyFee.value = '20000'
  initialFee.value = '1000'
  depositFee.value = '1000'
  activationMethod.value = 'immediate'
  startDate.value = new CalendarDate(2026, 6, 1)
  pricingActive.value = true
}

function formatFee(value: string) {
  const amount = Number(value.replace(/\D/g, ''))
  if (!amount) {
    return '¥0 JYP'
  }
  return `¥${amount.toLocaleString('en-US')} JYP`
}

function formatStartDate(date: CalendarDate) {
  return format(date.toDate(getLocalTimeZone()), 'dd/MM/yyyy')
}

function savePrice() {
  emit('save', {
    priceVersion: props.nextVersion,
    monthlyFee: formatFee(monthlyFee.value),
    initialFee: formatFee(initialFee.value),
    status: pricingActive.value ? 'Active' : 'Inactive',
    pricingType: pricingType.value,
    pricingPlan: pricingPlan.value,
    depositFee: formatFee(depositFee.value),
    activationMethod: activationMethod.value,
    activationStartDate: activationMethod.value === 'scheduled'
      ? formatStartDate(startDate.value)
      : undefined,
    pricingActive: pricingActive.value
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
    :ui="{ content: 'max-w-lg' }"
  >
    <template #body>
      <div class="space-y-4">
        <div class="flex items-start justify-between gap-3">
          <h2 class="text-lg font-semibold text-highlighted">
            Add Pricing
          </h2>
        </div>

        <UFormField label="Price Version">
          <UInput
            :model-value="nextVersion"
            disabled
            class="w-full opacity-75"
          />
        </UFormField>

        <div class="space-y-2">
          <p class="text-sm font-semibold text-highlighted">
            Pricing Type
          </p>
          <div class="grid grid-cols-2 gap-3">
            <button
              type="button"
              class="flex items-center gap-2 rounded-xl border p-3 text-left transition-colors"
              :class="pricingType === 'Subscription' ? 'border-primary' : 'border-default'"
              @click="pricingType = 'Subscription'"
            >
              <span
                class="size-4 rounded-full border flex items-center justify-center"
                :class="pricingType === 'Subscription' ? 'border-primary bg-primary' : 'border-default'"
              >
                <span
                  v-if="pricingType === 'Subscription'"
                  class="size-1.5 rounded-full bg-default"
                />
              </span>
              <span class="text-sm font-medium">Subcription</span>
            </button>
            <button
              type="button"
              class="flex items-center gap-2 rounded-xl border p-3 text-left transition-colors"
              :class="pricingType === 'One Time Payment' ? 'border-primary' : 'border-default'"
              @click="pricingType = 'One Time Payment'"
            >
              <span
                class="size-4 rounded-full border flex items-center justify-center"
                :class="pricingType === 'One Time Payment' ? 'border-primary bg-primary' : 'border-default'"
              >
                <span
                  v-if="pricingType === 'One Time Payment'"
                  class="size-1.5 rounded-full bg-default"
                />
              </span>
              <span class="text-sm font-medium">One Time Payment</span>
            </button>
          </div>
        </div>

        <UFormField label="Pricing Plan">
          <USelect
            v-model="pricingPlan"
            :items="pricingPlanOptions"
            class="w-full"
          />
        </UFormField>

        <UFormField label="Monthly Fee">
          <UInput
            v-model="monthlyFee"
            icon="i-lucide-japanese-yen"
            class="w-full"
          />
        </UFormField>

        <UFormField label="Initial Fee">
          <UInput
            v-model="initialFee"
            icon="i-lucide-japanese-yen"
            class="w-full"
          />
        </UFormField>

        <UFormField label="Deposit Fee">
          <UInput
            v-model="depositFee"
            icon="i-lucide-japanese-yen"
            class="w-full"
          />
        </UFormField>

        <div class="space-y-2">
          <p class="text-sm font-semibold text-highlighted">
            Activation Method
          </p>
          <div class="space-y-3">
            <button
              type="button"
              class="w-full rounded-xl border p-3 text-left transition-colors"
              :class="activationMethod === 'scheduled' ? 'border-primary' : 'border-default'"
              @click="activationMethod = 'scheduled'"
            >
              <div class="flex items-start gap-2">
                <span
                  class="mt-0.5 size-4 shrink-0 rounded-full border flex items-center justify-center"
                  :class="activationMethod === 'scheduled' ? 'border-primary bg-primary' : 'border-default'"
                >
                  <span
                    v-if="activationMethod === 'scheduled'"
                    class="size-1.5 rounded-full bg-default"
                  />
                </span>
                <div>
                  <p class="text-sm font-medium">
                    Schedule a Date
                  </p>
                  <p class="text-sm text-muted">
                    Price actives automatically on chosen day
                  </p>
                  <div
                    v-if="activationMethod === 'scheduled'"
                    class="mt-3"
                    @click.stop
                  >
                    <UFormField label="Start Date">
                      <UInputDate
                        ref="inputDate"
                        v-model="startDate"
                        class="w-full"
                      >
                        <template #trailing>
                          <UPopover :reference="inputDate?.inputsRef[3]?.$el">
                            <UButton
                              color="neutral"
                              variant="link"
                              size="sm"
                              icon="i-lucide-calendar"
                              aria-label="Select a date"
                              class="px-0"
                            />

                            <template #content>
                              <UCalendar
                                v-model="startDate"
                                class="p-2"
                              />
                            </template>
                          </UPopover>
                        </template>
                      </UInputDate>
                    </UFormField>
                  </div>
                </div>
              </div>
            </button>
            <button
              type="button"
              class="w-full rounded-xl border p-3 text-left transition-colors"
              :class="activationMethod === 'immediate' ? 'border-primary' : 'border-default'"
              @click="activationMethod = 'immediate'"
            >
              <div class="flex items-start gap-2 border-b border-default pb-2">
                <span
                  class="mt-0.5 size-4 shrink-0 rounded-full border flex items-center justify-center"
                  :class="activationMethod === 'immediate' ? 'border-primary bg-primary' : 'border-default'"
                >
                  <span
                    v-if="activationMethod === 'immediate'"
                    class="size-1.5 rounded-full bg-default"
                  />
                </span>
                <div>
                  <p class="text-sm font-medium">
                    Activate immediately
                  </p>
                  <p class="text-sm text-muted">
                    Price goes live the moment you save
                  </p>
                </div>
              </div>
              <div
                v-if="activationMethod === 'immediate'"
                class="mt-3 flex items-center gap-2 rounded-md bg-success/10 px-2 py-1.5 text-sm font-medium text-success"
              >
                <UIcon name="i-lucide-circle-check" class="size-4 shrink-0" />
                This price will be live immediately after saving.
              </div>
            </button>
          </div>
        </div>

        <div class="rounded-xl border border-default p-3">
          <div class="flex items-center justify-between gap-4">
            <div>
              <p class="text-base font-medium text-highlighted">
                Pricing active
              </p>
              <p class="text-sm text-muted">
                Price is live for customers
              </p>
            </div>
            <USwitch v-model="pricingActive" />
          </div>
        </div>

        <div class="flex items-center justify-end gap-3 pt-2">
          <UButton
            label="Cancel"
            color="neutral"
            variant="outline"
            @click="open = false"
          />
          <UButton
            label="Save Price"
            color="primary"
            @click="savePrice"
          />
        </div>
      </div>
    </template>
  </UModal>
</template>
