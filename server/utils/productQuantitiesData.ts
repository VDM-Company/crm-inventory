import type { ProductQuantityItem } from '~/types'

const baseItems: Omit<ProductQuantityItem, 'id'>[] = [{
  location: 'WH/Stock',
  imei: '002415515616',
  iccid: '245151616166',
  msnNumber: '081256677899',
  activationCode: '099921566',
  vendor: 'VDM',
  status: 'Ready'
}, {
  location: 'WH/Stock',
  imei: '003215517618',
  iccid: '345151617168',
  msnNumber: '091256677901',
  activationCode: '199921568',
  vendor: 'VDN',
  status: 'Ready'
}, {
  location: 'WH/Stock',
  imei: '004115519619',
  iccid: '445151618169',
  msnNumber: '101256677902',
  activationCode: '299921569',
  vendor: 'VDO',
  status: 'Ready'
}, {
  location: 'WH/Stock',
  imei: '005115520620',
  iccid: '545151619170',
  msnNumber: '111256677903',
  activationCode: '399921570',
  vendor: 'VDM',
  status: 'Ready'
}, {
  location: 'WH/Stock',
  imei: '006115521621',
  iccid: '645151620171',
  msnNumber: '121256677904',
  activationCode: '499921571',
  vendor: 'VDN',
  status: 'Ready'
}, {
  location: 'WH/Stock',
  imei: '007115522622',
  iccid: '745151621172',
  msnNumber: '131256677905',
  activationCode: '599921572',
  vendor: 'VDO',
  status: 'Ready'
}, {
  location: 'WH/Stock',
  imei: '008115523623',
  iccid: '845151622173',
  msnNumber: '141256677906',
  activationCode: '699921573',
  vendor: 'VDM',
  status: 'Ready'
}, {
  location: 'WH/Stock',
  imei: '009115524624',
  iccid: '945151623174',
  msnNumber: '151256677907',
  activationCode: '799921574',
  vendor: 'VDN',
  status: 'Ready'
}, {
  location: 'WH/Stock',
  imei: '010115525625',
  iccid: '105151624175',
  msnNumber: '161256677908',
  activationCode: '899921575',
  vendor: 'VDO',
  status: 'Ready'
}, {
  location: 'WH/Stock',
  imei: '011115526626',
  iccid: '115151625176',
  msnNumber: '171256677909',
  activationCode: '999921576',
  vendor: 'VDM',
  status: 'Ready'
}]

export function getProductQuantities(productId: string): ProductQuantityItem[] {
  if (productId !== '1') {
    return []
  }

  return baseItems.map((item, index) => ({
    id: String(index + 1),
    ...item
  }))
}
