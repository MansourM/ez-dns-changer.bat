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
    ::netsh interface ip set dns name="%NetConnectionID%" static 1.1.1.1
    ::netsh interface ip add dns name="%NetConnectionID%" 4.2.2.4 index=2
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
    goto :showmenuw

:showmenuw
bugfix

pause
goto :eof
