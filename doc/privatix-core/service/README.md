# Service

Privatix core can be used to provide different services. Core operation is generic and doesn't depend on particular service. Some possible scenarios of service can be video steaming, VoIP calls, water, electricity, etc. Any service, that can be sold in portions and usage verified independently by seller and buyer is a good candidate for being based on Privatix Network. Some of generic features that may be applicable to any service that sold without 3rd party and already included in Privatix core:

* payment automation
* service life-cycle automation
* billing
* reporting
* smart contracts
* payment token
* etc.

Instead of developing each time application that will provide single service and implement bunch of generic functionality, we decided to create generic platform, that can be extended for any service.

Each service that uses Privatix Network, will contain at least:

1. Service adapter - software that provides service
2. Offering template - template for service offering
3. Access template - template for service access 

Offering can be extended with any number of fields, that is needed for service.

Access message, also can pass any arbitrary data from provider to consumer.

All preliminary communication before Client starts to consume a service is done by Privatix core engine. This should greatly simplify development of DApps and usually will implement:

* service provisioning
* usage reporting
* start of usage
* stop of usage

