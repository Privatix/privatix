<#
.SYNOPSIS
    Add/Remove Windows firewall rule for payment reciever of dappctrl
.DESCRIPTION
    Add/remove Windows firewall rule for payment reciever of dappctrl

.PARAMETER Create
    Create firewall rule

.PARAMETER Remove
    Remove firewall rule

.PARAMETER ServiceName
    Name of service. Used for consitent naming between windows service and firewall rule.

.PARAMETER ProgramPath
    Path to binary

.PARAMETER Port
    Port number to allow through firewall

.PARAMETER Protocol
    Protocol. can be udp or tcp

.EXAMPLE
    .\set-ctrlfirewall.ps1 -Create -ServiceName "Privatix_dappctrl_7b1f782b82f83be7f7eb024def947bc214fa79a3" -ProgramPath "C:\Program Files\Privatix\Agent\dappctrl\dappctrl.exe" -Port 9000 -Protocol tcp

    Description
    -----------
    Allow payments to be recieved by dappctrl through windows firewall

.EXAMPLE
    .\set-ctrlfirewall.ps1 -Remove -ServiceName "Privatix_dappctrl_7b1f782b82f83be7f7eb024def947bc214fa79a3" 

    Description
    -----------
    Removes firewall rule for dappctrl payment receiver
#>
[cmdletbinding(
        DefaultParameterSetName='Create'
    )]
param (
    [Parameter(ParameterSetName = "Create", Mandatory = $true)]
    [switch]$Create,
    [Parameter(ParameterSetName = "Remove", Mandatory = $true)]
    [switch]$Remove,
    [Parameter(ParameterSetName = "Create")]
    [Parameter(ParameterSetName = "Remove")]
    [ValidateScript( {Get-Service -Name $_ })]
    [string]$ServiceName,
    [Parameter(ParameterSetName = "Create")]
    [ValidateScript( {Test-Path $_ })]
    [string]$ProgramPath,
    [Parameter(ParameterSetName = "Create")]
    [ValidateRange(0, 65535)] 
    [int]$Port,
    [Parameter(ParameterSetName = "Create")]
    [ValidateSet('tcp', 'udp')]
    [string]$Protocol = 'tcp'
)
if ($PSBoundParameters.ContainsKey('Create')) {
    New-NetFirewallRule -PolicyStore PersistentStore -Name $ServiceName -DisplayName "Privatix controller payment server" `
    -Description "Inbound rule for Privatix controller payments" -Group "Privatix" -Enabled True -Profile Any `
    -Action Allow -Direction Inbound -LocalPort $Port -Protocol $Protocol -Program $ProgramPath | Out-Null
} 
if ($PSBoundParameters.ContainsKey('Remove')) {
    Remove-NetFirewallRule -Name $ServiceName 
}