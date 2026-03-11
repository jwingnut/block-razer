#Requires -RunAsAdministrator
# Block all Razer executables from internet access and disable Razer services
# Run as Administrator: right-click > Run with PowerShell, or from elevated prompt

Write-Host "=== Blocking Razer Internet Access ===" -ForegroundColor Cyan

$razerPaths = @(
    "C:\Program Files (x86)\Razer",
    "C:\Program Files\Razer",
    "C:\ProgramData\Razer"
)

$exes = @()
foreach ($path in $razerPaths) {
    if (Test-Path $path) {
        $exes += Get-ChildItem -Path $path -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue
    }
}

Write-Host "Found $($exes.Count) Razer executables to block.`n" -ForegroundColor Yellow

foreach ($exe in $exes) {
    $name = $exe.BaseName
    $fullPath = $exe.FullName

    # Remove existing rules for this exe (clean slate)
    Get-NetFirewallRule -DisplayName "Block Razer - $name (Out)" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
    Get-NetFirewallRule -DisplayName "Block Razer - $name (In)" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue

    # Block outbound
    New-NetFirewallRule -DisplayName "Block Razer - $name (Out)" -Direction Outbound -Program $fullPath -Action Block -Profile Any | Out-Null
    # Block inbound
    New-NetFirewallRule -DisplayName "Block Razer - $name (In)" -Direction Inbound -Program $fullPath -Action Block -Profile Any | Out-Null

    Write-Host "  Blocked: $name" -ForegroundColor Green
}

# Stop and disable all Razer services
Write-Host "`n=== Disabling Razer Services ===" -ForegroundColor Cyan

Get-Service | Where-Object {$_.DisplayName -like "*Razer*"} | ForEach-Object {
    Write-Host "  Stopping: $($_.DisplayName)" -ForegroundColor Yellow
    Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
    Set-Service -Name $_.Name -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "  Disabled: $($_.DisplayName)" -ForegroundColor Green
}

# Clean up log files
Write-Host "`n=== Cleaning Up Razer Logs ===" -ForegroundColor Cyan

$logDirs = @(
    "C:\ProgramData\Razer\GameManager3\Logs",
    "C:\ProgramData\Razer\RazerCortex\Logs"
)

foreach ($logDir in $logDirs) {
    if (Test-Path $logDir) {
        Get-ChildItem -Path $logDir -File -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Remove-Item $_.FullName -Force -ErrorAction Stop
                Write-Host "  Deleted: $($_.FullName)" -ForegroundColor Green
            } catch {
                Write-Host "  Could not delete (locked): $($_.FullName)" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host "`n=== Done ===" -ForegroundColor Cyan
Write-Host "All Razer executables blocked. All Razer services disabled." -ForegroundColor Green
Write-Host "Restart your computer if any log files were locked." -ForegroundColor Yellow
