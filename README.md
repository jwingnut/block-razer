# Block Razer

Block all Razer software from internet access using Windows Firewall and disable Razer services to stop background activity and excessive logging.

## What it does

**`Block-Razer.ps1`**
- Creates inbound + outbound Windows Firewall block rules for every Razer `.exe` found in:
  - `C:\Program Files (x86)\Razer`
  - `C:\Program Files\Razer`
  - `C:\ProgramData\Razer`
- Stops and disables all Razer services (Game Manager, Central Service, etc.)
- Deletes Razer log files

**`Unblock-Razer.ps1`**
- Removes all "Block Razer" firewall rules
- Re-enables and starts Razer services

## Usage

1. Right-click the script > **Run with PowerShell** (must run as Administrator)

Or from an elevated PowerShell prompt:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Block-Razer.ps1
```

To undo:

```powershell
.\Unblock-Razer.ps1
```

## FAQ

**Will my Razer mouse/keyboard still work?**
Yes. Peripherals use USB HID drivers and work fine without internet access or Razer services. You just won't get firmware updates or cloud sync for profiles.

**Will Razer Synapse still work for configuring my devices?**
Synapse can still open and apply locally-saved profiles, but it won't be able to log in, sync cloud profiles, or check for updates.

**What about Razer Cortex game optimization features?**
Cortex's local features (like game boost/FPS overlay) should still function, but anything requiring a server connection (deals, game launcher, rewards) will not work.

**Why block Razer from the internet?**
Razer software is known for excessive telemetry, constant phoning home, background updates, and writing large log files (`GameManagerService.log` in particular). Blocking internet access stops all of this while keeping your hardware fully functional.

**Can I re-enable access later?**
Yes, run `Unblock-Razer.ps1` as Administrator. All firewall rules are removed and services are re-enabled.

**The script says "Access is denied"**
You need to run it as Administrator. Right-click > Run with PowerShell, or open an elevated PowerShell prompt first.

**Log files weren't deleted**
If a Razer service still had the log file open, it couldn't be deleted. Restart your computer and run the script again, or just delete the files manually — the services are now disabled so they won't recreate them.

**Will Windows Update or Razer reinstall undo this?**
A Razer software update could add new executables not covered by existing rules. Re-run `Block-Razer.ps1` after any Razer update to catch new files. Windows Update won't affect these firewall rules.
