#Requires -RunAsAdministrator
# Remove all Razer firewall blocks and re-enable services
# Run as Administrator: right-click > Run with PowerShell, or from elevated prompt

Write-Host "=== Removing Razer Firewall Blocks ===" -ForegroundColor Cyan

$rules = Get-NetFirewallRule -DisplayName "Block Razer*" -ErrorAction SilentlyContinue
if ($rules) {
    $rules | Remove-NetFirewallRule
    Write-Host "  Removed $($rules.Count) firewall rules." -ForegroundColor Green
} else {
    Write-Host "  No Razer firewall rules found." -ForegroundColor Yellow
}

Write-Host "`n=== Re-enabling Razer Services ===" -ForegroundColor Cyan

Get-Service | Where-Object {$_.DisplayName -like "*Razer*"} | ForEach-Object {
    Set-Service -Name $_.Name -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service -Name $_.Name -ErrorAction SilentlyContinue
    Write-Host "  Enabled: $($_.DisplayName)" -ForegroundColor Green
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host "Razer internet access restored and services re-enabled." -ForegroundColor Green
