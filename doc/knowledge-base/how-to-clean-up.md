---
description: how to delete all privatix network services from your computer
---

# How to "clean up"

We are very appreciate for everyone who have tried the previous versions of our software.  But, during many development cycles bug's revealed and fixed. 

Therefore, the software may "leave" some unnecessary components that may interfere the newer versions.

This guide is aimed to explain how to uninstall and delete all Privatix Network components from your computer.

## **Windows**

### To clean local storage:

Open devtools \(Electron menu -&gt; View -&gt; Toggle Developer Tools\) and execute this code in the electron's console: 

```text
window.localStorage.setItem('localSettings', JSON.stringify({accountCreated:false,firstStart:true,lang:"en"}))
```

### To clean services :

1. Open Add/remove programs, search for "Privatix network" and uninstall it.
2. Open powershell \(run as administrator\).
3. Execute this code in powershell: 

```text
Get-Service | ? {$_.name -match "privatix" -and $_.name -notmatch "PrivatixService"} | Stop-Service -PassThru -ErrorAction SilentlyContinue | % {sc.exe delete $_.name}
```

## **Mac** 

Uninstall the current Privatix software by calling uninstall.app \(Default location: `/Applications/Privatix/uninstall.app`\)

Remove the remaining services \(if they are present\):

List of remaining Privatix services:

```text
launchctl list | grep -i privatix
sudo launchctl list | grep -i privatix
ls ~/Library/LaunchAgents | grep -i privatix
ls /Library/LaunchDaemons | grep -i privatix
```

 If the list is not empty, then remove the remaining services:

{% hint style="danger" %}
Be careful, execute commands below only if you understand what you are doing.
{% endhint %}

```text
launchctl remove <name>
sudo launchctl remove <name>
rm -rf ~/Library/LaunchAgents/<name>
rm -rf /Library/LaunchDaemons/<name>
```

## **Ubuntu**

### GUI

1. Uninstall the current Privatix software by calling uninstall \(Default location: `/opt/Privatix/uninstall`\)
2. Remove the remaining services \(if they are present\):

```text
systemctl disable systemd-nspawn@common.service
systemctl disable systemd-nspawn@vpn.service
systemctl disable systemd-nspawn@agent.service  
systemctl disable systemd-nspawn@cient.service  

machinectl terminate agent
machinectl terminate client

machinectl disable agent
machinectl disable client

rm /lib/systemd/system/systemd-nspawn@common.service
rm /lib/systemd/system/systemd-nspawn@vpn.service
rm /lib/systemd/system/systemd-nspawn@agent.service
rm /lib/systemd/system/systemd-nspawn@client.service

rm -rf /opt/Privatix/
```

### **CLI** 

1. Uninstall the current Privatix software by calling the remove script \(Default location: `/opt/privatix_installer/remove.sh`\)
2. Remove the remaining services \(if they are present\):

```text
systemctl disable systemd-nspawn@common.service
systemctl disable systemd-nspawn@vpn.service
systemctl disable systemd-nspawn@agent.service  

machinectl terminate agent
machinectl disable agent

rm /lib/systemd/system/systemd-nspawn@common.service
rm /lib/systemd/system/systemd-nspawn@vpn.service
rm /lib/systemd/system/systemd-nspawn@agent.service

rm -rf /var/lib/container/agent/
```





