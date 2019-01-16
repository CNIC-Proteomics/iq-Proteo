# iq-Proteo
Snakemake workflow developed by the Proteomic Unit in CNIC


# Installation

## Prerequisites for installing

1. Add the environment variable "IQPROTEO_HOME"

    Read the following document [docs/add_env_variables](docs/add_env_variables.md) for more information.

2. Install R

    Read the following document [docs/install_r](docs/install_r.md) for more information.

    2.1. Add the environment variable "R_HOME"

        Read the following document [docs/add_env_variables](docs/add_env_variables.md) for more information.

3. Install Python2.7

    Read the following document [docs/install_pythons](docs/install_pythons.md) for more information.

    3.1. Add the environment variable "PYTHON27_HOME"

        Read the following document [docs/add_env_variables](docs/add_env_variables.md) for more information.

4. Install Python3.x

    Read the following document [docs/install_pythons](docs/install_pythons.md) for more information.

    4.1. Add the environment variable "PYTHON3x_HOME"

        Read the following document [docs/add_env_variables](docs/add_env_variables.md) for more information.

5. Install NodeJS

    Read the following document [docs/install_nodejs](docs/install_nodejs.md) for more information.

    5.1. Add the environment variable "NODEJS_HOME"

        Read the following document [docs/add_env_variables](docs/add_env_variables.md) for more information.

>#### Note:
>
>By default, the workflow will use the local pythons (tested in Windows 7) but it would be any problem executing the workflow, 
>you have to install python 2.x and python 3.x, and declare new environment variables.
>Read the following document [docs/install_pythons](docs/install_pythons.md) for more information.

## Execute the install script

### Windows distribution
Execute the batch script "install_win64.bat"

Requirements Microsoft Visual Studio but with the C++ languange!!!

Windows Python needs Visual C++ libraries installed via the SDK to build code, such as via setuptools.extension.Extension or numpy.distutils.core.Extension. For example, building f2py modules in Windows with Python requires Visual C++ SDK as installed above. On Linux and Mac, the C++ libraries are installed with the compiler.
https://www.scivision.co/python-windows-visual-c++-14-required/


<!-- Visual C++ Redistributable para Visual Studio 2015 -->
<!-- https://stackoverflow.com/questions/44290672/how-to-download-visual-studio-community-edition-2015-not-2017 -->
<!-- https://go.microsoft.com/fwlink/?LinkId=532606&clcid=0x409 -->
<!-- https://www.microsoft.com/es-es/download/details.aspx?id=48145 -->

### Linux distribution
UNDER CONTRUCTION

>#### Note:
>
>Take into account the following instructions:
>
>- Active on windows the virtualenv you must to execute the following command using cmd
>```bash
>Set-ExecutionPolicy Unrestricted -Force
>```
>
>- Check if the Path (environment variable) contains the system commands
>```
>Path = %SystemRoot%\system32;
>```


# Execute the workflow

## Windows distribution

Executing the batch script **iq-qproteo.bat**

The script needs the config 
## Linux distribution
UNDER CONTRUCTION

