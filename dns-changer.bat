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

:: main code
:payload
    ::set NetConnectionID (network name)
    SetLocal EnableExtensions
    Set "Name=" & Set "NetConnectionID="
    For /F Delims^= %%G In ('%__APPDIR__%wbem\WMIC.exe NIC Where ^
     "Not NetConnectionStatus Is Null And NetEnabled='TRUE'" ^
     Get Name^,NetConnectionID /Value 2^> NUL') Do Set "%%G" 2> NUL 1>&2
    if Not Defined Name goto :eof
    echo Detected network name is: %NetConnectionID%
    echo.
    goto :readfile

:readfile
    ::endlocal
    set /a x = 0
    setlocal enabledelayedexpansion
    for /f "tokens=1-3 delims=," %%i in (%2dns-servers.txt) do (
     ::call echo !x!
     set Names[!x!]=%%i
     ::call echo Name=%%Names[!x!]%%
     set Servers1[!x!]=%%j
     ::call echo Server1=%%Servers1[!x!]%%
     set Servers2[!x!]=%%k
     ::call echo Server2=%%Servers2[!x!]%%
     set /a x+=1
    )
    goto :show-menu

:show-menu
    ::echo show-menu
    if %x%==0 (
        echo No Servers found check dns-servers.txt file.
        pause
        goto :eof
        )
    set /a x-=1
    echo Select which DNS server you want to set (choose the number) :
    echo.
    setlocal enabledelayedexpansion
    FOR /L %%i IN (0 1 %x%) DO (
    set /a index = %%i + 1
    set "commands=!commands!!index!"
    call echo   !index!. %%Names[%%i]%%
    )
    echo   0. clear DNS (WIP)
    echo.
    set "commands=0%commands%"

    choice /c:%commands% /M "Please choose an action: "
    echo.

    if %errorlevel%==1 goto :clear-dns
    set /a dnsindex=%errorlevel% - 2
    goto set-dns

:set-dns
    ::setlocal enabledelayedexpansion
    call echo Setting DNS for %%Names[%dnsindex%]%% ...
    call set dns1=%%Servers1[%dnsindex%]%%
    call set dns2=%%Servers2[%dnsindex%]%%
    echo Setting Preferred DNS Server (%dns1%)
    echo Setting Alternate DNS Server (%dns2%)
    netsh interface ip set dns name="%NetConnectionID%" static %dns1%
    netsh interface ip add dns name="%NetConnectionID%" %dns2% index=2
    echo Done.
    pause
    goto :eof

:clear-dns
    echo clear-dns
    pause
    goto :eof

pause
goto :eof
