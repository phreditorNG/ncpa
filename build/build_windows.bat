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

:::: Start Configuration
set ver_7z=2301-x64
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

set PYTHONPATH=%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild
set PYSSLPATH=%PYTHONPATH%\%cpu_arch%\
set PYEXEPATH=%PYTHONPATH%\%cpu_arch%\py.exe

set PYDLLPATH=C:\Python311\DLLs

:::: End Configuration

:::: set execution policy to allow running powershell scripts
for /f "tokens=*" %%a in ('powershell.exe -Command "Get-ExecutionPolicy -Scope CurrentUser"') do set ORIGINAL_POLICY=%%a
echo Current policy: %ORIGINAL_POLICY%
powershell.exe -Command "Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force"
echo Execution policy set to Unrestricted

:::: build OpenSSL/Python
echo Building OpenSSL/Python
@REM powershell -File .\windows\build_python.ps1 -ncpa_build_dir %cd% -7z_ver %ver_7z% -python_ver %python_ver% -openssl_ver %openssl_ver% -base_dir %base_dir%

:::: build NCPA with Built Python:
:: i.e. C:\Users\Administrator\NCPA_PYTHON\Python-3.11.3\Python-3.11.3\PCbuild\amd64\py.exe - Python Launcher
echo Building NCPA with Built Python
set pydir=%PYEXEPATH%
set python=%PYEXEPATH%
@REM set PATH=%PYTHONPATH%;%PATH%
echo.
echo PATH: %PATH%
echo.
echo %PYEXEPATH% python version:
Call %PYEXEPATH% -c "import sys; print(sys.version); import ssl; print(ssl.OPENSSL_VERSION)"
echo.

:: Copy SSL DLLs to Python DLLs directory
echo Copying OpenSSL DLLs to Python DLLs directory
set ssl_dlls=%PYSSLPATH%\libcrypto-3-x64.dll %PYSSLPATH%\libssl-3-x64.dll %PYSSLPATH%\_ssl.pyd
for %%i in (%ssl_dlls%) do (
    echo Copying %%~nxi to %PYDLLPATH%
    copy %%i %PYDLLPATH%
)

echo Calling %PYEXEPATH% .\windows\build_ncpa.py %PYTHONPATH%
echo NOTE: This will take a while... You can check ncpa\build\build_ncpa.log for progress
echo.
@REM Call %PYEXEPATH% .\windows\build_ncpa.py %PYEXEPATH% > build_ncpa.log
Call %PYEXEPATH% %~dp0\windows\build_ncpa.py %PYEXEPATH%

:::: Restore original execution policy
powershell.exe -Command "Set-ExecutionPolicy %ORIGINAL_POLICY% -Scope CurrentUser -Force"
echo Execution policy restored to %ORIGINAL_POLICY%
