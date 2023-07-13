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
:endFileDoc

@echo off

:: configuration
set 7z_ver="2301-x64"
set python_ver="3.11.3"
set openssl_ver="3.0.8"

set base_dir="%USERPROFILE%\NCPA_PYTHON_BUILD"
cd %base_dir%

:: set execution policy to allow running powershell scripts
powershell -Command "$originalPolicy = Get-ExecutionPolicy"
powershell -Command "Set-ExecutionPolicy Unrestricted"


:: build OpenSSL/Python
@REM powershell -ExecutionPolicy Bypass -File build_python.ps1 -7z_ver %7z_ver% -python_ver %python_ver% -openssl_ver %openssl_ver% -base_dir %base_dir%

:: build NCPA
%base_dir%\Python-%py_ver%\Python-%py_ver%.exe .\windows\build_windows.py

:: restore original execution policy
powershell -Command "Set-ExecutionPolicy $originalPolicy"