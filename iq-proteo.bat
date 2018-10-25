@ECHO OFF

:: check env varibles are defined
IF "%IQPROTEO_HOME%"=="" GOTO :EndProcess1

:: go to home
CD %IQPROTEO_HOME%

REM :: execute iq-Proteo application
ECHO **
ECHO ** execute iq-Proteo application
CMD /C " "%IQPROTEO_HOME%/app/node_modules/electron/dist/electron.exe" app "

GOTO :EndProcess



REM :: checking "functions"
:EndProcess1
    ECHO IQPROTEO_HOME env. variable is NOT defined
    GOTO :EndProcess



:: wait to Enter => Good installation
:EndProcess
    SET /P DUMMY=The application has been closed. Hit ENTER to continue...
