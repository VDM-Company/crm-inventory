<script setup lang="ts">
interface HistoryEvent {
  title: string
  timestamp: string
  latest?: boolean
  badge?: string
}

const open = defineModel<boolean>('open', { default: false })

const events: HistoryEvent[] = [{
  title: 'Approve to adjust On Hand Stock',
  timestamp: 'Feb 10, 2026, 09:30 PM · Nobita (Manager)',
  latest: true,
  badge: 'New Update'
}, {
  title: 'On hand stock sycn with Counted',
  timestamp: 'Feb 10, 2026, 05:00 PM · Shizuka (Shipping Team)'
}, {
  title: 'On hand stock sycn with Counted',
  timestamp: 'Feb 10, 2026, 05:00 PM · Shizuka (Shipping Team)'
}, {
  title: 'Product Created',
  timestamp: 'Feb 10, 2026, 05:00 PM · Naruto Uzumaki (Marketing)'
}]
</script>

<template>
  <UModal
    v-model:open="open"
    :ui="{ content: 'max-w-md' }"
  >
    <template #content>
      <div class="flex flex-col gap-6 p-5">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2">
            <UIcon name="i-lucide-clock" class="size-6 text-highlighted" />
            <h2 class="text-base font-semibold text-highlighted">
              History
            </h2>
            <span class="text-sm text-dimmed">({{ events.length }} events)</span>
          </div>

          <UButton
            icon="i-lucide-x"
            color="neutral"
            variant="ghost"
            size="sm"
            square
            @click="open = false"
          />
        </div>

        <div class="relative flex flex-col gap-8">
          <div class="absolute left-[5px] top-[33px] bottom-[33px] w-px bg-default" />

          <div
            v-for="(event, index) in events"
            :key="index"
            class="relative flex items-center gap-[18px]"
          >
            <span
              class="relative z-10 size-3 shrink-0 rounded-full border-[1.5px]"
              :class="event.latest ? 'bg-info border-info' : 'bg-elevated border-default'"
            />

            <div class="flex flex-1 flex-col gap-1.5 rounded-xl border border-default bg-elevated p-3">
              <div class="flex items-center gap-1.5">
                <p class="text-sm font-medium text-highlighted">
                  {{ event.title }}
                </p>
                <span
                  v-if="event.badge"
                  class="rounded-md bg-info/10 px-1 py-0.5 text-[8px] font-medium leading-3 text-info"
                >
                  {{ event.badge }}
                </span>
              </div>

              <p class="text-xs text-muted">
                {{ event.timestamp }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </template>
  </UModal>
</template>
