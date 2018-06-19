@ECHO OFF

:: environment variables
SET VENV=%QPROTEO_HOME%/venv_win64/venv_win64_py3x
SET VENV_ACTIVE=%VENV%/Scripts/activate.bat
SET WF_PATH=%QPROTEO_HOME%
SET TESTS_PATH=%QPROTEO_HOME%/test

:: workflow variables
SET WF_SMK_FILE=%WF_PATH%/qproteo.smk
SET WF_NTHREADS=25
SET /p WF_NTHREADS="Enter the number of threads you want to use (by default 25): "

:: interactive arguments
:: default value to test
SET WF_CONF_FILE="S:/LAB_JVC/RESULTADOS/JM RC/qProteo/test/test3-conf.pesa.yml"
SET /p WF_CONF_FILE="Enter the input file for the config workflow (in YAML extension): "

:: execute workflow
CMD /k "%VENV_ACTIVE% && snakemake.exe --configfile %WF_CONF_FILE% --snakefile %WF_SMK_FILE% --unlock && snakemake.exe --configfile %WF_CONF_FILE% --snakefile %WF_SMK_FILE% -j %WF_NTHREADS% --rerun-incomplete "

SET /P DUMMY=Hit ENTER to continue...