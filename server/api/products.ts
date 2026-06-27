import { products, toProductListItem } from '../utils/productsData'

export default eventHandler(async () => {
  return products.map(toProductListItem)
})
