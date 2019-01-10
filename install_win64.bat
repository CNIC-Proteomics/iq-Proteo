@ECHO OFF

:: sets the env. variables from input parameters ----------------------
ECHO **
ECHO **
ECHO ** sets the env. variables from input parameters:

ECHO **
FOR  %%i in ("%~dp0") do SET "SRC_HOME=%%~fi"
SET  SRC_HOME=%SRC_HOME:"=%

ECHO **
SET  LIB_VERSION=0.1
SET  LIB_PATH="%HOMEDRIVE%%HOMEPATH%/iq-Proteo"
SET  /p LIB_PATH="** Enter the path where iq-Proteo libraries will be saved (by default %LIB_PATH%): "
SET  LIB_PATH=%LIB_PATH:"=%
SET  LIB_HOME=%LIB_PATH%/%LIB_VERSION%

ECHO **
SET  PYTHON3x_HOME="%LIB_HOME%/python.3.6.7"
SET  PYTHON3x_HOME=%PYTHON3x_HOME:"=%

ECHO **
SET  R_HOME="C:\Program Files\R\R-3.5.1"
SET  /p R_HOME="** Enter the path to R (by default %R_HOME%): "
SET  R_HOME=%R_HOME:"=%
SET  R_LIB=%LIB_HOME%/R

ECHO **
SET  NODE_HOME=%LIB_HOME%/node
SET  NODE_PATH=%NODE_HOME%/node_modules

ECHO **
ECHO %SRC_HOME%
ECHO %LIB_HOME%
ECHO %PYTHON3x_HOME%
ECHO %R_HOME%
ECHO %R_LIB%
ECHO %NODE_HOME%
ECHO %NODE_PATH%

:: create env variables ----------------------
ECHO **
ECHO **
ECHO ** create the env. variables
SETX IQPROTEO_SRC_HOME "%SRC_HOME%"
SETX IQPROTEO_LIB_HOME "%LIB_HOME%"
SETX IQPROTEO_PYTHON3x_HOME "%PYTHON3x_HOME%"
SETX IQPROTEO_R_HOME "%R_HOME%"
SETX IQPROTEO_R_LIB "%R_LIB%"
SETX IQPROTEO_NODE_HOME "%NODE_HOME%"
SETX IQPROTEO_NODE_PATH "%NODE_PATH%"

REM Stablish this env variable for the git python
SETX GIT_PYTHON_REFRESH quiet


:: create library directory ----------------------
IF NOT EXIST "%LIB_HOME%" MD "%LIB_HOME%"
IF NOT EXIST "%R_LIB%" MD "%R_LIB%"


:: install the 'python' ----------------------
ECHO **
ECHO **
ECHO ** install the 'python'
CMD /C " "%SRC_HOME%/install/win/nuget.exe"  install python -Version 3.6.7 -OutputDirectory "%LIB_HOME%" "


:: install the PIP package ----------------------
ECHO **
ECHO **
ECHO ** install the 'pip' package
CMD /C " "%PYTHON3x_HOME%/tools/python" "%SRC_HOME%/install/get-pip.py"  --no-warn-script-location "


:: install required packages ----------------------
ECHO **
ECHO **
ECHO ** install required packages
CMD /C " "%PYTHON3x_HOME%/tools/Scripts/pip3.exe" install numpy matplotlib scipy pytest-shutil snakemake pandas pprint --no-warn-script-location "


:: install R packages ----------------------
ECHO **
ECHO **
ECHO ** install R packages
CMD /C " "%R_HOME%/bin/R" --vanilla --args "%R_LIB%" test2=no < "%SRC_HOME%/install/src/install_Rlibs.R" "


:: download and install npm ----------------------
ECHO **
ECHO **
ECHO ** download and install npm
SET  NODE_URL=https://nodejs.org/dist/v10.14.2/node-v10.14.2-win-x64.zip
CMD /C " "%PYTHON3x_HOME%/tools/python" "%SRC_HOME%/install/src/install_url_pkg.py" "%NODE_URL%" "%NODE_HOME%" "%LIB_HOME%/tmp" move "


:: install electron package ----------------------
ECHO **
ECHO **
ECHO ** install electron package
CMD /C " "%NODE_HOME%/npm" config set scripts-prepend-node-path true"
CMD /C " "%NODE_HOME%/npm" install electron --save-dev --save-exact --global "
CMD /C " "%NODE_HOME%/npm" install ps-tree --global "




GOTO :EndProcess



:: wait to Enter => Good installation
:EndProcess
    SET /P DUMMY=End of installation. Hit ENTER to continue...
