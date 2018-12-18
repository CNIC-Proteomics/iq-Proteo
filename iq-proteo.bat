@ECHO OFF

:: check env varibles are defined
IF "%NODE_PATH%"=="" GOTO :EndProcess1

:: go to home
SET PWD=%~dp0
SET PWD=%PWD:~0,-1%
CD "%PWD%"

:: execute iq-Proteo application
ECHO **
ECHO ** execute iq-Proteo application
CMD /C " "%NODE_PATH%/electron/dist/electron.exe" app "


GOTO :EndProcess


REM :: checking "functions"
:EndProcess1
    ECHO NODE_PATH env. variable is NOT defined
    GOTO :EndProcess



:: wait to Enter => Good installation
:EndProcess
    SET /P DUMMY=The application has been closed. Hit ENTER to continue...
