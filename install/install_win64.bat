@ECHO OFF

:: sets the env. variables from input parameters ----------------------
ECHO **
ECHO **
ECHO ** sets the env. variables from input parameters:

ECHO **
REM  SET  pwd=%~dp0
REM  SET  pwd=%pwd:~0,-1%
FOR  %%i in ("%~dp0..") do SET "SRC_HOME=%%~fi"
SET  SRC_HOME=%SRC_HOME:"=%

ECHO **
SET  LIB_VERSION=0.1
REM SET  LIB_PATH=""
REM SET  /p LIB_PATH="** Enter the path where iq-Proteo libraries will be saved: "
SET  LIB_PATH="D:\iq Proteo\library"
IF   %LIB_PATH% =="" GOTO :EndProcess1
SET  LIB_PATH=%LIB_PATH:"=%
SET  LIB_HOME=%LIB_PATH%/%LIB_VERSION%
SET  PYENV_HOME=%LIB_HOME%/python_venv

ECHO **
REM SET  PYTHON3x_HOME=""
REM SET  /p PYTHON3x_HOME="** Enter the path to Python 3 (3.6.7 version!!): "
SET  PYTHON3x_HOME="D:\softwares\Python3.6.7"
IF   %PYTHON3x_HOME% =="" GOTO :EndProcess2
SET  PYTHON3x_HOME=%PYTHON3x_HOME:"=%

ECHO **
REM SET  R_HOME=""
REM SET  /p R_HOME="** Enter the path to R: "
SET  R_HOME="C:\Program Files\R\R-3.5.1"
IF   %R_HOME% =="" GOTO :EndProcess3
SET  R_HOME=%R_HOME:"=%
SET  R_LIB=%LIB_HOME%/R

ECHO **
SET  NODE_URL=https://nodejs.org/dist/v10.14.2/node-v10.14.2-win-x64.zip
SET  NODE_HOME=%LIB_HOME%/node-v10.14.2
SET  NODE_PATH=%NODE_HOME%/node_modules

SETX IQPROTEO_SRC_HOME "%SRC_HOME%"
SETX IQPROTEO_LIB_HOME "%LIB_HOME%"
SETX IQPROTEO_PYENV_HOME "%PYENV_HOME%"
SETX IQPROTEO_R_HOME "%R_HOME%"
SETX IQPROTEO_R_LIB "%R_LIB%"
SETX IQPROTEO_NODE_PATH "%NODE_PATH%"

ECHO **
ECHO %SRC_HOME%
ECHO %LIB_HOME%
ECHO %PYTHON3x_HOME%
ECHO %R_HOME%
ECHO %NODE_PATH%


:: stablish the local directory ----------------------
CD   "%SRC_HOME%"

:: create library directory ----------------------
IF NOT EXIST "%LIB_HOME%" MD "%LIB_HOME%"


:: install the PIP packages ----------------------
ECHO **
ECHO **
ECHO ** install the 'pip' package for python
CMD /C " "%PYTHON3x_HOME%/python" "%SRC_HOME%/install/get-pip.py"  --no-warn-script-location "



:: install virtualenv packages ----------------------
ECHO **
ECHO **
ECHO ** install the 'virtualenv' packages for python
CMD /C " "%PYTHON3x_HOME%/Scripts/pip" install virtualenv --no-warn-script-location "
CMD /C " "%PYTHON3x_HOME%/Scripts/pip" install virtualenvwrapper-win --no-warn-script-location "


:: create virtual enviroment for the application in the local path ----------------------
ECHO **
ECHO **
ECHO ** create virtualenv in python for the application
CMD /C " "%PYTHON3x_HOME%/Scripts/virtualenv" -p "%PYTHON3x_HOME%/python" "%PYENV_HOME%" "


:: active the virtualenv and install the required packages ----------------------
ECHO **
ECHO **
ECHO ** active the virtualenv and install the required packages for each enviroment
CMD /C " "%PYENV_HOME%/Scripts/activate.bat" && pip install numpy && pip install matplotlib && pip install scipy && pip install pytest-shutil && pip install snakemake && pip install pandas && pip install pprint"




:: install R packages ----------------------
ECHO **
ECHO **
ECHO ** install R packages
REM CMD /C " "%R_HOME%/bin/R" --vanilla < "%SRC_HOME%/install/src/install_Rlibs.R" "
CMD /C " "%R_HOME%/bin/Rscript" --vanilla "%SRC_HOME%/install/src/install_Rlibs.R" "%R_LIB%" "




:: download and install npm ----------------------
ECHO **
ECHO **
ECHO ** download and install npm
CMD /C " "%PYENV_HOME%/Scripts/activate.bat" && python "%SRC_HOME%/install/src/install_url_pkg.py" "%NODE_URL%" "%NODE_HOME%" "%LIB_HOME%" move "




:: install electron package ----------------------
ECHO **
ECHO **
ECHO ** install electron package
CMD /C " "%NODE_HOME%/npm" config set scripts-prepend-node-path true"
CMD /C " "%NODE_HOME%/npm" install electron --save-dev --save-exact --global "
CMD /C " "%NODE_HOME%/npm" install ps-tree --global "





GOTO :EndProcess




:: error messages
:EndProcess1
    ECHO IQPROTEO_LIB_PATH env. variable is NOT defined
    GOTO :EndProcess
:EndProcess2
    ECHO PYTHON3x_HOME env. variable is NOT defined
    GOTO :EndProcess
:EndProcess3
    ECHO R_HOME env. variable is NOT defined
    GOTO :EndProcess

:: wait to Enter => Good installation
:EndProcess
    SET /P DUMMY=End of installation. Hit ENTER to continue...
