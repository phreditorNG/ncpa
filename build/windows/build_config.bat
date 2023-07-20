@echo off
:::::::::::::::::::::::::
:::: Build Configuration
:::::::::::::::::::::::::

:::: OpenSSL/Python Build Directory
set base_dir=%USERPROFILE%\NCPA-Building_Python

:::: Build Options
:: install_prereqs              - whether to use Chocolatey to install prerequisites
::      NOTE: if false, you must install them manually before running the build
:: download_openssl_and_python  -  whether to download OpenSSL/Python or use local copies
::      NOTE: if false, you must have the OpenSSL/Python files in the %base_dir% location
:: build_openssl_python         - whether to build OpenSSL/Python
::      Note: if false, you must have OpenSSL/Python built in the %base_dir% location (%base_dir%\OpenSSL and %base_dir%\Python-%python_ver%)
:: build_ncpa                   - whether to build NCPA
set install_prereqs=true
set download_openssl_and_python=true
set build_openssl_python=true
set build_ncpa=true

if exist "%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild\amd64\py.exe" (
    set ossl_python_already_built=true
) else (
    set ossl_python_already_built=false
    set build_openssl_python=true
)

:::: Product version selection
set ver_7z=2301-x64
set python_ver=3.11.3
set openssl_ver=3.0.8

:::: CPU Architecture
:: TODO: build not tested on ARM64 or x86
set "cpu_arch=%PROCESSOR_ARCHITECTURE%"
if "%cpu_arch%"=="AMD64" (
    set cpu_arch=amd64
) else if "%cpu_arch%"=="x86" (
    set cpu_arch=win32
) else if "%cpu_arch%"=="ARM64" (
    set cpu_arch=arm64
)

:::: Paths
:: DO NOT CHANGE THESE UNLESS YOU KNOW WHAT YOU'RE DOING - DOING SO WILL BREAK OTHER SCRIPTS
:: Python building directory
set PYTHONPATH=%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild
:: Built Python OpenSSL files directory
set PYSSLPATH=%PYTHONPATH%\%cpu_arch%\
:: Built Python Launcher
set PYEXEPATH=%PYTHONPATH%\%cpu_arch%\py.exe
:: Installed Python DLLs directory (installed via Chocolatey)
set PYDLLPATH=C:\Python311\DLLs

:::::::::::::::::::::::::
:::: Script Output
:::::::::::::::::::::::::

echo.
echo Openssl/Python Build Directory: %base_dir%
echo OpenSSL/Python already built?: %ossl_python_already_built%
echo Building OpenSSL/Python?: %build_openssl_python%
echo Building NCPA?: %build_ncpa%
echo.
echo Getting:
echo 7z:        %ver_7z%
echo Python:    %python_ver%
echo OpenSSL:   %openssl_ver%
echo.
echo CPU Architecture: %cpu_arch%