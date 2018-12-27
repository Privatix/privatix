# Client billing

[Client billing](https://github.com/Privatix/dappctrl/tree/master/client/bill) runs periodically SQL query for live `channels`, send payments and creates `jobs`.

Billing responsible for:

1. Service payment

   - Send payments. It compares actual usage (converted to tokens) to last sent payment amount and sends payments, if necessary.

   Payment frequency is controlled by offering [billingFrequency](/doc/offering.md#Offering-template-schema) (aka BillingInterval) parameter.

2. Service aging

   - Termination of services, that was suspended longer that [maxSuspendTime](/doc/offering.md#Offering-template-schema) for corresponding offering. It prevents client from occupating service without using it for indefinite time. Same operation is performed on Agent side. Thus it is done to keep service state synchronized between Agent and Client.
