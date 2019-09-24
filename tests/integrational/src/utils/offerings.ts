const random_names = ['First', 'Second', 'Third'];

export const generateOffering =
  (
    productId: string,
    agentId: string,
    offeringName: string,
    templateId: string
  ) => ({
    'product': productId,
    'template': templateId,
    'agent': agentId,
    'serviceName': offeringName,
    'description': `${offeringName} description`,
    'country': 'KG',
    'supply': 3,
    'unitName': 'MB',
    'unitType': 'units',
    'billingType': 'postpaid',
    'setupPrice': 0,
    'unitPrice': 100000,
    'minUnits': 100,
    'maxUnit': 200,
    'deposit': 3*100000*100,
    'billingInterval': 1,
    'maxBillingUnitLag': 3,
    'maxSuspendTime': 1800,
    'maxInactiveTimeSec': 1800,
    'freeUnits': 0,
    'additionalParams': {
      'minDownloadMbits': 100,
      'minUploadMbits': 80
    },
    'autoPopUp': false,
    'iptype': 'residential'
  });

export const generateSomeOfferings =
  (productId: string, agentId: string, templateId: string) => {
    return random_names
      .map(name =>
        generateOffering(productId, agentId, `${name} Service`, templateId))
  };
