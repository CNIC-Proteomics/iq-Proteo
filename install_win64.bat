@ECHO OFF

:: stablish lib version ----------------------
ECHO **
ECHO **
ECHO ** sets the env. variables
SET  IQPROTEO_LIB_VERSION=0.1
SET lib_home=%IQPROTEO_LIB_HOME%
SETX IQPROTEO_LIB "%lib_home%/%IQPROTEO_LIB_VERSION%"
SET IQPROTEO_LIB_PATH=%IQPROTEO_LIB%

:: sets the env. variables from input parameters ----------------------
REM ECHO **
REM ECHO **
REM ECHO ** sets the env. variables from input parameters:

REM ECHO **
REM SET iq_lib=""
REM SET /p iq_lib="** Enter the path where iq-Proteo libraries will be saved: "
REM IF %iq_lib% =="" GOTO :EndProcess1
REM SETX IQPROTEO_LIB "%iq_lib%/%IQPROTEO_LIB_VERSION%"

REM ECHO **
REM SET p_home=""
REM SET /p p_home="** Enter the path to Python 3 (3.6.7 version!!): "
REM IF %p_home% =="" GOTO :EndProcess2
REM SETX PYTHON3x_HOME %p_home%

REM ECHO **
REM SET r_home=""
REM SET /p r_home="** Enter the path to R: "
REM IF %r_home% =="" GOTO :EndProcess3
REM SETX R_HOME %r_home%

REM ECHO **
REM SET  NODE_URL=https://nodejs.org/dist/v10.14.2/node-v10.14.2-win-x64.zip
REM SET  NODE_HOME=%IQPROTEO_LIB%/node-v10.14.2
REM SETX NODE_PATH %NODE_HOME%/node_modules


SET  NODE_URL=https://nodejs.org/dist/v10.14.2/node-v10.14.2-win-x64.zip
SET  NODE_HOME=%IQPROTEO_LIB_PATH%/node-v10.14.2
SETX NODE_PATH "%NODE_HOME%/node_modules"

ECHO **
ECHO %IQPROTEO_LIB_PATH%
ECHO %PYTHON3x_HOME%
ECHO %R_HOME%
ECHO %NODE_HOME%
ECHO %NODE_PATH%



:: create library directory ----------------------
IF NOT EXIST "%IQPROTEO_LIB_PATH%" MD "%IQPROTEO_LIB_PATH%"


:: stablish local directory ----------------------
SET PWD=%~dp0
SET PWD=%PWD:~0,-1%
CD "%PWD%"


:: install the PIP packages ----------------------
ECHO **
ECHO **
ECHO ** install the 'pip' package for python
CMD /C " "%PYTHON3x_HOME%/python" "%PWD%/venv_win64/get-pip.py"  --no-warn-script-location "


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
CMD /C " "%PYTHON3x_HOME%/Scripts/virtualenv" -p "%PYTHON3x_HOME%/python" "%IQPROTEO_LIB_PATH%/python_venv" "


:: active the virtualenv and install the required packages ----------------------
ECHO **
ECHO **
ECHO ** active the virtualenv and install the required packages for each enviroment
CMD /C " "%IQPROTEO_LIB_PATH%/python_venv/Scripts/activate.bat" && pip install numpy && pip install matplotlib && pip install scipy && pip install pytest-shutil && pip install snakemake"


:: install R packages ----------------------
ECHO **
ECHO **
ECHO ** install R packages
CMD /C " "%R_HOME%/bin/R" --vanilla < "%PWD%/install_Rlibs.R" "


:: download and install npm ----------------------
ECHO **
ECHO **
ECHO ** download and install npm
CMD /C " "%IQPROTEO_LIB_PATH%/python_venv/Scripts/activate.bat" && python install_url_pkg.py "%NODE_URL%" "%NODE_HOME%" move "


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
