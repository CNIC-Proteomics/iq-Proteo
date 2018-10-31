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

