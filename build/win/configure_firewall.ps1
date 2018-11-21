param (
    $UserRole,
#OpenVPN
    $OpenVPNserviceName,
    $OpenVPNProgramPath,
    $OpenVPNport,
    $OpenVPNprotocol,
#DappCtrl
    $dappctrlServiceName,
    $dappctrlProgramPath,
    $dappctrlPort,
    $dappctrlProtocol
)
$UserRole = "Agent"

$OpenVPNserviceName = "Privatix_OpenVPN_7b1f782b82f83be7f7eb024def947bc214fa79a3"
#$OpenVPNProgramPath = "c:\privatix\openvpn-win-install\openvpn-win-server\openvpn-win-install\bin\openvpn\openvpn.exe"
$OpenVPNport = 443
$OpenVPNprotocol = "TCP"
New-NetFirewallRule -PolicyStore PersistentStore -Name $OpenVPNserviceName -DisplayName "Privatix OpenVPN server" -Description "Inbound rule for Privatix OpenVPN server" -Group "Privatix $UserRole" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort $OpenVPNport -Protocol $OpenVPNprotocol -Program $OpenVPNProgramPath

$dappctrlServiceName = "Privatix_Controller_503b328415fe86f1d2858fd4688d001051877fc2"
#$dappctrlProgramPath = "C:\build1\deploy\agent\dappctrl\dappctrl.exe"
$dappctrlPort = 9000
$dappctrlProtocol = "TCP"
New-NetFirewallRule -PolicyStore PersistentStore -Name $dappctrlServiceName -DisplayName "Privatix controller payment server" -Description "Inbound rule for Privatix controller payments" -Group "Privatix $UserRole" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort $dappctrlPort -Protocol $dappctrlProtocol -Program $dappctrlProgramPath