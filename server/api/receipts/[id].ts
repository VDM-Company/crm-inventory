import { receipts } from '../../utils/receiptsData'
import type { Receipt } from '~/types'

export default eventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  const receipt = receipts.find((item: Receipt) => item.id === id)

  if (!receipt) {
    throw createError({ statusCode: 404, statusMessage: 'Receipt not found' })
  }

  return receipt
})
