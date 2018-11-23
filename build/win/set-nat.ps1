#Requires -Version 3.0 -Modules NetAdapter
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Set IP forwarding for OpenVPN TAP device.
.DESCRIPTION
    Set IP forwarding for OpenVPN TAP device. This operation allows OpenVPN client to browse internet.
    NOTE: internet facing adpater is considered as adpater with lowest route metric. This should be valid in most configurations, but not all. 

.PARAMETER TAPdeviceAddress
    Unique identifier of TAP device. It is identified by "PnPDeviceID" (Get-NetAdapter) and same as "Device instance path" in device manager.

.EXAMPLE
    .\start_server_nat.ps1 -TAPdeviceAddress 'ROOT\NET\0002' -Enabled $true

    Description
    -----------
    Enables IP routing. Configures IP forwarding on internet adapter and TAP adapter. Starts "SharedAccess" and "RemoteAccess" services.

.EXAMPLE
    .\start_server_nat.ps1 -TAPdeviceAddress 'ROOT\NET\0002' -Enabled $false

    Description
    -----------
    Disables internet sharing for VPN adapter with specified TAPdeviceAddress
#>
param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$TAPdeviceAddress,
    [Parameter(Mandatory)]
    [bool]$Enabled
)

<#
.SYNOPSIS
    Set internet connection sharing between two adapters
.DESCRIPTION
    Set internet connection sharing between two adapters

.PARAMETER InetAdapterName
    Name of adpater with internet connection

.PARAMETER VPNAdapterName
    Name of TAP adapter, that should get connection to internet

.PARAMETER Enabled
    If true - enable internet connection sharing. 
    if false - disable internet connection sharing. 

.EXAMPLE
    Set-InternetConnectionSharing -InetAdapterName 'Ethernet' -VPNAdapterName 'Privatix VPN Server' -Enabled $true

    Description
    -----------
    Enables internet sharing on "Ethernet" adpater, giving "Privatix VPN Server" adpater to use its internet connection.

.EXAMPLE
    Set-InternetConnectionSharing -InetAdapterName 'Ethernet' -VPNAdapterName 'Privatix VPN Server' -Enabled $false

    Description
    -----------
    Disables internet sharing on "Ethernet" adpater, disallowing "Privatix VPN Server" adpater to use its internet connection.
#>
function Set-InternetConnectionSharing {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript(
            {if ((Get-NetAdapter -Name $_ -ErrorAction SilentlyContinue -OutVariable inetAdapter) -and (($inetAdapter).Status -notin @('Disabled', 'Not Present') ))
                {$true} 
                else {
                    throw "$_ adpater not exists or disabled"
                }
            }
        )]
        $InetAdapterName,
        [Parameter(Mandatory)]
        [ValidateScript(
            {if ((Get-NetAdapter -Name $_ -ErrorAction SilentlyContinue -OutVariable inetAdapter) -and (($inetAdapter).Status -notin @('Disabled', 'Not Present') ))
                {$true} 
                else {
                    throw "$_ adpater not exists or disabled"
                }
            }
        )]
        $VPNAdapterName,
        [Parameter(Mandatory)]
        [bool]$Enabled
    )

    begin {
        $ns = $null

        try {
            # Create a NetSharingManager object
            $ns = New-Object -ComObject HNetCfg.HNetShare
        }
        catch {
            # Register the HNetCfg library (once)
            regsvr32 /s hnetcfg.dll

            # Create a NetSharingManager object
            $ns = New-Object -ComObject HNetCfg.HNetShare
        }      

        if ($InetSharingConf.SharingEnabled) {throw "Connection sharing already enable on adapter $InetAdapterName"}
    }

    process {
        # Get internet connected adapter internet connection sharing configuration
        $InetConn = $ns.EnumEveryConnection | Where-Object { $ns.NetConnectionProps.Invoke($_).Name -eq $InetAdapterName }
        $InetSharingConf = $ns.INetSharingConfigurationForINetConnection.Invoke($InetConn)
        # Get VPN server adapter internet connection sharing configuration
        $VPNConn = $ns.EnumEveryConnection | Where-Object { $ns.NetConnectionProps.Invoke($_).Name -eq $VPNAdapterName }
        $VPNSharingConf = $ns.INetSharingConfigurationForINetConnection.Invoke($VPNConn)

        # check, if sharing is already configured
        $PhysicalAdapters = (Get-NetAdapter -Physical).Name
        $ns.EnumEveryConnection | Where-Object { $ns.NetConnectionProps.Invoke($_).Name -in $PhysicalAdapters } | ForEach-Object {
            if ($ns.INetSharingConfigurationForINetConnection.Invoke($_).SharingEnabled) {$SharingConfigured = $true}
        }

        if ($Enabled -and (-not $SharingConfigured)) {
            try {
                $InetSharingConf.EnableSharing(0)
                $VPNSharingConf.EnableSharing(1)
            }
            catch {throw "Failed to enable internet sharing for public adpater $InetAdapterName and VPN adpater $VPNAdapterName. Original exception: $($Error[0].exception)"}
        } 
        if ($SharingConfigured -and (-not $Enabled)) {
            try {
                $InetSharingConf.DisableSharing()
                $VPNSharingConf.DisableSharing()
            }
            catch {throw "Failed to disable internet sharing for public adpater $InetAdapterName and VPN adpater $VPNAdapterName. Original exception: $($Error[0].exception)"}
        }
    }

    end {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ns) | Out-Null
    }
}

# Find Internet connected adapter assuming it has lowest metric
$minRouteMetric = (Get-NetRoute | Measure-Object RouteMetric -Minimum).Minimum
$ifIndex = (Get-NetRoute | Where-Object { $_.RouteMetric -eq $minRouteMetric }).ifIndex | Select-Object -Unique
$InetAdapterName = (Get-NetAdapter -Physical | Where-Object { $_.ifIndex -in $ifIndex }).Name
# Find VPN server adpater by TAPdeviceAddress
$VPNAdapterName = (Get-NetAdapter | Where-Object { $_.PnPDeviceID -eq $TAPdeviceAddress }).Name

if ($Enabled) {
    # enable routing in registry
    $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
    Get-ItemProperty -Path $registryPath -Name "IPEnableRouter" | Set-ItemProperty -Name "IPEnableRouter" -Value 1

    #start windows services
    Get-Service -Name "SharedAccess" |  Set-Service -StartupType Automatic |  Start-Service
    Get-Service -Name "RemoteAccess" |  Set-Service -StartupType Automatic |  Start-Service

    Set-InternetConnectionSharing -InetAdapterName $InetAdapterName -VPNAdapterName $VPNAdapterName -Enabled $true
}
else {
    Set-InternetConnectionSharing -InetAdapterName $InetAdapterName -VPNAdapterName $VPNAdapterName -Enabled $false
}