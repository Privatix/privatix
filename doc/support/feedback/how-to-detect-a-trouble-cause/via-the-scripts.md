# Via the scripts

## Note:

1. There are different scripts for different operating systems
2. You can analyze the logs yourself or you can send them to the support team

## Mac

Find:

* the path the application has been installed in
* the application role \(agent or client\)

E.g.:

```bash
app_path=/Applications/Privatix
role=client
```

Run the script:

```bash
"${app_path}/${role}/util/dump/dump_mac.sh" "${app_path}"
```

The dump will be created in the folder:

```text
${app_path}/dump
```

More information at: [https://github.com/Privatix/privatix/tree/master/tools/dump\_mac](https://github.com/Privatix/privatix/tree/master/tools/dump_mac)

## Ubuntu

Find:

* the path the application has been installed in
* the application role \(agent or client\)

E.g.:

```bash
app_path=/opt/Privatix
role=agent
```

Run the script:

```bash
sudo "${app_path}/${role}/util/dump/dump_mac.sh" "${app_path}"
```

The dump will be created in the folder:

```text
${app_path}/dump
```

More information at: [https://github.com/Privatix/privatix/tree/master/tools/dump\_ubuntu](https://github.com/Privatix/privatix/tree/master/tools/dump_ubuntu)

## Windows

Find the path the application has been installed in.

```bash
SET app_path="C:\Program Files\Privatix\client"
```

Run the script:

```bash
cd "%app_path%\util\dump"
.\ps-runner.exe -script ".\new-dump.ps1" -installDir "%app_path%" -outFile "dump.zip"
```

Result:

```text
.\dump.zip
```

More information at: [https://github.com/Privatix/privatix/tree/master/tools/dump\_win](https://github.com/Privatix/privatix/tree/master/tools/dump_win)

