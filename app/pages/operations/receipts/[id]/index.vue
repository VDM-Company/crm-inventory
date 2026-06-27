<script setup lang="ts">
import type { Receipt } from '~/types'

const route = useRoute()
const id = computed(() => route.params.id as string)

const { data, status } = await useFetch<Receipt>(() => `/api/receipts/${id.value}`, {
  lazy: true
})

const toast = useToast()

function onDelete() {
  toast.add({
    title: 'Deleted',
    description: 'Receipt deleted successfully',
    color: 'success'
  })
  navigateTo('/operations/receipts')
}
</script>

<template>
  <UDashboardPanel id="receipts-detail">
    <template #body>
      <div
        v-if="status === 'pending'"
        class="flex items-center justify-center py-24"
      >
        <UIcon name="i-lucide-loader-circle" class="size-8 animate-spin text-muted" />
      </div>

      <div
        v-else-if="data"
        class="mx-auto flex w-full max-w-6xl flex-col gap-6"
      >
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
          <span class="font-medium text-primary">Detail Receipts</span>
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
                Detail Receipts
              </h1>
              <p class="text-base text-muted">
                See detail receipts information here
              </p>
            </div>
          </div>

          <div class="flex flex-wrap items-center gap-3">
            <UButton
              label="Delete"
              icon="i-lucide-trash-2"
              color="error"
              variant="outline"
              @click="onDelete"
            />
            <UButton
              label="Edit"
              icon="i-lucide-pencil"
              color="neutral"
              variant="outline"
              :to="`/operations/receipts/${id}/edit`"
            />
          </div>
        </div>

        <UCard>
          <template #header>
            <h2 class="text-lg font-bold text-highlighted">
              General Information
            </h2>
          </template>

          <div class="grid grid-cols-1 gap-6 md:grid-cols-3">
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Destination/Location
              </p>
              <p class="text-sm text-highlighted">
                {{ data.destination }}
              </p>
            </div>
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Source Location
              </p>
              <p class="text-sm text-highlighted">
                {{ data.sourceLocation }}
              </p>
            </div>
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Operation Type
              </p>
              <p class="text-sm text-highlighted">
                {{ data.operationType }}
              </p>
            </div>
          </div>
        </UCard>

        <UCard>
          <template #header>
            <h2 class="text-lg font-bold text-highlighted">
              Additional Information
            </h2>
          </template>

          <div class="grid grid-cols-1 gap-6">
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Schedule at
              </p>
              <p class="text-sm text-highlighted">
                {{ data.scheduleAt ?? '—' }}
              </p>
            </div>
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Notes
              </p>
              <p class="text-sm text-highlighted">
                {{ data.notes || '—' }}
              </p>
            </div>
          </div>
        </UCard>

        <UCard>
          <template #header>
            <h2 class="text-lg font-bold text-highlighted">
              Product Information
            </h2>
          </template>

          <div
            v-if="!data.products.length"
            class="py-6 text-sm text-muted"
          >
            No products added.
          </div>

          <div
            v-for="(product, index) in data.products"
            :key="index"
            class="grid grid-cols-1 gap-6 md:grid-cols-4"
            :class="{ 'mt-6 border-t border-default pt-6': index > 0 }"
          >
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Product Name
              </p>
              <p class="text-sm text-highlighted">
                {{ product.productName }}
              </p>
            </div>
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Demand
              </p>
              <p class="text-sm text-highlighted">
                {{ product.demand }}
              </p>
            </div>
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Product Category
              </p>
              <p class="text-sm text-highlighted">
                {{ product.productCategory }}
              </p>
            </div>
            <div class="space-y-2">
              <p class="text-sm font-semibold text-highlighted">
                Set Product Status To <span class="font-normal text-dimmed">(Optional)</span>
              </p>
              <UBadge
                v-if="product.productStatus"
                variant="subtle"
                color="info"
                class="text-xs"
              >
                {{ product.productStatus }}
              </UBadge>
              <p
                v-else
                class="text-sm text-muted"
              >
                —
              </p>
            </div>
          </div>
        </UCard>
      </div>
    </template>
  </UDashboardPanel>
</template>
