const templateId = 'efc61769-96c8-4c0d-b50a-e4d11fc30523';

const random_names = ['First', 'Second', 'Third'];

export const generateOffering =
  (
    productId: string,
    agentId: string,
    offeringName: string
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
    'billingInterval': 1,
    'maxBillingUnitLag': 3,
    'maxSuspendTime': 1800,
    'maxInactiveTimeSec': 1800,
    'freeUnits': 0,
    'additionalParams': {
      'minDownloadMbits': 100,
      'minUploadMbits': 80
    },
    'autoPopUp': false
  });

export const generateSomeOfferings =
  (productId: string, agentId: string) => {
    return random_names
      .map(name =>
        generateOffering(productId, agentId, `${name} Service`))
  };
