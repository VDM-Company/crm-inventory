import { getProductQuantities } from '../../../utils/productQuantitiesData'

export default eventHandler(async (event) => {
  const id = getRouterParam(event, 'id')

  if (!id) {
    throw createError({ statusCode: 400, statusMessage: 'Product id is required' })
  }

  return getProductQuantities(id)
})
