@echo off
setlocal EnableDelayedExpansion

:: Define the file name to search for
set "FileName=PacketshareWatchdog.ps1"
set "FileFound=false"
set "NewestFile="
set "NewestDate=0"

:: Search for the exact file name in the user's profile directory
for /r "%USERPROFILE%" %%f in (%FileName%) do (
    if exist "%%f" (
        set "FileFound=true"
        
        :: Get the file's last modified date and time
        for %%a in ("%%f") do (
            set "CurrentFile=%%~tf"
            :: Remove all non-numeric characters to create a sortable date/time string
            set "CurrentDate=!CurrentFile:/=!"
            set "CurrentDate=!CurrentDate::=!"
            set "CurrentDate=!CurrentDate: =!"
            
            :: Compare with the newest date found so far
            if !CurrentDate! gtr !NewestDate! (
                set "NewestDate=!CurrentDate!"
                set "NewestFile=%%f"
            )
        )
    )
)

:: Output results and execute if found
if "%FileFound%"=="true" (
    echo Most recent version found at: %NewestFile%
    echo Executing script...
    PowerShell -ExecutionPolicy Bypass -File "%NewestFile%"
) else (
    echo File "%FileName%" not found in the user profile.
)

pause