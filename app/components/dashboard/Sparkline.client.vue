<script setup lang="ts">
import { VisXYContainer, VisLine, VisArea } from '@unovis/vue'

const props = defineProps<{
  data: number[]
  color: string
}>()

const points = computed(() => props.data.map((value, index) => ({ index, value })))

const x = (d: { index: number }) => d.index
const y = (d: { value: number }) => d.value
</script>

<template>
  <VisXYContainer
    :data="points"
    :width="96"
    :height="48"
    :padding="{ top: 4, bottom: 4, left: 2, right: 2 }"
  >
    <VisArea
      :x="x"
      :y="y"
      :color="color"
      :opacity="0.12"
    />
    <VisLine
      :x="x"
      :y="y"
      :color="color"
      :line-width="2"
    />
  </VisXYContainer>
</template>
