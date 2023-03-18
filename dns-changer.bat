:: get admin access (you need admin access to set dns)
@echo off
if _%1_==_payload_  goto :payload

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
    netsh interface ip set dns name="Main Ethernet" static 1.1.1.1
    netsh interface ip add dns name="Main Ethernet" 1.0.0.1 index=2
echo ...
echo ...
echo PLEASE CHECK ABOVE IF SHARE WAS SUCCESFUL. YOU MAY NOW CLOSE THE WINDOW(S)
echo ...
echo ...
pause
goto :eof
