# How to change Infura Endpoint

We use [Infura](https://infura.io) as a Blockchain Access Provider. 

Infura has recently limited the number of requests per day. To prevent an application from crashing due to a request limit, we recommend that you use the application through your own Infura account.

{% hint style="info" %}
As always, your application can be switched to a Geth Node in the same way as described below.
{% endhint %}

## Step 1. Create Infura Account:

1. Go to [https://infura.io/](https://infura.io/)
2. Register your own account
3. Choose a core subscription plan \(it's free\)

![](../../.gitbook/assets/image%20%281%29.png)

## Step 2. Get Infura Endpoint:

1. Login to the Infura Account
2. Create a project
3. Get the endpoint

![Create new project](../../.gitbook/assets/image%20%289%29.png)

![View Project](../../.gitbook/assets/image%20%287%29.png)

![Get endpoint](../../.gitbook/assets/image%20%2811%29.png)

{% hint style="info" %}
In the case of testnet, choose target network on the screen above. 
{% endhint %}

## Step 3. Replace Endpoint in the config file:

1. Find **dappctrl.config.json**. The path to the configuration depends on which folder you have installed the application in. The relative path will be as follows: `$app_path/client/dappctrl/dappctrl.config.json`
2. Stop the application if it is running
3. Replace `GethURL` value in `dappctrl.config.json`
4. Start the application

![Change GethURL](../../.gitbook/assets/image.png)



