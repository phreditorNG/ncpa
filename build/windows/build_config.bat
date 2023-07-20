@echo off
:::::::::::::::::::::::::
:::: Build Configuration
:::::::::::::::::::::::::

:: 7-Zip   - sourced from https://www.7-zip.org/a/7z%7z_ver%.exe
:: OpenSSL - sourced from https://www.openssl.org/source/openssl-%openssl_ver%.tar.gz
:: Python  - sourced from https://www.python.org/ftp/python/%python_ver%/Python-%python_ver%.tgz
set ver_7z=2301-x64
set openssl_ver=3.0.8
set python_ver=3.11.4

:::: OpenSSL/Python Build Directory
set base_dir=%USERPROFILE%\NCPA-Building_Python

:::: Build Options
:: NOTE: these will be overridden by command line options
:: install_prereqs              - whether to use Chocolatey to install prerequisites
:: download_openssl_and_python  - whether to download OpenSSL/Python or use local copies
:: build_openssl_python         - whether to build OpenSSL/Python - if false, will use installed Python
:: build_ncpa                   - whether to build NCPA
set install_prereqs=true
set download_openssl_and_python=true
set build_openssl_python=true
set build_ncpa=true

:::::::::::::::::::::::::
:::: Auto-Configuration
:::::::::::::::::::::::::

if exist "%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild\amd64\py.exe" (
    set python_already_built=true
) else (
    set python_already_built=false
)

:::: Take options from command line
:options_loop
if "%~1"=="" goto :end_options_loop
if "%~1"=="-h" (
    echo.
    echo        ---------------------------
    echo Usage: build_windows.bat [options]
    echo        ---------------------------
    echo.
    echo Options:
    echo -h                  Show this help message
    echo -np, -no_prereqs    Do not install prerequisites
    echo -nd, -no_download   Do not download OpenSSL/Python
    echo -nb, -no_build      Do not build OpenSSL/Python
    echo -nn, -no_ncpa       Do not build NCPA
    echo.
    echo          ----------------------------------
    echo Example: build_windows.bat -no_download -nb
    echo          ----------------------------------
    echo In this example, the script skips downloading and building OpenSSL/Python. It will build NCPA with the Python installed through the prerequisites instead.
    echo.
    echo.
    echo !!!!!!!!!! WARNING !!!!!!!!!!
    echo Do not run this script on a production machine, it will install Chocolatey and other software.
    echo This may break your system.
    echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    exit /B 1
)
:: --python-ver=<version> - specify Python version to build (e.g. --python-ver=3.11.4)
if "%~1"=="--python-ver" (
    set python_ver=%~2
    shift
    shift
    print python_ver: %python_ver%
    exit /B 1
    goto :options_loop
)
:: --openssl-ver=<version> - specify OpenSSL version to build (e.g. --openssl-ver=3.0.8)
if "%~1"=="--openssl-ver" (
    set openssl_ver=%~2
    shift
    shift
    print openssl_ver: %openssl_ver%
    exit /B 1
    goto :options_loop
)
if "%~1"=="-no_prereqs"  goto :no_prereqs
if "%~1"=="-np"          goto :no_prereqs
if "%~1"=="-no_download" goto :no_download
if "%~1"=="-nd"          goto :no_download
if "%~1"=="-no_build"    goto :no_build
if "%~1"=="-nb"          goto :no_build
if "%~1"=="-no_ncpa"     goto :no_ncpa
if "%~1"=="-nn"          goto :no_ncpa
goto :invalid
:no_prereqs
    set install_prereqs=false
    shift
    goto :options_loop
:no_download
    set download_openssl_and_python=false
    shift
    goto :options_loop
:no_build
    set build_openssl_python=false
    shift
    goto :options_loop
:no_ncpa
    set build_ncpa=false
    shift
    goto :options_loop
:invalid
    echo Invalid option: %~1, use -h for help
    shift
    goto :options_loop
:end_options_loop

:::: CPU Architecture
:: Tested on AMD64
:: TODO: test build on ARM64 and x86
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

:: Splice Python version to get install directory C:\Python<version> (e.g. C:\Python311)
for /f "tokens=1-2 delims=." %%a in ("%python_ver%") do set major=%%a&set minor=%%b
set py_ver_spliced=%major%%minor%

:: Python building directory
set PYTHONPATH=%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild
:: Built Python OpenSSL files directory
set PYSSLPATH=%PYTHONPATH%\%cpu_arch%\
:: Built Python Launcher
set PYEXEPATH=%PYTHONPATH%\%cpu_arch%\py.exe
:: Installed Python DLLs directory (installed via Chocolatey)
set PYDLLPATH=C:\Python%py_ver_spliced%\DLLs

if "%build_ncpa%"=="true" (
    if "%build_openssl_python%"=="true" (
        :: use built Python
        set PYTHONPATH=%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild
        set PYSSLPATH=%PYTHONPATH%\%cpu_arch%\
        set PYEXEPATH=%PYTHONPATH%\%cpu_arch%\py.exe
        set PYDLLPATH=%PYTHONPATH%\%cpu_arch%\DLLs
    ) else (
        :: use installed Python
        set PYTHONPATH=C:\Windows\
        set PYEXEPATH=C:\Windows\py.exe
        :: set other build options to false
        set download_openssl_and_python=false
        set build_openssl_python=false
    )
)

:::::::::::::::::::::::::
:::: Script Output
:::::::::::::::::::::::::

echo.
echo Install Prerequisites?: %install_prereqs%
echo Download OpenSSL/Python?: %download_openssl_and_python%
echo Build OpenSSL/Python?: %build_openssl_python%
echo Build NCPA?: %build_ncpa%
echo.

if "%build_ncpa%"=="true" (
    if "%build_openssl_python%"=="true" (
        echo Building NCPA with Built Python
        echo Openssl/Python Build Directory: %base_dir%
        echo OpenSSL/Python already built?: %ossl_python_already_built%
        echo Building OpenSSL/Python?: %build_openssl_python%
        echo Building NCPA?: %build_ncpa%
        goto :build_ncpa
    ) else (
        echo Building NCPA with Installed Python
        echo Python Executable: %PYEXEPATH%
        goto :build_ncpa_wo_openssl_python
    )
)

:show_versions
echo.
echo Getting:
echo 7z:        %ver_7z%
echo Python:    %python_ver%
echo OpenSSL:   %openssl_ver%
echo.
echo CPU Architecture: %cpu_arch%