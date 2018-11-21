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
get-NetAdapter | Where-Object { $_.PnPDeviceID -eq $TAPdeviceAddress } | Get-NetIPInterface | Where-Object { $_.forwarding -eq "disabled" } | Set-NetIPInterface -Forwarding Enabled

#start windows services
Get-Service -Name "SharedAccess" |  Set-Service -StartupType Automatic |  Start-Service
Get-Service -Name "RemoteAccess" |  Set-Service -StartupType Automatic |  Start-Service
