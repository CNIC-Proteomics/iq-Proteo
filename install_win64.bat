@ECHO off

:: get the python executable files
:: default values
SET PYTHON27_SCR=%QPROTEO_HOME%/venv_win64/python27/python
SET PYTHON3x_SCR=%QPROTEO_HOME%/venv_win64/python3x/python
:: from the interative shell
SET /p PYTHON27_SCR="Write the executable file for python27 (complete path). With empty enter, takes the default path: "
SET /p PYTHON3x_SCR="Enter executable file for python27 (complete path). With empty enter, takes the default path: "
:: from command line
IF NOT "%1" == "" ( SET PYTHON27_SCR="%1" )
IF NOT "%2" == "" ( SET PYTHON3x_SCR="%2" )
ECHO **
ECHO ** use the following python executable files:
ECHO %PYTHON27_SCR%
ECHO %PYTHON3x_SCR%

:: go to home
CD %QPROTEO_HOME%

:: install the PIP packages
ECHO **
ECHO ** install the PIP package for python27
%PYTHON27_SCR%  venv_win64/get-pip.py
ECHO **
ECHO ** install the PIP package for python3x
%PYTHON3x_SCR%  venv_win64/get-pip.py

:: install virtualenv packeges
REM ECHO **
REM ECHO ** install the PIP package for python27
REM %PYTHON27_SCR%  venv_win64/get-pip.py

SET /P DUMMY=Hit ENTER to continue...