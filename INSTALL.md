
# Installing in Virtualenv

Install the virtualenv

```bash
pip3 install virtualenv
pip3 install virtualenvwrapper-win
```

# Install snakemake in Virtualenv for Windows

To create an installation in a virtual environment, use the following commands:

```bash
virtualenv -p python .venv_win
./.venv_win/Scripts/activate
pip3 install snakemake
```

Note: To active on windows the virtualenv you must to execute:

```bash
Set-ExecutionPolicy Unrestricted -Force
```
# Install R using the virtualenv

Create a local directory
```bash
mkdir .venv_win/R
```
Install R in the local path

Include in the PATH variable the binaries of R. Modify the following files:
./.venv_win/Scripts/activate, ./.venv_win/Scripts/activate.bat, ./.venv_win/Scripts/activate.ps1

# References

Python, Pip, virtualenv installation on Windows
http://timmyreilly.azurewebsites.net/python-pip-virtualenv-installation-on-windows/

virtualenv won't activate on windows
https://stackoverflow.com/questions/18713086/virtualenv-wont-activate-on-windows
