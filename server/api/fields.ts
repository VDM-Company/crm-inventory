import type { CustomField } from '~/types'

const fields: CustomField[] = [{
  id: '1',
  label: 'Activation Code',
  fieldType: 'Text',
  fieldLocation: 'Product Activation',
  section: 'Add Product Quantity Modal',
  required: false,
  visibility: true
}, {
  id: '2',
  label: 'Batch Expiry',
  fieldType: 'Date',
  fieldLocation: 'Delivery',
  section: 'Add Delivery',
  required: false,
  visibility: true
}, {
  id: '3',
  label: 'ICCID',
  fieldType: 'Number',
  fieldLocation: 'Product Activation',
  section: 'Add Product Quantity Modal',
  required: false,
  visibility: true
}, {
  id: '4',
  label: 'Product Category',
  fieldType: 'Dropdown',
  fieldLocation: 'Product Activation',
  section: 'Add Product Quantity Modal',
  required: false,
  visibility: true
}]

export default eventHandler(async () => {
  return fields
})
