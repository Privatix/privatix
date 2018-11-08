# How to build privatix application on win10+ operating systems


## Install Prerequisites

Install prerequisite software if it's not installed.

* [git](https://git-scm.com/downloads)

* [Golang](https://golang.org/doc/install) 1.11+. Make sure that 
`$GOPATH/bin` is added to system path `$PATH`.

* [gcc](https://sourceforge.net/projects/mingw-w64/). During the installation
choose `x86_64-win32-seh-rev0 version`. Make sure that `bin`
is added to  system path `$PATH`

* [node.js](https://nodejs.org/en/) 9.3+

## Build

First of all, please, set the execution policy: 
```bash
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
```

Then execute the following command:
```bash
publish-dapp.ps1 [[-wkdir] <string>] [[-staticArtefactsDir] <string>] 
                 [[-dappguibranch] <string>] [[-dappctrlbranch] <string>] 
                 [[-dappinstbranch] <string>] [[-dappopenvpnbranch] <string>] 
                 [-pack] [-godep] [-gitpull] [<CommonParameters>]
```

## Help

All modules have help. List here, but it is retrievable using `get-help` cmdlet

```bash
et-help .\publish-dapp.ps1

NAME
    publish-dapp.ps1

SYNOPSIS
    Build Privatix app, copy artefacts and create deploy archive with installer.


SYNTAX
    C:\Users\it\OneDrive\Documents\Work\Privatix\Other\Scripts\Windows\build\publish-dapp.ps1 [[-wkdir] <String>]
    [[-staticArtefactsDir] <String>] [-pack] [[-dappguibranch] <String>] [[-dappctrlbranch] <String>]
    [[-dappinstbranch] <String>] [[-dappopenvpnbranch] <String>] [-godep] [-gitpull] [<CommonParameters>]


DESCRIPTION
    Build Privatix artefacts.
    Copy them to single location.
    Create deploy folder with installer and app.zip.


PARAMETERS
    -wkdir <String>
        Working directory, where result will be published. It will be created.

        Required?                    false
        Position?                    1
        Default value                c:\prix_workdir\
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -staticArtefactsDir <String>
        Directory with static artefacts (e.g. postgesql, tor, openvpn, visual studio redistributable)

        Required?                    false
        Position?                    2
        Default value                c:\privatix\art
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -pack [<SwitchParameter>]
        If to package application additionaly to just building components.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -dappguibranch <String>
        Git branch to checkout for dappgui build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    3
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -dappctrlbranch <String>
        Git branch to checkout for dappctrl build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    4
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -dappinstbranch <String>
        Git branch to checkout for dapp-installer build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    5
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -dappopenvpnbranch <String>
        Git branch to checkout for dapp-openvpn build. If not specified "develop" branch will be used.

        Required?                    false
        Position?                    6
        Default value                develop
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -godep [<SwitchParameter>]
        Run "dep ensure" command for each golang branch. It runs for all of them.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -gitpull [<SwitchParameter>]
        Make git pull before build.

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

    PS C:\>build-dappctrl

    Description
    -----------
    Build dappctrl.




    -------------------------- EXAMPLE 2 --------------------------

    PS C:\>build-dappctrl -branch "develop" -godep -gitpull

    Description
    -----------
    Checkout branch "develop". Pull from git. Run go dependecy. Build dappctrl.

```