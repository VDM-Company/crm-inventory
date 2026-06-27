<script setup lang="ts">
const { isNotificationsSlideoverOpen } = useDashboard()
</script>

<template>
  <UDashboardPanel id="dashboard">
    <template #header>
      <AppHeader
        title="Dashboard"
        subtitle="Manage your product inventory and track stock levels."
      >
        <template #right>
          <UTooltip text="Notifications" :shortcuts="['N']">
            <UButton
              color="neutral"
              variant="ghost"
              square
              @click="isNotificationsSlideoverOpen = true"
            >
              <UChip color="error" inset>
                <UIcon name="i-lucide-bell" class="size-5 shrink-0" />
              </UChip>
            </UButton>
          </UTooltip>

          <UButton
            icon="i-lucide-download"
            color="neutral"
            variant="outline"
            label="Download CSV"
          />
        </template>
      </AppHeader>
    </template>

    <template #body>
      <DashboardMetrics />

      <div class="grid grid-cols-1 xl:grid-cols-2 gap-4 sm:gap-6">
        <DashboardLowStock />
        <DashboardIncoming />
      </div>

      <DashboardInventoryTable />
    </template>
  </UDashboardPanel>
</template>
