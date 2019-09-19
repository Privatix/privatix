# How to customize offering \(for CLI\)

The offering is a JSON file with all the details about your service offering.

When you create a JSON file with all the necessary settings, you can publish it on Privatix Network to start providing the service. Clients can check and accept your offering from the list of available services \(in Advanced mode\) or via auto selection system \(in Simple mode\).

{% hint style="info" %}
Please note, the Client software in Simple mode will choose the best and cheap offering from the available in the selected country. So if you want to make your offer the first in this queue, you should make the most advantageous offer on the market for the country.
{% endhint %}

###  Offering.json example <a id="configurationobject"></a>

```text
{
  "supply": 10,
  "unitName": "MB",
  "autoPopUp": true,
  "unitType": "units",
  "billingType": "postpaid",
  "setupPrice": 0,
  "unitPrice": 0.0001,
  "minUnits": 1000,
  "maxUnit": 0,
  "billingInterval": 70,
  "maxBillingUnitLag": 100,
  "maxSuspendTime": 1800,
  "freeUnits": 0,
  "ipType": "datacenter",
  "additionalParams": {
    "minDownloadMbits": 100,
    "minUploadMbits": 80,
  }
}
```

### General Parameters:

* `"supply": 10` // Maximum number of clients that can consume this service offering concurrently. 
* `"unitName": "MB"` // Name of single unit of service \(only supported unitName is "MB"\).
* `"autoPopUp": true` // Auto pop up function for this offering. Can be: _true_ or _false._
* `"unitType": "units"` // How the provided service is calculated: _units_ or _seconds_  \(only supported unitType is "units"\).
* `"billingType": "postpaid"` // Model of billing: _postapaid_ or _prepaid_ \(only supported billingType is "postpaid"\).
* `"setupPrice": 0` // Setup fee is a price, that must be paid by Client to start using your service \(only supported setupPrice is "0"\).
* `"unitPrice": 0.0001` // Price in PRIX for a single unit of service.
* `"minUnits": 1000` // The minimum units of service to provide. Used to calculate the minimum deposit required.
* `"maxUnit": 0` // The maximum units of service that will be provided for each contract to Clients. Can be zero \(if maxUnit=0 it means that maxUnit is unlimited\).
* `"billingInterval": 70` // The interval in consumed units of service after which Client must provide payment approval to Agent.
* `"maxBillingUnitLag": 100` // The maximum number of unpaid units of service after which Agent will suspend the service.
* `"maxSuspendTime": 1800` // Maximum time \(seconds\) Agent will wait for Client to continue using the service, before Agent will terminate service.
* `"maxInactiveTime": 1800` // Maximum time \(seconds\) Agent will wait for Client to start using the service for the first time, before Agent will terminate service..
* `"freeUnits": 0` // The amount of first free units of service that you can provide to the Client as a trial \(only supported freeUnits is "0"\).
* `"ipType": "datacenter"` // The type of your IP address. It can be: _datacenter_, _residential_, _mobile_.

{% hint style="warning" %}
When you place an offering on Privatix Network, the smart contract will automatically take a deposit of PRIX tokens from your Marketplace balance in equivalent to your offering price. The deposit will be returned to you when the offering will be closed. 

**Agent deposit = supply \* minUnits \* unitPrice**
{% endhint %}

### Additional Parameters:

* `"minDownloadMbits": 100` // The minimum download speed of your service \(Mbps\). Can be empty.
* `"minUploadMbits": 80` // The maximum upload speed of your service \(Mbps\). Can be empty.

#### 

#### Full description and available parameters can be found here: 

[https://docs.privatix.network/privatix-core/core/messaging/offering/offering-template](https://docs.privatix.network/privatix-core/core/messaging/offering/offering-template)





