@echo off

:: get current path
SET PWD=%~dp0
SET PWD=%PWD:~0,-1%

:: environment variables
SET QPROTEO=%PWD%/..
SET QPROTEO_VENV=%QPROTEO%/.venv_win
SET QPROTEO_VENV_ACTIVE=%QPROTEO_VENV%/Scripts/activate.bat
SET WF_PATH=%QPROTEO%/wf
SET TESTS_PATH=%QPROTEO%/test

:: workflow variables
SET WF_SMK_FILE=%WF_PATH%/sanxot.smk

:: interactive arguments
:: default value to test
SET WF_CONF_FILE=%TESTS_PATH%/test1-conf.ptm.yml
SET /p WF_CONF_FILE="Enter the input file for the config workflow (in YAML extension): "

:: execute workflow
CMD /k "%QPROTEO_VENV_ACTIVE% && snakemake.exe --configfile  %WF_CONF_FILE% --snakefile %WF_SMK_FILE%  -j 20 --verbose "

SET /P DUMMY=Hit ENTER to continue...