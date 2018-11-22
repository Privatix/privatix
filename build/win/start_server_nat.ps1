<#
.SYNOPSIS
    Set IP forwarding for OpenVPN TAP device.
.DESCRIPTION
    Set IP forwarding for OpenVPN TAP device. This operation allows OpenVPN client to browse internet.
    NOTE: internet facing adpater is considered as adpater with lowest route metric. This should be valid in most configurations, but not all. 

.PARAMETER TAPdeviceAddress
    Unique identifier of TAP device. It is identified by "PnPDeviceID" (Get-NetAdapter) and same as "Device instance path" in device manager.

.EXAMPLE
    .\start_server_nat.ps1 -TAPdeviceAddress 'ROOT\NET\0002'

    Description
    -----------
    Enables IP routing. Configures IP forwarding on internet adapter and TAP adapter. Starts "SharedAccess" and "RemoteAccess" services.
#>
param (
    [ValidateNotNullOrEmpty()]
    $TAPdeviceAddress
)

# enable routing in registry
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Get-ItemProperty -Path $registryPath -Name "IPEnableRouter" | Set-ItemProperty -Name "IPEnableRouter" -Value 1

# enable IP forwarding on Internet connected adapter (lowest metric)
$minRouteMetric = (Get-NetRoute | Measure-Object RouteMetric -Minimum).Minimum
$ifIndex = (Get-NetRoute | Where-Object { $_.RouteMetric -eq $minRouteMetric }).ifIndex | Select-Object -Unique
$adapterIndex = (Get-NetAdapter -Physical | Where-Object { $_.ifIndex -in $ifIndex }).ifIndex
$Interfaces = Get-NetIPInterface -InterfaceIndex $adapterIndex
$Interfaces | Where-Object { $_.forwarding -eq "disabled" } | Set-NetIPInterface -Forwarding Enabled

#enable IP forwarding on TAP adapter
Get-NetAdapter | Where-Object { $_.PnPDeviceID -eq $TAPdeviceAddress } | Get-NetIPInterface | Where-Object { $_.forwarding -eq "disabled" } | Set-NetIPInterface -Forwarding Enabled

#start windows services
Get-Service -Name "SharedAccess" |  Set-Service -StartupType Automatic |  Start-Service
Get-Service -Name "RemoteAccess" |  Set-Service -StartupType Automatic |  Start-Service
