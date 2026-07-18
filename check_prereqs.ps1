# IMI Guard - environment / prerequisite checker.
# Run this on a target machine to see whether IMI Guard will run fully, with limits, or not at all.
#   powershell -ExecutionPolicy Bypass -File .\check_prereqs.ps1
$ErrorActionPreference = 'SilentlyContinue'

function Line($label, $value, $ok) {
    $mark = if ($ok -eq $true) { '[ OK ]' } elseif ($ok -eq $false) { '[FAIL]' } else { '[ -- ]' }
    Write-Host ("{0}  {1,-26} {2}" -f $mark, $label, $value)
}

Write-Host ""
Write-Host "IMI Guard - prerequisite check" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------"

# OS
$os = Get-CimInstance Win32_OperatingSystem
if (-not $os) { $os = Get-WmiObject Win32_OperatingSystem }
$caption = $os.Caption
$build = [int]$os.BuildNumber
$osOk = $build -ge 10240   # Windows 10 RTM or later
Line "Operating system" "$caption (build $build)" $osOk

# .NET Framework 4.x (registry Release value)
$rel = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release).Release
$netVer = switch ($rel) {
    { $_ -ge 528040 } { '4.8 or later'; break }
    { $_ -ge 461808 } { '4.7.2'; break }
    { $_ -ge 460798 } { '4.7'; break }
    { $_ -ge 394254 } { '4.6.1'; break }
    { $_ -ge 393295 } { '4.6'; break }
    default { if ($rel) { "4.x (release $rel)" } else { 'not detected' } }
}
$netOk = ($rel -ge 393295)   # 4.6 is the minimum (licensing crypto APIs)
Line ".NET Framework 4.6+" $netVer $netOk

# PowerShell
$psVer = $PSVersionTable.PSVersion
$psOk = $psVer.Major -ge 5
Line "PowerShell 5.1+" "$psVer" $psOk

# Spot-check the key cmdlet families the collectors rely on
$cmds = 'Get-NetTCPConnection','Get-NetFirewallProfile','Get-CimInstance','Get-PnpDevice','ConvertTo-Json'
$missing = @()
foreach ($c in $cmds) { if (-not (Get-Command $c -ErrorAction SilentlyContinue)) { $missing += $c } }
Line "Core collector cmdlets" ($(if ($missing.Count -eq 0) { 'all present' } else { "missing: $($missing -join ', ')" })) ($missing.Count -eq 0)

# Admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
Line "Running as Administrator" ($(if ($isAdmin) { 'yes' } else { 'no (the app will elevate itself)' })) ($null)

Write-Host "------------------------------------------------------------"
if ($netOk -and $psOk -and $missing.Count -eq 0) {
    Write-Host "RESULT: This machine can run IMI Guard fully." -ForegroundColor Green
}
elseif ($netOk -and $psOk) {
    Write-Host "RESULT: IMI Guard will run, but some collectors will report 'Limited' on this OS." -ForegroundColor Yellow
}
else {
    Write-Host "RESULT: Prerequisites missing. Install .NET Framework 4.8 and/or PowerShell 5.1 (WMF 5.1)." -ForegroundColor Red
    Write-Host "        See prereqs\README.txt for offline installers." -ForegroundColor Red
}
Write-Host ""
