@ECHO OFF

:: check environment variables ----------------------
ECHO **
ECHO **
ECHO ** check environment variables
REM IF   %IQPROTEO_LIB_HOME% =="" GOTO :EndProcess1
REM IF   %IQPROTEO_PYTHON3x_HOME% =="" GOTO :EndProcess2
REM IF   %IQPROTEO_R_HOME% =="" GOTO :EndProcess3



:: install the PIP packages ----------------------
ECHO **
ECHO **
ECHO ** install the 'pip' package for python
CMD /C " "%IQPROTEO_PYTHON3x_HOME%/python" "%IQPROTEO_SRC_HOME%/install/get-pip.py"  --no-warn-script-location "



:: install virtualenv packages ----------------------
ECHO **
ECHO **
ECHO ** install the 'virtualenv' packages for python
CMD /C " "%IQPROTEO_PYTHON3x_HOME%/Scripts/pip" install virtualenv --no-warn-script-location "
CMD /C " "%IQPROTEO_PYTHON3x_HOME%/Scripts/pip" install virtualenvwrapper-win --no-warn-script-location "


:: create virtual enviroment for the application in the local path ----------------------
ECHO **
ECHO **
ECHO ** create virtualenv in python for the application
CMD /C " "%IQPROTEO_PYTHON3x_HOME%/Scripts/virtualenv" -p "%IQPROTEO_PYTHON3x_HOME%/python" "%IQPROTEO_PYENV_HOME%" "


:: active the virtualenv and install the required packages ----------------------
ECHO **
ECHO **
ECHO ** active the virtualenv and install the required packages for each enviroment
CMD /C " "%IQPROTEO_PYENV_HOME%/Scripts/activate.bat" && pip install numpy && pip install matplotlib && pip install scipy && pip install pytest-shutil && pip install snakemake && pip install pandas && pip install pprint"



:: install R packages ----------------------
ECHO **
ECHO **
ECHO ** install R packages
CMD /C " "%IQPROTEO_R_HOME%/bin/R" --vanilla < "%IQPROTEO_SRC_HOME%/install/src/install_Rlibs.R" "


:: download and install npm ----------------------
ECHO **
ECHO **
ECHO ** download and install npm
SET  NODE_URL=https://nodejs.org/dist/v10.14.2/node-v10.14.2-win-x64.zip
CMD /C " "%IQPROTEO_PYENV_HOME%/Scripts/activate.bat" && python "%IQPROTEO_SRC_HOME%/install/src/install_url_pkg.py" "%NODE_URL%" "%IQPROTEO_NODE_HOME%" move "



:: install electron package ----------------------
ECHO **
ECHO **
ECHO ** install electron package
CMD /C " "%IQPROTEO_NODE_HOME%/npm" config set scripts-prepend-node-path true"
CMD /C " "%IQPROTEO_NODE_HOME%/npm" install electron --save-dev --save-exact --global "
CMD /C " "%IQPROTEO_NODE_HOME%/npm" install ps-tree --global "





GOTO :EndProcess




:: error messages
:EndProcess1
    ECHO IQPROTEO_LIB_HOME env. variable is NOT defined
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
