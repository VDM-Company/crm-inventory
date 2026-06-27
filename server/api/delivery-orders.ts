import { deliveryOrders, toListItem } from '../utils/deliveryOrdersData'

export default eventHandler(async () => {
  return deliveryOrders.map(toListItem)
})
