:::::::::::::::::::::::::
:::: Build Configuration
:::::::::::::::::::::::::

set base_dir=%USERPROFILE%\NCPA-Building_Python
echo Openssl/Python Build Directory: %base_dir%

set build_openssl_python=true
:: skip building OpenSSL/Python (if not found in base_dir, will download/build anyway)
set ossl_python_already_built=false
set build_ncpa=true


if exist "%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild\amd64\py.exe" (
    set ossl_python_already_built=true
) else (
    set ossl_python_already_built=false
)

:: product version selection
set ver_7z=2301-x64
set python_ver=3.11.3
set openssl_ver=3.0.8
echo Getting:
echo 7z: %ver_7z%
echo Python: %python_ver%
echo OpenSSL: %openssl_ver%
echo.

set "cpu_arch=%PROCESSOR_ARCHITECTURE%"
if "%cpu_arch%"=="AMD64" (
    set cpu_arch=amd64
) else if "%cpu_arch%"=="x86" (
    set cpu_arch=win32
) else if "%cpu_arch%"=="ARM64" (
    set cpu_arch=arm64
)
echo CPU Architecture: %cpu_arch%


set PYTHONPATH=%base_dir%\Python-%python_ver%\Python-%python_ver%\PCbuild
set PYSSLPATH=%PYTHONPATH%\%cpu_arch%\
set PYEXEPATH=%PYTHONPATH%\%cpu_arch%\py.exe

set PYDLLPATH=C:\Python311\DLLs