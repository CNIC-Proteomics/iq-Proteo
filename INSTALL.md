# Prerequisites for installing

1. Python: 2.x and 3.x
2. Pip for both versions of Python (2.x and 3.x)

# 1. Install the two versions of Python: 2.x and 3.x

## Windows distribution
Download and execute the latest Python 2.* installation package from [here](https://www.python.org/downloads/windows/).  
_While either 32-bit (x86) or 64-bit (x86-64) versions should work just fine_
* Verify a successful installation by opening a command prompt window and navigating to your Python installation directory (default is `C:\Python27`).  Type `python` from this location to launch the Python interpreter.
    ```
    Microsoft Windows [Version 6.2.9200]
    (c) 2012 Microsoft Corporation. All rights reserved.
    
    C:\Users\Username>cd C:\Python27
    
    C:\Python27>python
    Python 2.7.8 (default, Jun 30 2014, 16:03:49) [MSC v.1500 32 bit (Intel)] on win
    32
    Type "help", "copyright", "credits" or "license" for more information.
    >>>
    ```
* It would be nice to be able to run Python from any location without having to constantly reference the full installation path name.  This can by done by adding the Python installation path to Windows' `PATH` `ENVIRONMENT VARIABLE`  
*_In Windows 7 and Windows 8, simply searching for "environment variables" will present the option to `Edit the system environment variables`. This will open the `System Properties / Advanced` tab_  
*_In Windows XP, right click on `My Computer->Properties` to open `System Properties` and click on the `Advanced` tab._  
 1. On the `System Properties / Advanced` tab, click `Environment Variables` to open `User Variables` and `System Variables`
 2. Create a new `System Variable` named Variable name: `PYTHON_HOME` and  Variable value: `c:\Python27` (or whatever your installation path was)  
![](https://camo.githubusercontent.com/767e3e7294af750e7db47ffb119cdc1154e2c79f/68747470733a2f2f662e636c6f75642e6769746875622e636f6d2f6173736574732f323939363230352f313035383236332f38643062376334632d313138352d313165332d383532622d3863653063303263623464322e706e67)
 3. Find the system variable called `Path` and click `Edit`  
![](https://camo.githubusercontent.com/da06b60252e8293d278d2027544d23602daa853b/68747470733a2f2f662e636c6f75642e6769746875622e636f6d2f6173736574732f323939363230352f313035383239342f30643734343936382d313138362d313165332d383766302d6531326166323330353030612e706e67)
 4. Add the following text to the end of the Variable value:  `;%PYTHON_HOME%\;%PYTHON_HOME%\Scripts\`
![](https://camo.githubusercontent.com/fb28d689631f2f4012741f6cf599dd52ed720b92/68747470733a2f2f662e636c6f75642e6769746875622e636f6d2f6173736574732f323939363230352f313035383237362f63333566353334612d313138352d313165332d386631622d6439343033633836643939662e706e67)
 5. Verify a successful environment variable update by opening a new command prompt window (important!) and typing `python` from any location
    ```
    Microsoft Windows [Version 6.2.9200]
    (c) 2012 Microsoft Corporation. All rights reserved.
    
    C:\Users\Username>python
    Python 2.7.8 (default, Jun 30 2014, 16:03:49) [MSC v.1500 32 bit (Intel)] on win
    32
    Type "help", "copyright", "credits" or "license" for more information.
    >>>
    ```

References:
https://github.com/BurntSushi/nfldb/wiki/Python-&-pip-Windows-installation

## Linux distribution

If you are using Ubuntu 16.10 or newer, then you can easily install Python 3.6 with the following commands:
```bash
sudo apt-get update
sudo apt-get install python3.6
```

There are a few more packages and development tools to install to ensure that we have a robust set-up for our programming environment:
```bash
sudo apt-get install build-essential libssl-dev libffi-dev python-dev
```

# 2. Install pip

## Windows distribution
The easiest way to install the `nfl*` python modules and keep them up-to-date is with a Python-based package manager called [Pip](http://en.wikipedia.org/wiki/Pip_(package_manager))

There are many methods for getting Pip installed, but my preferred method is the following:
* Download [get-pip.py](https://bootstrap.pypa.io/get-pip.py) to a folder on your computer. Open a command prompt window and navigate to the folder containing `get-pip.py`. Then run `python get-pip.py`. This will install `pip`.
* Verify a successful installation by opening a command prompt window and navigating to your Python installation's script directory (default is `C:\Python27\Scripts`).  Type `pip freeze` from this location to launch the Python interpreter.  
_`pip freeze` displays the version number of all modules installed in your Python non-standard library;  On a fresh install, `pip freeze` probably won't have much info to show but we're more interested in any errors that might pop up here than the actual content_
    ```
    Microsoft Windows [Version 6.2.9200]
    (c) 2012 Microsoft Corporation. All rights reserved.
    
    C:\Users\Username>cd c:\Python27\Scripts
    
    c:\Python27\Scripts>pip freeze
    antiorm==1.1.1
    enum34==1.0
    requests==2.3.0
    virtualenv==1.11.6
    ```
* It would be nice to be able to run Pip from any location without having to constantly reference the full installation path name.  If you followed the Python installation instructions above, then you've already got the pip install location (default = `C:\Python27\Scripts`) in your Windows' `PATH` `ENVIRONMENT VARIABLE`.  If you did not follow those steps, refer to them above now.
* Verify a successful environment variable update by opening a new command prompt window (important!) and typing `pip freeze` from any location
    ```
    Microsoft Windows [Version 6.2.9200]
    (c) 2012 Microsoft Corporation. All rights reserved.
    
    C:\Users\Username>pip freeze
    antiorm==1.1.1
    enum34==1.0
    requests==2.3.0
    virtualenv==1.11.6
    ```

Reference:
https://github.com/BurntSushi/nfldb/wiki/Python-&-pip-Windows-installation

## Linux distribution

On Ubuntu, the installation of pip (to manage software packages for Python):
```bash
sudo apt-get install -y python3-pip
```


# 3. Install the Virtualenv packages (Windows and Linux distribution)

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
pip install snakemake
pip install pandas
pip install matplotlib
pip install scipy
pip install xlrd
```

Note: To active on windows the virtualenv you must to execute:

```bash
Set-ExecutionPolicy Unrestricted -Force
```
# Install R using the virtualenv

Create a local directory
```bash
mkdir -p .venv_win/R
mkdir -p .venv_win/R/lib
```
Install R in the local path

Include in the PATH variable the binaries of R. Modify the following files:
./.venv_win/Scripts/activate, ./.venv_win/Scripts/activate.bat, ./.venv_win/Scripts/activate.ps1

# References

Python, Pip, virtualenv installation on Windows
http://timmyreilly.azurewebsites.net/python-pip-virtualenv-installation-on-windows/

virtualenv won't activate on windows
https://stackoverflow.com/questions/18713086/virtualenv-wont-activate-on-windows
