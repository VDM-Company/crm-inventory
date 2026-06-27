<script setup lang="ts">
const transferFeatures = [{
  title: 'Delivery Orders',
  description: 'Manage outbond deliveries.',
  icon: 'i-lucide-truck',
  to: '/operations/delivery-orders'
}, {
  title: 'Receipts',
  description: 'Manage inbound shipments.',
  icon: 'i-lucide-receipt',
  to: '/operations/receipts'
}]

const adjustmentFeatures = [{
  title: 'Physical Inventory',
  description: 'Manage stock and product quantity.',
  icon: 'i-lucide-archive',
  to: '/operations/physical-inventory'
}]
</script>

<template>
  <UDashboardPanel id="operations">
    <template #header>
      <AppHeader
        title="Operations Menu"
        subtitle="See related few features with Operations"
      />
    </template>

    <template #body>
      <section class="space-y-3">
        <h2 class="text-lg font-semibold text-highlighted">
          Transfer
        </h2>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
          <OperationsFeatureCard
            v-for="feature in transferFeatures"
            :key="feature.title"
            v-bind="feature"
          />
        </div>
      </section>

      <section class="space-y-3">
        <h2 class="text-lg font-semibold text-highlighted">
          Adjustment
        </h2>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
          <OperationsFeatureCard
            v-for="feature in adjustmentFeatures"
            :key="feature.title"
            v-bind="feature"
          />
        </div>
      </section>
    </template>
  </UDashboardPanel>
</template>
