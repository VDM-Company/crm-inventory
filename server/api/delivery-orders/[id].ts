import { deliveryOrders } from '../../utils/deliveryOrdersData'
import type { DeliveryOrder } from '~/types'

export default eventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  const order = deliveryOrders.find((item: DeliveryOrder) => item.id === id)

  if (!order) {
    throw createError({ statusCode: 404, statusMessage: 'Delivery order not found' })
  }

  return order
})
