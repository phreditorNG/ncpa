@echo off
:::::::::::::::::::::::::
:::: Build Configuration
:::::::::::::::::::::::::

echo.
set base_dir=%USERPROFILE%\NCPA-Building_Python
echo Openssl/Python Build Directory: %base_dir%

:::: Build Options
set install_prereqs=true
set build_openssl_python=true
set build_ncpa=true


if exist "%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild\amd64\py.exe" (
    set ossl_python_already_built=true
) else (
    set ossl_python_already_built=false
    set build_openssl_python=true
)

echo OpenSSL/Python already built?: %ossl_python_already_built%
echo Building OpenSSL/Python?: %build_openssl_python%
echo Building NCPA?: %build_ncpa%
echo.

:: product version selection
set ver_7z=2301-x64
set python_ver=3.11.3
set openssl_ver=3.0.8
echo Getting:
echo 7z:        %ver_7z%
echo Python:    %python_ver%
echo OpenSSL:   %openssl_ver%
echo.

:: CPU Architecture
:: TODO: build not tested on ARM64 or x86
set "cpu_arch=%PROCESSOR_ARCHITECTURE%"
if "%cpu_arch%"=="AMD64" (
    set cpu_arch=amd64
) else if "%cpu_arch%"=="x86" (
    set cpu_arch=win32
) else if "%cpu_arch%"=="ARM64" (
    set cpu_arch=arm64
)
echo CPU Architecture: %cpu_arch%

:: Python building directory
set PYTHONPATH=%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild
:: Built Python OpenSSL files directory
set PYSSLPATH=%PYTHONPATH%\%cpu_arch%\
:: Built Python Launcher
set PYEXEPATH=%PYTHONPATH%\%cpu_arch%\py.exe

:: Installed Python DLLs directory (installed via Chocolatey)
set PYDLLPATH=C:\Python311\DLLs