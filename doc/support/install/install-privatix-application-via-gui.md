# GUI: Install Privatix Application

## Download Installer

Go to [https://privatix.io](https://privatix.io/#download) website, choose the target OS and download the Installer.

{% hint style="info" %}
If your target OS is Ubuntu, then don't forget to grant the execute permissions to the installer.

Example: "chmod +x privatix\_ubuntu\_x64\_0.23.1\_installer.run"
{% endhint %}

## Install the Application

Pass all the installation steps. 

If you chose an agent mode, then ensure that all required ports are opened.

{% hint style="info" %}
Try to google how to open ports on your particular router.

General information: [https://www.howtogeek.com/66214/how-to-forward-ports-on-your-router/](https://www.howtogeek.com/66214/how-to-forward-ports-on-your-router/)
{% endhint %}

## Replace Infura Endpoint

We use [Infura](https://infura.io) as a Blockchain Access Provider. 

Infura has recently limited the number of requests per day. To prevent an application from crashing due to a request limit, we recommend that you use the application through your own Infura account: [how to change Infura Endpoint](how-to-change-infura-url.md)

## Pass the Wizard

Pass all the wizard's steps one-by-one. 

{% hint style="info" %}
The password that you use is used both for the application's autentification and for encrypting private key.

In case you lose your password, you will lose access to the application and account without the possibility of returning it.
{% endhint %}

 After passing the Wizard you can use the application.







