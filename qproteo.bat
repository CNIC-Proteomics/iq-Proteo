@echo off

:: get current path
REM SET PWD=%~dp0
REM SET PWD=%PWD:~0,-1%

:: environment variables
REM SET QPROTEO=%PWD%
REM SET VENV=%QPROTEO%/venv_win64/venv_win64_py3x

:: environment variables
SET VENV=%QPROTEO_HOME%/venv_win64/venv_win64_py3x
SET VENV_ACTIVE=%VENV%/Scripts/activate.bat
SET WF_PATH=%QPROTEO_HOME%
SET TESTS_PATH=%QPROTEO_HOME%/test

:: workflow variables
SET WF_SMK_FILE=%WF_PATH%/qproteo.smk
SET WF_NTHREADS=25

:: interactive arguments
:: default value to test
SET WF_CONF_FILE=%TESTS_PATH%/test3-conf.pesa.yml
REM SET WF_CONF_FILE=%TESTS_PATH%/test2-conf.tmt.yml
SET /p WF_CONF_FILE="Enter the input file for the config workflow (in YAML extension): "

:: execute workflow
CMD /k "%VENV_ACTIVE% && snakemake.exe --configfile %WF_CONF_FILE% --snakefile %WF_SMK_FILE% --unlock && snakemake.exe --configfile %WF_CONF_FILE% --snakefile %WF_SMK_FILE% -j %WF_NTHREADS% --rerun-incomplete "

REM SET /P DUMMY=Hit ENTER to continue...