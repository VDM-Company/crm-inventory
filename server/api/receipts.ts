import { receipts, toReceiptListItem } from '../utils/receiptsData'

export default eventHandler(async () => {
  return receipts.map(toReceiptListItem)
})
