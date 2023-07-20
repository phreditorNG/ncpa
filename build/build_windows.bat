@echo off
goto endFileDoc
:: Controller script for building NCPA on Windows.
::     THIS SCRIPT MUST BE RUN AS ADMINISTRATOR
::
:: Table of Contents:
:: 1. Configuration
:: 2. Set execution policy to allow running powershell scripts
:: 3. Build OpenSSL/Python (ncpa\build\windows\build_ossl_python\build_python.ps1)
::   3.1 Chocolatey: (ncpa\build\windows\choco_prereqs.ps1)
::     3.1.1 Install Chocolatey
::     3.1.2 Install Git, Perl, VS Build Tools, etc. w/ Chocolatey
::   3.2 Install 7-Zip
::   3.3 Download/Build OpenSSL (ncpa\build\windows\build_ossl_python\build_openssl.ps1)
::   3.4 Download/Build Python (ncpa\build\windows\build_ossl_python\build_python.ps1)
:: 4. Build NCPA (ncpa\build\windows\build_ncpa.py)
:: 5. Restore original execution policy
::
:: TODO: Add parameters to allow for customizing the build
::  (with pre-built OpenSSL/Python)
:: TODO: Add support for building NCPA with a pre-built OpenSSL
:: TODO: Add support for building NCPA with a pre-built Python - Allow building with official Python releases (will have OSSL 3 soon)
:endFileDoc

setlocal

:::: Take options from command line to pass to build_config.ps1
:options_loop
echo option: %~1
set "build_options="
if "%~1"=="" goto :end_options_loop
if "%~1"=="-np"          goto :no_prereqs
if "%~1"=="-no_prereqs"  goto :no_prereqs
if "%~1"=="-nd"          goto :no_download
if "%~1"=="-no_download" goto :no_download
if "%~1"=="-nb"          goto :no_build
if "%~1"=="-no_build"    goto :no_build
if "%~1"=="-nn"          goto :no_ncpa
if "%~1"=="-no_ncpa"     goto :no_ncpa

if "%~1"=="-h" (
    set "build_options=-h"
    goto :end_options_loop
)
:no_prereqs
    set "build_options=%build_options% -no_prereqs"
    goto :options_loop
:no_download
    set "build_options=%build_options% -no_download"
    goto :options_loop
:no_build
    set "build_options=%build_options% -no_build"
    goto :options_loop
:no_ncpa
    set "build_options=%build_options% -no_ncpa"
    goto :options_loop
echo Invalid option: %~1, use -h for help
shift
goto :options_loop
:end_options_loop

:::::::::::::::::::::::
:::: 1. Configuration
:::::::::::::::::::::::
echo Configuring build
call %~dp0\windows\build_config.bat %build_options%
if ERRORLEVEL 1 exit /B

:::::::::::::::::::::::
:::: 2. Set execution policy to allow running powershell scripts
:::::::::::::::::::::::
for /f "tokens=*" %%a in ('powershell.exe -Command "Get-ExecutionPolicy -Scope CurrentUser"') do set ORIGINAL_POLICY=%%a
echo Current policy: %ORIGINAL_POLICY%
powershell.exe -Command "Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force"
echo Execution policy set to Unrestricted
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

:::::::::::::::::::::::
:::: 3. Build OpenSSL/Python
:::::::::::::::::::::::
echo Building OpenSSL/Python
:: build_all.ps1 will:
:: 1. Install Prerequisites
:: 2. Download/Build OpenSSL
:: 3. Download/Build Python
powershell -File %~dp0\windows\build_ossl_python\build_all.ps1 ^
    -ncpa_build_dir %~dp0 ^
:: product versions
    -7z_ver %ver_7z% ^
    -python_ver %python_ver% ^
    -openssl_ver %openssl_ver% ^
::
    -base_dir %base_dir% ^
:: build options
    -install_prereqs %install_prereqs% ^
    -download_openssl_and_python %download_openssl_and_python% ^
    -build_openssl_python %build_openssl_python% ^
    -build_ncpa %build_ncpa%
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

:::::::::::::::::::::::
:::: 4. Build NCPA with Built Python:
:::::::::::::::::::::::
:: i.e. C:\Users\Administrator\NCPA_PYTHON\Python-3.11.3\Python-3.11.3\PCbuild\amd64\py.exe - Built Python Launcher
IF %build_ncpa% (
    echo Building NCPA with Built Python
    set pydir=%PYEXEPATH%
    set python=%PYEXEPATH%
    echo %PYEXEPATH% python version:
    Call %PYEXEPATH% -c "import sys; print(sys.version); import ssl; print(ssl.OPENSSL_VERSION)"
    echo.

    :: Copy built Python SSL DLLs to installed Python DLLs directory
    echo Copying OpenSSL DLLs to Python DLLs directory
    set ssl_dlls=%PYSSLPATH%\libcrypto-3-x64.dll %PYSSLPATH%\libssl-3-x64.dll %PYSSLPATH%\_ssl.pyd
    for %%i in (%ssl_dlls%) do (
        echo Copying %%~nxi to %PYDLLPATH%
        copy %%i %PYDLLPATH%
    )
    if ERRORLEVEL 1 exit /B %ERRORLEVEL%

    echo Calling %PYEXEPATH% %~dp0\windows\build_ncpa.py %PYTHONPATH%
    echo NOTE: This will take a while... You can check ncpa\build\build_ncpa.log for progress
    echo.
    @REM Call %PYEXEPATH% .\windows\build_ncpa.py %PYEXEPATH% > build_ncpa.log
    Call %PYEXEPATH% %~dp0\windows\build_ncpa.py %PYEXEPATH%
    if ERRORLEVEL 1 exit /B %ERRORLEVEL%
)

:::::::::::::::::::::::
:::: 5. Restore original execution policy
:::::::::::::::::::::::
powershell.exe -Command "Set-ExecutionPolicy %ORIGINAL_POLICY% -Scope CurrentUser -Force"
echo Execution policy restored to %ORIGINAL_POLICY%
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

endlocal