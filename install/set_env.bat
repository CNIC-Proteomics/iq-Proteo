@ECHO OFF

:: sets the env. variables from input parameters ----------------------
ECHO **
ECHO **
ECHO ** sets the env. variables from input parameters:

ECHO **
FOR  %%i in ("%~dp0..") do SET "SRC_HOME=%%~fi"
SET  SRC_HOME=%SRC_HOME:"=%

ECHO **
SET  LIB_VERSION=0.1
SET  LIB_PATH=""
SET  /p LIB_PATH="** Enter the path where iq-Proteo libraries will be saved: "
SET  LIB_PATH="D:\iq Proteo\library"
IF   %LIB_PATH% =="" GOTO :EndProcess1
SET  LIB_PATH=%LIB_PATH:"=%
SET  LIB_HOME=%LIB_PATH%/%LIB_VERSION%
SET  PYENV_HOME=%LIB_HOME%/python_venv

ECHO **
SET  PYTHON3x_HOME=""
SET  /p PYTHON3x_HOME="** Enter the path to Python 3 (3.6.7 version!!): "
REM SET  PYTHON3x_HOME="D:\softwares\Python3.6.7"
IF   %PYTHON3x_HOME% =="" GOTO :EndProcess2
SET  PYTHON3x_HOME=%PYTHON3x_HOME:"=%

ECHO **
SET  R_HOME=""
SET  /p R_HOME="** Enter the path to R: "
REM SET  R_HOME="C:\Program Files\R\R-3.5.1"
IF   %R_HOME% =="" GOTO :EndProcess3
SET  R_HOME=%R_HOME:"=%
SET  R_LIB=%LIB_HOME%/R

ECHO **
SET  NODE_HOME=%LIB_HOME%/node
SET  NODE_PATH=%NODE_HOME%/node_modules

SETX IQPROTEO_SRC_HOME "%SRC_HOME%"
SETX IQPROTEO_LIB_HOME "%LIB_HOME%"
SETX IQPROTEO_PYTHON3x_HOME "%PYTHON3x_HOME%"
SETX IQPROTEO_PYENV_HOME "%PYENV_HOME%"
SETX IQPROTEO_R_HOME "%R_HOME%"
SETX IQPROTEO_R_LIB "%R_LIB%"
SETX IQPROTEO_NODE_HOME "%NODE_HOME%"
SETX IQPROTEO_NODE_PATH "%NODE_PATH%"

ECHO **
ECHO %SRC_HOME%
ECHO %LIB_HOME%
ECHO %PYTHON3x_HOME%
ECHO %PYENV_HOME%
ECHO %R_HOME%
ECHO %R_LIB%
ECHO %NODE_HOME%
ECHO %NODE_PATH%

:: create library directory ----------------------
IF NOT EXIST "%LIB_HOME%" MD "%LIB_HOME%"

GOTO :EndProcess


:: error messages
:EndProcess1
    ECHO IQPROTEO_LIB_PATH env. variable is NOT defined
    GOTO :EndProcess
:EndProcess2
    ECHO IQPROTEO_PYTHON3x_HOME env. variable is NOT defined
    GOTO :EndProcess
:EndProcess3
    ECHO IQPROTEO_R_HOME env. variable is NOT defined
    GOTO :EndProcess


:: wait to Enter => Good installation
:EndProcess
    SET /P DUMMY=End of installation. Hit ENTER to continue...
