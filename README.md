# Watchdog script for the Packetshare Windows app

### This script ensures that Packetshare will always be running in the background.

I created this script because packetshare would occassionally crash on me every now and then, and I'd always have to run it again. Ths script will monitor any crashes, and in the event of a crash, it will start the service again. Logs are saved in C:/Logs. Script ideally should be scheduled to run at startup ~~via task scheduler.~~ 

**Update:** I've not gotten task scheduler to cooperate, so I have implemented a somewhat sophistated batch script that will launch PacketshareWatchdog.ps1 from **_anywhere_** inside your user profile directory. Just put a shorcut of the batch script inside your startup folder.

## INSTRUCTIONS
1. Download both the powershell and batch script.
    - You may put the powershell script anywhere as long as it resides in your user directory.
2. Create a shortcut of the batch script and put it inside your startup folder (WIN+R --> shell:common startup).
4. The script will now run on startup. You may also run the script manually when needed.


## 
**NOTE:** Depending on your system's architecture, your packetshare directory may be either in your Program Files or Program Files (x86) directory. By default, this script assumes the x86 directory, but feel free to edit the script if otherwise.
