@ECHO OFF

:: Sets the env. variables from input parameters ----------------------
ECHO **
ECHO **
ECHO ** sets the env. variables from input parameters:
ECHO **
SET iq_lib=""
SET /p iq_lib="** Enter the path where iq-Proteo libraries will be saved: "
IF %iq_lib% =="" GOTO :EndProcess1
SETX IQPROTEO_LIBRARY %iq_lib%
ECHO **
SET p_home=""
SET /p p_home="** Enter the path to Python 3 (3.6.7 version!!): "
IF %p_home% =="" GOTO :EndProcess2
SETX PYTHON3x_HOME %p_home%
ECHO **
SET r_home=""
SET /p r_home="** Enter the path to R: "
IF %r_home% =="" GOTO :EndProcess3
SETX R_HOME %r_home%
ECHO **
SET  NODE_URL=https://nodejs.org/dist/v10.14.2/node-v10.14.2-win-x64.zip
SET  NODE_HOME=%IQPROTEO_LIBRARY%/node-v10.14.2
SETX NODE_PATH %NODE_HOME%/node_modules
ECHO **
ECHO %IQPROTEO_LIBRARY%
ECHO %PYTHON3x_HOME%
ECHO %R_HOME%
ECHO %NODE_PATH%


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
CMD /C " "%PYTHON3x_HOME%/Scripts/virtualenv" -p "%PYTHON3x_HOME%/python" "%IQPROTEO_LIBRARY%/python_venv" "


:: active the virtualenv and install the required packages ----------------------
ECHO **
ECHO **
ECHO ** active the virtualenv and install the required packages for each enviroment
CMD /C " "%IQPROTEO_LIBRARY%/python_venv/Scripts/activate.bat" && pip install numpy && pip install matplotlib && pip install scipy && pip install pytest-shutil && pip install snakemake"


:: install R packages ----------------------
ECHO **
ECHO **
ECHO ** install R packages
CMD /C " "%R_HOME%/bin/R" --vanilla < "%PWD%/install_Rlibs.R" "


:: download and install npm ----------------------
ECHO **
ECHO **
ECHO ** download and install npm
CMD /C " "%IQPROTEO_LIBRARY%/python_venv/Scripts/activate.bat" && python install_url_pkg.py "%NODE_URL%" "%NODE_HOME%" move "


:: install electron package ----------------------
ECHO **
ECHO **
ECHO ** install electron package
CMD /C " "%NODE_HOME%/npm" config set scripts-prepend-node-path true"
CMD /C " "%NODE_HOME%/npm" install electron --save-dev --save-exact --global "
CMD /C " "%NODE_HOME%/npm" install ps-tree --global "


:: rename package.json file because github security ----------------------
ECHO **
ECHO **
ECHO ** rename package.json file because github security
CMD /C " cd "%PWD%/app" && ren package.json.sample package.json"




GOTO :EndProcess




:: error messages
:EndProcess1
    ECHO IQPROTEO_LIBRARY env. variable is NOT defined
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
