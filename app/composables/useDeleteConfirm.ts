export function useDeleteConfirm<T>(onConfirm: (value: T) => void) {
  const open = ref(false)
  const pending = ref<T | null>(null)

  function request(value: T) {
    pending.value = value
    open.value = true
  }

  function confirm() {
    if (pending.value !== null && pending.value !== undefined) {
      onConfirm(pending.value)
    }

    pending.value = null
    open.value = false
  }

  function cancel() {
    pending.value = null
    open.value = false
  }

  return {
    open,
    pending,
    request,
    confirm,
    cancel
  }
}
