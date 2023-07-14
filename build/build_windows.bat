goto endFileDoc
:: Controller script for building NCPA on Windows.
::     THIS SCRIPT MUST BE RUN AS ADMINISTRATOR
::
:: Executes the following steps:
::     1. Execute build_python.ps1
::         a. Execute choco_prereqs.ps1
::             i.  Installs Chocolatey
::             ii. Installs prerequisites for building OpenSSL/Python/NCPA with Chocolatey
::         b. Download/Build OpenSSL source
::         d. Download/Build Python source
::     2. Execute build_windows.py
::         a. Build NCPA
::         b. Build NSIS installer

:: TODO: Add parameters to allow for customizing the build
::  (i.e. OpenSSL/Python versions, with pre-built OpenSSL/Python)
:: TODO: Add support for building NCPA with a pre-built OpenSSL
:: TODO: Add support for building NCPA with a pre-built Python
:endFileDoc

@echo off

:::: configuration
set 7z_ver=2301-x64
set python_ver=3.11.3
set openssl_ver=3.0.8

set "cpu_arch=%PROCESSOR_ARCHITECTURE%"
if "%cpu_arch%"=="AMD64" (
    set cpu_arch=amd64
) else if "%cpu_arch%"=="x86" (
    set cpu_arch=win32
) else if "%cpu_arch%"=="ARM64" (
    set cpu_arch=arm64
)
echo CPU Architecture: %cpu_arch%

set base_dir=%USERPROFILE%\NCPA-Building_Python
echo base_dir: %base_dir%

:::: set execution policy to allow running powershell scripts
for /f "tokens=*" %%a in ('powershell.exe -Command "Get-ExecutionPolicy -Scope CurrentUser"') do set ORIGINAL_POLICY=%%a
echo Current policy: %ORIGINAL_POLICY%
powershell.exe -Command "Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force"
echo Execution policy set to Unrestricted

:::: build OpenSSL/Python
echo Building OpenSSL/Python
@REM powershell -File .\windows\build_python.ps1 -7z_ver %7z_ver% -python_ver %python_ver% -openssl_ver %openssl_ver% -base_dir %base_dir%

:::: build NCPA with Built Python:
:: i.e. C:\Users\Administrator\NCPA_PYTHON\Python-3.11.3\Python-3.11.3\PCbuild\amd64\python.exe
echo Building NCPA with Built Python
set PYTHONPATH=%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild
set PYTHONEXEPATH=%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild\%cpu_arch%\py.exe
set pydir=%PYTHONEXEPATH%
set python=%PYTHONEXEPATH%
set PATH=%PYTHONPATH%;%PATH%
Call %PYTHONEXEPATH% .\windows\build_ncpa.py %PYTHONPATH% > build_ncpa.log

:::: Restore original execution policy
powershell.exe -Command "Set-ExecutionPolicy %ORIGINAL_POLICY% -Scope CurrentUser -Force"
echo Execution policy restored to %ORIGINAL_POLICY%
