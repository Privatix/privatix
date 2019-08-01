# CLI: Install Privatix Agent Node to a DigitalOcean cloud

## Prepare a virtual machine <a id="InstallPrivatixAgentnode(viaCLi)toDigitalOceancloud-Prepareavirtualmachine"></a>

Minimum system requirements:

* 2GB of RAM
* 2 vCPU
* OS: Ubuntu 16.04 LTS / Ubuntu 18.04 LTS

### Create a droplet <a id="InstallPrivatixAgentnode(viaCLi)toDigitalOceancloud-Createadroplet"></a>

Before installation you need to create [a droplet:](https://www.digitalocean.com/products/droplets/)

* [Login](https://cloud.digitalocean.com/login) to the digital ocean cloud  
* Choose a standard droplet
* Choose OS and parameters according to minimal system requirements
* Go through the Wizard's steps.
* After 2-3 minutes the droplet will be available for `ssh` access

![Choosing a stadard droplet](../../.gitbook/assets/choosing_image-1.png)

## **Install Privatix Agent on a virtual machine**

### Unpack a deb-package

1. Go to the Privatix's releases page: [https://github.com/Privatix/privatix/releases](https://github.com/Privatix/privatix/releases)
2. Choose the latest release \(in this example the latest release is 1.0.0\)
3. Execute the following script

```bash
wget https://github.com/Privatix/privatix/releases/download/1.0.0/privatix_ubuntu_x64_1.0.0_cli.deb &&
sudo dpkg -i privatix_ubuntu_x64_1.0.0_cli.deb
```

This script will download and unpack the Privatix Network installer to the **/opt/privatix\_installer** folder.

## Install the application

To install the application, execute the following script:

```bash
cd /opt/privatix_installer 
./install.sh 

sudo apt-get install python
./cli/install_dependencies.sh
```

### Create an offering

After the application has been installed, you can create an offering:

#### Create an account

```bash
export DAPP_PASSWORD=your_password

cd /opt/privatix_installer/cli &&
python create_account.py
```

#### Save your account backup

Backup location: /opt/privatix\_installer/autooffer/mainnet/private\_key.json

You can use the following script to download the backup:

```bash
scp your_username@host:/opt/privatix_installer/autooffer/mainnet/private_key.json ~
```

#### Transfer to your account ETH and PRIX

[https://help.privatix.network/general/how-to-get-prix-token](https://help.privatix.network/general/how-to-get-prix-token)

Check that funds have been delivered:

```bash
python update_balance.py
python get_accounts.py
```

#### Transfer all PRIX from the Account to the Marketplace

```bash
python transfer_all_to_marketplace.py
```

Ensure that PRIX has been transferred to the Marketplace \(usually it takes 5-10 min\):

```bash
python get_transactions.py
python get_accounts.py
```

#### Prepare the offering

```text
nano ./offering.json
```

#### Publish the offering

```text
python publish_offering.py ./offering.json
```

Ensure that the offering has been published \(usually it takes 5-10 min\):

```bash
python get_offerings.py
```

Output example \(expected status: registered\):

```text
Get agent offerings (product_id: 9234b192-e291-4116-a7d5-3c449c15167a, status: ['empty', 'registering', 'registered', 'popping_up', 'popped_up', 'removing', 'removed'], offset: 0, limit: 100)
    Ok: <Response [200]>
--------------------------------------------------------------------------------

name:
    Hash: 0xda414c689c40b2369840d63755a0b2120252e4a8681851d0398e295c3cd64001
    Status: registered
    Supply: 30
    Current supply: 30
    Id: 96a65e42-9828-40f6-b1b9-52cc0424896b
```

More information about the offer publication at [https://github.com/Privatix/dappctrl/tree/release/1.0.1/scripts/cli](https://github.com/Privatix/dappctrl/tree/release/1.0.1/scripts/cli)

#### In case of an error

In case of errors, you can see errors output by executing the following command:

```bash
python get_errors.py 60
```

Where 60 means "Give me all the errors in the last 60 minutes".

## Get your earnings

Transfer all tokens from the Marketplace to the Account

```bash
export DAPP_PASSWORD=your_password

cd /opt/privatix_installer/cli &&
python transfer_all_to_account.py
```

Wait about 10-15 min and make sure the tokens have been transferred:

```bash
python get_transactions.py
python check_account.py
```

Restore your account in any Ethereum wallet \(eg MyEtherWallet or Metamask\)

## How to remove the application

Make sure you have a backup or you have already withdrawn all funds.

To remove the application, execute the following script:

```bash
cd /opt/privatix_installer &&
./remove.sh &&
sudo apt-get remove privatix
```

