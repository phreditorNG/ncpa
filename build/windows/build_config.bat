@echo off
:::::::::::::::::::::::::
:::: Build Configuration
:::::::::::::::::::::::::

:::: OpenSSL/Python Build Directory
set base_dir=%USERPROFILE%\NCPA-Building_Python

:::: Build Options
:: install_prereqs              - whether to use Chocolatey to install prerequisites
:: download_openssl_and_python  - whether to download OpenSSL/Python or use local copies
:: build_openssl_python         - whether to build OpenSSL/Python - if false, will use installed Python
:: build_ncpa                   - whether to build NCPA
set install_prereqs=true
set download_openssl_and_python=true
set build_openssl_python=true
set build_ncpa=true

if exist "%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild\amd64\py.exe" (
    set ossl_python_already_built=true
) else (
    set ossl_python_already_built=false
)

:::: Product version selection
set ver_7z=2301-x64
set python_ver=3.11.3
set openssl_ver=3.0.8

:::::::::::::::::::::::::
:::: Auto-Configuration
:::::::::::::::::::::::::

:: Splice Python version to get install directory C:\Python<version> (e.g. C:\Python311)
for /f "tokens=1-2 delims=." %%a in ("%python_ver%") do set major=%%a&set minor=%%b
set py_ver_spliced=%major%%minor%

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
:: Python building directory
set PYTHONPATH=%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild
:: Built Python OpenSSL files directory
set PYSSLPATH=%PYTHONPATH%\%cpu_arch%\
:: Built Python Launcher
set PYEXEPATH=%PYTHONPATH%\%cpu_arch%\py.exe
:: Installed Python DLLs directory (installed via Chocolatey)
set PYDLLPATH=C:\Python%py_ver_spliced%\DLLs

if (%build_ncpa%) (
    if (%build_openssl_python%) (
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

if (%build_ncpa%) (
    if (%build_openssl_python%) (
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