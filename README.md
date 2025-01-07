# Watchdog script for the Packetshare Windows app

### This script ensures that Packetshare will always be running in the background.

I created this script because packetshare would occassionally crash on me every now and then, and I'd always have to run it again. Ths script will monitor any crashes, and in the event of a crash, it will start the service again. Logs are saved in C:/Logs. Script ideally should be scheduled to run at startup via task scheduler (powershell.exe with the arguments: _-WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\path\to\PacketshareWatchdog.ps1"_).

**NOTE:** Depending on your system's architecture, your packetshare directory may be either in your Program Files or Program Files (x86) directory. By default, this script assumes the x86 directory, but feel free to edit the script if otherwise.
