import { products } from '../../utils/productsData'
import type { Product } from '~/types'

export default eventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  const product = products.find((item: Product) => item.id === id)

  if (!product) {
    throw createError({ statusCode: 404, statusMessage: 'Product not found' })
  }

  return product
})
