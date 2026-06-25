<script setup lang="ts">
import type { NavigationMenuItem } from '@nuxt/ui'

const open = ref(false)

const links = [[{
  label: 'Inventory',
  icon: 'i-lucide-archive',
  defaultOpen: true,
  type: 'trigger',
  children: [{
    label: 'Dashboard',
    icon: 'i-lucide-layout-dashboard',
    to: '/',
    exact: true,
    onSelect: () => {
      open.value = false
    }
  }, {
    label: 'Product',
    icon: 'i-lucide-package',
    to: '/product',
    onSelect: () => {
      open.value = false
    }
  }, {
    label: 'Operations',
    icon: 'i-lucide-workflow',
    to: '/operations',
    onSelect: () => {
      open.value = false
    }
  }]
}, {
  label: 'Orders',
  icon: 'i-lucide-shopping-bag',
  type: 'trigger',
  children: [{
    label: 'All Orders',
    to: '/orders',
    onSelect: () => {
      open.value = false
    }
  }]
}, {
  label: 'Billing',
  icon: 'i-lucide-credit-card',
  type: 'trigger',
  children: [{
    label: 'Invoices',
    to: '/billing',
    onSelect: () => {
      open.value = false
    }
  }]
}]] satisfies NavigationMenuItem[][]

const groups = computed(() => [{
  id: 'links',
  label: 'Go to',
  items: links.flat()
}])
</script>

<template>
  <UDashboardGroup unit="rem">
    <UDashboardSidebar
      id="default"
      v-model:open="open"
      collapsible
      resizable
      class="bg-default"
      :ui="{
        header: 'h-16 border-b border-default',
        footer: 'border-t border-default'
      }"
    >
      <template #header="{ collapsed }">
        <AppLogo :collapsed="collapsed" />
      </template>

      <template #default="{ collapsed }">
        <UNavigationMenu
          :collapsed="collapsed"
          :items="links[0]"
          orientation="vertical"
          tooltip
          popover
        />
      </template>

      <template #footer="{ collapsed }">
        <UserMenu :collapsed="collapsed" />
      </template>
    </UDashboardSidebar>

    <UDashboardSearch :groups="groups" />

    <slot />

    <NotificationsSlideover />
  </UDashboardGroup>
</template>
