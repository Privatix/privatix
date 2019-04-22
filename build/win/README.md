# How to build Privatix application on win10+ operating systems

## Install Prerequisites

Install prerequisite software if it's not installed.

### Manually

- [git](https://git-scm.com/downloads)

- [Golang](https://golang.org/doc/install) 1.12+. Make sure that
  `$GOPATH/bin` is added to system path `$PATH`.

- [gcc](https://sourceforge.net/projects/mingw-w64/). During the installation
  choose `x86_64-win32-seh-rev0 version`. Make sure that `bin`
  is added to system path `$PATH`

- [node.js](https://nodejs.org/en/) 9.3+

### Using PowerShell

Install prerequisite software via `powershell`.

1. Run `powershell as administrator`
2. Run PS command: `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine`
3. Download and run [prepare-environment.ps1](../win/prepare-environment.ps1)

## Build

Set the execution policy to allow execution of PowerShell scripts:

```bash
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

Start build by executing `publish-dapp.ps1` with parameters
suitable for your build to build whole application.

You can build separate repository using `build-dapp.ps1`.

For help on each script use `get-help <script name> -full` PS command.

### Get installer binary

To get installer binary same as shipped to users, you can:

- install [Bitrock installer Enterprise](https://installbuilder.bitrock.com/download-step-2.html)
- add `builder-cli.exe` to %PATH%
- use `-installer` switch instead of `-pack` while running `publish-dapp.ps1`

Resulting installer binary will be placed to `$wkdir\project\out`

### publish-dapp.ps1 parameters

```bash
publish-dapp.ps1 [[-wkdir] <String>] [[-staticArtefactsDir] <String>]
    [[-product] <String>] [[-clean] <String>] [-gitpull] [-installer] [[-version] <String>] [[-dappguibranch]
    <String>] [[-dappctrlbranch] <String>] [[-dappinstbranch] <String>] [[-dappopenvpnbranch] <String>]
    [[-dappproxybranch] <String>] [[-privatixbranch] <String>] [-prodConfig] [<CommonParameters>]

```

### Help on publish-dapp.ps1

All modules have help. To get most recent docs use `get-help` cmdlet.

```PowerShell
get-help .\publish-dapp.ps1 -full

NAME
    publish-dapp.ps1

SYNOPSIS
    Build Privatix app, copy artefacts and create deploy archive with installer.


SYNTAX
    publish-dapp.ps1 [[-wkdir] <String>] [[-staticArtefactsDir] <String>]
    [[-product] <String>] [[-clean] <String>] [-gitpull] [-installer] [[-version] <String>] [[-dappguibranch]
    <String>] [[-dappctrlbranch] <String>] [[-dappinstbranch] <String>] [[-dappopenvpnbranch] <String>]
    [[-dappproxybranch] <String>] [[-privatixbranch] <String>] [-prodConfig] [<CommonParameters>]


DESCRIPTION
    Build Privatix artefacts.
    Copy them to single location.
    Create deploy folder with installer and app.zip.


PARAMETERS
    -wkdir <String>
        Working directory, where result will be published. It will be created.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -staticArtefactsDir <String>
        Directory with static artefacts (e.g. postgesql, tor, openvpn, visual studio redistributable)

        Required?                    false
        Position?                    2
        Default value                c:\privatix\art
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -product <String>
        Which Service plug-in to package. Can be "vpn" or "proxy". If not specified - VPN product is built.

        Required?                    false
        Position?                    3
        Default value                vpn
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -clean <String>
        Can be: "nothing","binaries", "all".
        Nothing - do not remove anything before build.
        Binaries - remove only project binaries form $wkdir\bin
        All - remove binaries and all repos from $wkdir\src\github.com\privatix

        Required?                    false
        Position?                    4
        Default value                nothing
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -gitpull [<SwitchParameter>]
        Make git pull before build.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -installer [<SwitchParameter>]
        Run BitRock installer to get packed installer.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -version <String>
        If version is specified, it will be passed to Bitrock and Dapp-GUI settings.json -> release.

        Required?                    false
        Position?                    5
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -dappguibranch <String>
        Git branch to checkout for dappgui build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    6
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -dappctrlbranch <String>
        Git branch to checkout for dappctrl build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    7
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -dappinstbranch <String>
        Git branch to checkout for dapp-installer build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    8
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -dappopenvpnbranch <String>
        Git branch to checkout for dapp-openvpn build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    9
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -dappproxybranch <String>
        Git branch to checkout for dapp-proxy build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    10
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -privatixbranch <String>
        Git branch to checkout for privatix build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    11
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -prodConfig [<SwitchParameter>]
        If specified, dappctrl will use production config, else development config.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>.\publish-dapp.ps1 -wkdir "C:\build" -staticArtefactsDir "C:\static_art"

    Description
    -----------
    Build application from develop branches.




    -------------------------- EXAMPLE 2 --------------------------

    PS C:\>.\publish-dapp.ps1 -wkdir "C:\build" -staticArtefactsDir "C:\static_art" -clean all

    Description
    -----------
    Same as above, but deletes all project binaries from gopath\bin.
    Additionally it deletes folder in $wkdir\src\github.com\privatix.
    Build application from develop branches.




    -------------------------- EXAMPLE 3 --------------------------

    PS C:\>.\publish-dapp.ps1 -staticArtefactsDir "C:\static_art" -gitpull -Verbose

    Description
    -----------
    Build application. Package it, so it can be installed, using installer.
    Checkout "develop" branch for each component. Pull latest commints from git.
    Place result in default location %SystemDrive%\build\<date-time>\




    -------------------------- EXAMPLE 4 --------------------------

    PS C:\>.\publish-dapp.ps1 -staticArtefactsDir "C:\privatix\art" -gitpull -dappguibranch "master" -dappctrlbranch
    "master" -dappinstbranch "master" -dappopenvpnbranch "master" -privatixbranch "master"

    Description
    -----------
    Same as above, but "master" branch is used for all components.




    -------------------------- EXAMPLE 5 --------------------------

    PS C:\>.\publish-dapp.ps1 -product proxy -staticArtefactsDir "C:\privatix\art" -installer -version "0.21.0"
    -gitpull -dappguibranch "master" -dappctrlbranch "master" -dappinstbranch "master" -dappopenvpnbranch "master"
    -privatixbranch "master" -prodConfig

    Description
    -----------
    Same as above, but "proxy" product and Bitrock installer is triggered to create executable installer.
    Note: Bitrock installer should be installed (https://installbuilder.bitrock.com/download-step-2.html) and
    "builder-cli.exe" added to %PATH%

```
