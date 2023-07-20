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

    -install_prereqs %install_prereqs% ^
    -download_openssl_and_python %download_openssl_and_python% ^
    -build_openssl_python %build_openssl_python% ^
    -build_ncpa %build_ncpa%
Param(
    [string]$7z_ver,            # 7-Zip version to install  (e.g. 2301-x64)
    [string]$openssl_ver,       # OpenSSL version to build  (e.g. 3.0.8)
    [string]$python_ver,        # Python version to build   (e.g. 3.11.3)

    [string]$ncpa_build_dir,    # NCPA repo directory
    [string]$base_dir,          # OpenSSL and Python building directory

    [bool]$install_prereqs,     # install prerequisites                         ($true/$false)
    [bool]$download_openssl_python, # download OpenSSL and Python tarballs      ($true/$false)
    [bool]$build_openssl_python,    # build OpenSSL and Python                  ($true/$false)
    [bool]$build_ncpa           # build NCPA                                    ($true/$false)
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

# OpenSSL takes a LOOOONG time to build, give option to not build OpenSSL again
if ($build_openssl_python){
    if (Test-Path -Path "$openssl_dir\bin\openssl.exe"){
        $installed_version = & "$openssl_dir\bin\openssl.exe" version
        $installed_version = $installed_version -replace 'OpenSSL\s*','' -replace 's*([^\s]*).*','$1'
        $userInput = Read-Host -Prompt "`nOpenSSL $installed_version build detected at $openssl_dir. Do you want to download/build/install OpenSSL version $openssl_ver`? `n(y/n)"
        if ($userInput -eq "yes" -or $userInput -eq "y"){
            $build_openssl_python = $true
        }
    } else { $build_openssl_python = $true }
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

if($build_openssl_python) {
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
}

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv