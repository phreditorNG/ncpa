##### ----------------------------------
###    Run this script as administrator
##### ----------------------------------

##### ----------------------------------
#
# BuildPython.ps1
#
# This script downloads and installs the
# necessary prerequisites to build Python
# with a custom OpenSSL version
#
# This script is intended to be run on a
# build machine or VM and not on a
# production server
#
##### ----------------------------------

##### ----------------------------------
#
# Table of Contents:
# |- 0. Script Configuration
# |- 1. Chocolatey Script
#    |- 1.0 Install Chocolatey
#    |- 1.1 Install Git, Perl and Visual Studio Build Tools with Chocolatey
# |- 2. Install 7-Zip
# |- 3. Build/Install OpenSSL
# |- 4. Build Python
#
##### ----------------------------------

### 0. Script Configuration
Param(
    [string]$7z_ver,        # 7-Zip version to install (e.g. 2301-x64)
    [string]$openssl_ver,   # OpenSSL version to build (e.g. 3.0.8)
    [string]$python_ver,    # Python version to build (e.g. 3.11.3)

    [string]$ncpa_build_dir,# NCPA repo directory
    [string]$base_dir       # Custom OpenSSL and Python build directory
)
$openssl_dir = "$base_dir\OpenSSL\"
$cpython_dir = "$base_dir\Python-$python_ver\Python-$python_ver\"

## legacy - now passed in as params as seen above
#$7z_ver      = "2301-x64" # 7-Zip   - sourced from https://www.7-zip.org/a/7z$7z_ver.exe
#$openssl_ver = "3.0.8"    # OpenSSL - sourced from https://www.openssl.org/source/openssl-$openssl_ver.tar.gz
#$python_ver  = "3.11.3"   # Python  - sourced from https://www.python.org/ftp/python/$python_ver/Python-$python_ver.tgz
#$base_dir = "$HOME\NCPA-Building_Python"

if (-not (Test-Path -Path $base_dir)) {
    New-Item -ItemType Directory -Path $base_dir | Out-Null
}
Set-Location $base_dir

$build_w_openssl = $true  # build Python with OpenSSL ($true/$false)
$download_files  = $true  # download fresh tarballs (OpenSSL/Python) ($true/$false)
$preserve_files  = $true  # preserve or delete downloaded OpenSSL and Python .tar.gz and .tgz files ($true/$false)

# If OpenSSL is already built/installed in $openssl_dir, give option to not build
$build_openssl = $false
if ($build_w_openssl -and $download_files){
    if (Test-Path -Path "$openssl_dir\bin\openssl.exe"){
        $installed_version = & "$openssl_dir\bin\openssl.exe" version
        $installed_version = $installed_version -replace 'OpenSSL\s*','' -replace 's*([^\s]*).*','$1'
        $userInput = Read-Host -Prompt "`nOpenSSL $installed_version already installed. Do you want to download/build/install OpenSSL version $openssl_ver`? `n(y/n)"
        if ($userInput -eq "yes" -or $userInput -eq "y"){
            $build_openssl = $true
        }
    } else { $build_openssl = $true }
}

### 1. Chocolatey Script
## 1.0 Install Chocolatey
## 1.1 Install Git, Perl and Visual Studio Build Tools with Chocolatey
Write-Host "Running Chocolatey install script..."
. $ncpa_build_dir\windows\choco_prereqs.ps1

# Add Perl, NASM, Git, etc. to the PATH
Write-Host "Adding prerequisites to PATH"
$env:Path += ";C:\Strawberry\perl\bin"
$env:Path += ";C:\Program Files\NASM"
$env:Path += ";C:\Program Files\Git\bin"
$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin"
$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin"

### 2. Download and install 7-zip
if (Test-Path -Path "C:\Program Files\7-Zip"){
    Write-Host "7-Zip already installed"
} else {
    Write-Host "Installing 7-Zip..."
    $7ZipInstaller = "$base_dir\7z$7z_ver.exe"
    Invoke-WebRequest -Uri https://www.7-zip.org/a/7z$7z_ver.exe -Outfile $7ZipInstaller
    Start-Process $7ZipInstaller -ArgumentList "/S" -Wait
    $env:Path += ";C:\Program Files\7-Zip"
    Remove-Item -Path $7ZipInstaller
    if ($LASTEXITCODE -ne 0) { Throw "Error downloading or installing 7-Zip to $base_dir" }
}

### 3. Build OpenSSL
Write-Host "Running OpenSSL build script..."
. $ncpa_build_dir\windows\build_openssl.ps1

### 4. Build Python
Write-Host "Running Python build script..."
. $ncpa_build_dir\windows\build_python.ps1

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv