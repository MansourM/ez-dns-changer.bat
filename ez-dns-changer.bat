::repo => https://github.com/MansourM/ez-dns-changer.bat
::author => sm.mirbehbahani@gmail.com

@echo off

:: Customize Window
title DNS Changer

:: go to payload if we already got admin
if _%1_==_payload_  goto :payload

:: get admin access (you need admin access to set dns), here we call this batch file again with admin privileges
:getadmin
    echo %~nx0: elevating self
    set vbs=%temp%\getadmin.vbs
    echo Set UAC = CreateObject^("Shell.Application"^)                >> "%vbs%"
    echo UAC.ShellExecute "%~s0", "payload %~sdp0 %*", "", "runas", 1 >> "%vbs%"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
goto :eof

:: this runs after program is re-run as administrator
:payload
    goto :set-network-name

:: fetch and set network-name
:set-network-name
   SetLocal EnableExtensions
       Set "Name=" & Set "NetConnectionID="
       For /F Delims^= %%G In ('%__APPDIR__%wbem\WMIC.exe NIC Where ^
        "Not NetConnectionStatus Is Null And NetEnabled='TRUE'" ^
        Get Name^,NetConnectionID /Value 2^> NUL') Do Set "%%G" 2> NUL 1>&2
       if Not Defined Name goto :eof
       goto :readfile

::read dns servers from dns-servers.txt
:readfile
    set /a x = 0
    setlocal enabledelayedexpansion
    for /f "tokens=1-3 delims=," %%i in (%2dns-servers.txt) do (
     set Names[!x!]=%%i
     set Servers1[!x!]=%%j
     set Servers2[!x!]=%%k
     set /a x+=1
    )
    goto :show-menu

::show main menu and take action based on user input
:show-menu
    cls
    call :print-logo
    echo   Detected network name is: %NetConnectionID%
    echo.
    if %x%==0 (
        echo   No Servers found check dns-servers.txt file.
        pause
        goto :eof
        )
    set /a x-=1
    echo   Select which DNS server you want to set (choose the number) :
    echo.
    set "commands="
    setlocal enabledelayedexpansion
    FOR /L %%i IN (0 1 %x%) DO (
    set /a index=%%i+1
    set "commands=!commands!!index!"
    call echo     !index!. %%Names[%%i]%%
    )
    echo.
    echo     c. Clear DNS
    echo     f. Flush DNS
    echo     n. Open Network Connections
    echo     q. Quit!
    echo.
    set "commands=%commands%cfnq"
    choice /c:%commands% /M "` Please choose an action: "
    echo.

    set /a index+=1
    if %errorlevel%==%index% goto :clear-dns
    set /a index+=1
    if %errorlevel%==%index% goto :flush-dns
    set /a index+=1
    if %errorlevel%==%index% goto :open-network-connections
    set /a index+=1
    if %errorlevel%==%index% goto :eof
    set /a dnsindex=%errorlevel% - 1
    goto set-dns

:: set the selected dns servers
:set-dns
    ::setlocal enabledelayedexpansion
    call echo   Setting DNS for %%Names[%dnsindex%]%% ...
    call set dns1=%%Servers1[%dnsindex%]%%
    call set dns2=%%Servers2[%dnsindex%]%%
    echo   Setting Preferred DNS Server (%dns1%)
    echo   Setting Alternate DNS Server (%dns2%)
    netsh interface ip set dns name="%NetConnectionID%" static %dns1%
    netsh interface ip add dns name="%NetConnectionID%" %dns2% index=2
    echo   Done.
    pause
    goto :readfile

:: unset dns server (dhcp mode)
:clear-dns
    echo   Clearing DNS Servers...
    netsh interface ip set dnsservers name="%NetConnectionID%" source=dhcp
    echo   Done.
    echo.
    pause
    goto :readfile

::The “release” switch will release your current IP address settings.
::The “flushdns” switch will flush the DNS resolver cache.
::The “renew” switch will renew your IP address settings.
:flush-dns
    echo   Running ipconfig /release ...
    ipconfig /release > nul
    echo   Running ipconfig /flushdns ...
    ipconfig /flushdns > nul
    echo   Rpconfig /renew ...
    ipconfig /renew > nul
    echo   Done.
    echo.
    pause
    goto :readfile

:open-network-connections
    ncpa.cpl
    goto :readfile

::make your own at https://patorjk.com/software/taag
:print-logo
    echo   ______ ______  _____  _   _  _____    _____ _
    echo  ^|  ____^|___  / ^|  __ \^| \ ^| ^|/ ____^|  / ____^| ^|
    echo  ^| ^|__     / /  ^| ^|  ^| ^|  \^| ^| (___   ^| ^|    ^| ^|__   __ _ _ __   __ _  ___ _ __
    echo  ^|  __^|   / /   ^| ^|  ^| ^| . ` ^|\___ \  ^| ^|    ^| '_ \ / _` ^| '_ \ / _` ^|/ _ \ '__^|
    echo  ^| ^|____ / /__  ^| ^|__^| ^| ^|\  ^|____) ^| ^| ^|____^| ^| ^| ^| (_^| ^| ^| ^| ^| (_^| ^|  __/ ^|
    echo  ^|______/_____^| ^|_____/^|_^| \_^|_____/   \_____^|_^| ^|_^|\__,_^|_^| ^|_^|\__, ^|\___^|_^|
    echo                                                                  __/ ^|
    echo                                                                 ^|___/
    Exit /b
