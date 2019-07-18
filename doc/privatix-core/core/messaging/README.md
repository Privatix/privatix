# Messaging

## **How it works today**

In centralized world, Buyer usually surfs the web, then goes to Seller's web-site, study various pages, somehow get pricing via site or by contacting sales. Then, he register's on web-site and sets a password, that will be used to consume a service. Afterwards he downloads a client software, that has preconfigured addresses of servers, various software settings. He logs-in using credentials, he has set up previously. If it is a web-service, he consume service via browser, but still need to understand terms and pricing and setup credentials. Looks not so complicated, but still terms and process are always custom for each provider.

**What's wrong with this process**

1. Buyer not sure, that he know all terms, even after he spent a lot of time researching providers web-site. 
2. Offerings for the same service are different, such that buyer cannot compare prices directly.
3. No single place to discover and compare all offerings.
4. Offering discovery is centralized. We are using search provider \(Google, Facebook, etc.\) and letting our search provider to know what we are looking for. Browsing providers web-sites also give ability to identify your intention.

**What seller need**

* Get all offerings in one place, but only for service he is interested in.
* Compare offering for the same service from different providers easily. What if sellers of each service will standardize their offerings?
* Know some basic history about provider's deals. Is he new or has a lot of happy customers?
* Get access to the service as simple as possible. Without email confirmations, without remembering a password, etc.

**Our approach**

As a buyer, if you want to consume a service, you would download DApp that allows you to:

* Get offerings from all providers in single interface
* Compare between offerings easily as they are standardized for particular service
* Clearly understand terms. Offering include strictly defined billing rules. You always know how service is measured, how it is billed and what will happen, if you delay a payment or doesn't use service for a long time. This offering data is cryptographically signed by provider and registered in blockchain. No way to say "You didn't understand our sales representative correctly."
* Stop using service any moment and do not have to cancel subscription.
* Do not have to go through custom and complicated process of chargeback.

  **Let's simplify it**

Seller need to get offerings. Check that they comply with a standard.

After Seller accepted offering he should get credentials, servers addresses, configuration parameters, etc. Briefly, all data that he need to start using a service.

## Messages

In Privatix Network decentralized environment Client need to get two basic things:

1. Client should get offering from Agent.
2. If Client accepts Agent's offering, then he need details about, how to start consuming a service.

There are two messages that passed from Agent to Client:

* [offering message](offering/) - filled and signed by Agent according to [offering template](offering/offering-template.md)
* [access message](access/) - filled, encrypted and signed according to [access template](access/access-template.md)

`Template` is a standardized schema of message, that may contain different values, but strictly according to the schema. Each message can be validated to comply with a schema.

Client communicates with Agent to:

* get offerings
* get access messages

Offerings and Access messages can be retrieved from Agent via different [transports](transport.md).

## Offering message

[Offering ](offering/)retrieved by Client in two steps:

1. Ethereum events notify Client about new or actualized offerings
2. Client get offering data directly from Agent

## Access message

[Access ](access/)retrieved by Client:

1. Ethereum event notify Client about offering acceptance registration
2. Client get access data directly from Agent

