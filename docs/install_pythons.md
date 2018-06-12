# Install the two versions of Python: 2.x and 3.x

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

2. Add the environment variable "PYTHON27_HOME"

    Read the following document [add_env_variables](add_env_variables.md) for more information.

2. Add the environment variable "PYTHON3x_HOME"

    Read the following document [add_env_variables](add_env_variables.md) for more information.


References:
https://github.com/BurntSushi/nfldb/wiki/Python-&-pip-Windows-installation

### Linux distribution

If you are using Ubuntu 16.10 or newer, then you can easily install Python 3.6 with the following commands:
```bash
sudo apt-get update
sudo apt-get install python3.6
```

There are a few more packages and development tools to install to ensure that we have a robust set-up for our programming environment:
```bash
sudo apt-get install build-essential libssl-dev libffi-dev python-dev
```
