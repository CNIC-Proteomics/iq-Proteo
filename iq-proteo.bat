@ECHO OFF

:: check env varibles are defined
IF "%IQPROTEO_NODE_PATH%"=="" GOTO :EndProcess1

:: go to home
CD "%IQPROTEO_SRC_HOME%"

:: execute iq-Proteo application
ECHO **
ECHO ** execute iq-Proteo application
CMD /C " "%IQPROTEO_NODE_PATH%/electron/dist/electron.exe" app "


GOTO :EndProcess


REM :: checking "functions"
:EndProcess1
    ECHO IQPROTEO_NODE_PATH env. variable is NOT defined
    GOTO :EndProcess



:: wait to Enter => Good installation
:EndProcess
    REM SET /P DUMMY=The application has been closed. Hit ENTER to continue...
