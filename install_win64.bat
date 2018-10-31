@ECHO OFF

:: check env varibles are defined
IF "%IQPROTEO_HOME%"=="" GOTO :EndProcess1
IF "%R_HOME%"=="" GOTO :EndProcess2
IF "%PYTHON27_HOME%"=="" GOTO :EndProcess3
IF "%PYTHON3x_HOME%"=="" GOTO :EndProcess4
IF "%NODEJS_HOME%"=="" GOTO :EndProcess5

:: get the python executable files
REM IF "%PYTHON27_HOME%" == "" SET PYTHON27_HOME=%IQPROTEO_HOME%/venv_win64/python27
REM IF "%PYTHON3x_HOME%" == "" SET PYTHON3x_HOME=%IQPROTEO_HOME%/venv_win64/python3x
ECHO **
ECHO ** use the following paths for python27 and python3x:
ECHO %PYTHON27_HOME%
ECHO %PYTHON3x_HOME%

:: go to home
CD %IQPROTEO_HOME%

REM :: install the PIP packages
ECHO **
ECHO ** install the 'pip' package for python27
CMD /C " "%PYTHON27_HOME%/python" "%IQPROTEO_HOME%/venv_win64/get-pip.py" "
ECHO **
ECHO ** install the 'pip' package for python3x
CMD /C " "%PYTHON3x_HOME%/python" "%IQPROTEO_HOME%/venv_win64/get-pip.py" "

:: install virtualenv packages
ECHO **
ECHO ** install the 'virtualenv' packages for python27
CMD /C " "%PYTHON27_HOME%/Scripts/pip" install virtualenv"
CMD /C " "%PYTHON27_HOME%/Scripts/pip" install virtualenvwrapper-win"
ECHO **
ECHO ** install the 'virtualenv' packages for python3x
CMD /C " "%PYTHON3x_HOME%/Scripts/pip" install virtualenv"
CMD /C " "%PYTHON3x_HOME%/Scripts/pip" install virtualenvwrapper-win"

:: create virtual enviroment for the application in the local path
ECHO **
ECHO ** create virtualenv in python27 for the application
CMD /C " "%PYTHON27_HOME%/Scripts/virtualenv" -p "%PYTHON27_HOME%/python" "%IQPROTEO_HOME%/venv_win64/venv_win64_py27" "
ECHO **
ECHO ** create virtualenv in python3x for the application
CMD /C " "%PYTHON3x_HOME%/Scripts/virtualenv" -p "%PYTHON3x_HOME%/python" "%IQPROTEO_HOME%/venv_win64/venv_win64_py3x" "

:: active the virtualenv and install the required packages
ECHO **
ECHO ** active the virtualenv and install the required packages for each enviroment
CMD /C " "%IQPROTEO_HOME%/venv_win64/venv_win64_py27/Scripts/activate.bat" && pip install numpy && pip install matplotlib && pip install scipy && pip install pandas && pip install xlrd"
ECHO **
ECHO ** active the virtualenv and install the required packages for each enviroment
CMD /C " "%IQPROTEO_HOME%/venv_win64/venv_win64_py3x/Scripts/activate.bat" && pip install snakemake && pip install pandas && pip install xlrd"

:: install R packages
ECHO **
ECHO ** install R packages
CMD /C " "%R_HOME%/bin/R" --vanilla < "%IQPROTEO_HOME%/install_Rlibs.R" "

:: install electron package
ECHO **
ECHO ** install electron package
CMD /C " cd "%IQPROTEO_HOME%/app" && "%NODEJS_HOME%/npm" config set scripts-prepend-node-path true"
CMD /C " cd "%IQPROTEO_HOME%/app" && "%NODEJS_HOME%/npm" install electron --save-dev --save-exact"
CMD /C " cd "%IQPROTEO_HOME%/app" && "%NODEJS_HOME%/npm" install ps-tree"


GOTO :EndProcess

:: error messages
:EndProcess1
    ECHO IQPROTEO_HOME env. variable is NOT defined
    GOTO :EndProcess
:EndProcess2
    ECHO R_HOME env. variable is NOT defined
    GOTO :EndProcess
:EndProcess3
    ECHO PYTHON27_HOME env. variable is NOT defined
    GOTO :EndProcess
:EndProcess4
    ECHO PYTHON3x_HOME env. variable is NOT defined
    GOTO :EndProcess
:EndProcess5
    ECHO NODEJS_HOME env. variable is NOT defined
    GOTO :EndProcess

:: wait to Enter => Good installation
:EndProcess
    SET /P DUMMY=End of installation. Hit ENTER to continue...
