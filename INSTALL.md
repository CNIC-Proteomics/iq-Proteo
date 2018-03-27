
# Installing in Virtualenv

Install the virtualenv

```bash
pip3 install virtualenv
```

# Install snakemake in Virtualenv

To create an installation in a virtual environment, use the following commands:

```bash
virtualenv -p python3 .venv
./venv/Scripts/activate
pip3 install snakemake
```

Note: To active on windows the virtualenv you must to execute:

```bash
Set-ExecutionPolicy Unrestricted -Force
```

# References

Python, Pip, virtualenv installation on Windows
http://timmyreilly.azurewebsites.net/python-pip-virtualenv-installation-on-windows/

virtualenv won't activate on windows
https://stackoverflow.com/questions/18713086/virtualenv-wont-activate-on-windows
