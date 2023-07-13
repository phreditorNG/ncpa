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
# |- 1. Install Chocolatey
# |- 2. Install Git, Perl and Visual Studio Build Tools with Chocolatey
# |- 3. Install 7-Zip
# |- 4. Build/Install OpenSSL
# |- 5. Build Python
#
##### ----------------------------------

### 0. Script Configuration
Param(
    [string]$7z_ver,
    [string]$openssl_ver,
    [string]$python_ver,

    [string]$base_dir
)

## legacy - now passed in as params as seen above
#$7z_ver      = "2301-x64" # 7-Zip   - sourced from https://www.7-zip.org/a/7z$7z_ver.exe
#$openssl_ver = "3.0.8"    # OpenSSL - sourced from https://www.openssl.org/source/openssl-$openssl_ver.tar.gz
#$python_ver  = "3.11.3"   # Python  - sourced from https://www.python.org/ftp/python/$python_ver/Python-$python_ver.tgz
#$base_dir = "$HOME\NCPA-Building_Python"

if (-not (Test-Path -Path $base_dir)){
    New-Item -ItemType Directory -Path $base_dir | Out-Null
}
cd $base_dir

$build_w_openssl = $true  # build Python with OpenSSL ($true/$false)
$download_files  = $true  # download fresh tarballs (OpenSSL/Python) ($true/$false)
$preserve_files  = $true  # preserve or delete downloaded OpenSSL and Python .tar.gz and .tgz files ($true/$false)

# If OpenSSL is already built/installed in $openssl_dir, give option to not build
$build_openssl = $false
if ($download_files){
    if (Test-Path -Path "$openssl_dir\bin\openssl.exe"){
        $installed_version = & "$openssl_dir\bin\openssl.exe" version
        $installed_version = $installed_version -replace 'OpenSSL\s*','' -replace 's*([^\s]*).*','$1'
        $userInput = Read-Host -Prompt "`nOpenSSL $installed_version already installed. Do you want to download/build/install OpenSSL version $openssl_ver`? `n(y/n)"
        if ($userInput -eq "yes" -or $userInput -eq "y"){
            $build_openssl = $true
        }
    } else { $build_openssl = $true }
}


# Add Perl, NASM, Git and nmake to the PATH
Write-Host "Adding prerequisites to PATH"
$env:Path += ";C:\Strawberry\perl\bin"
$env:Path += ";C:\Program Files\NASM"
$env:Path += ";C:\Program Files\Git\bin"
$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin"
$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin"

### 3. Download and install 7-zip
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

### 4. Build OpenSSL
# OpenSSL takes three eternities to build, so we give the option to skip if they have it installed already
if ($build_openssl) {
    cd $base_dir
    ## 4.0 Download OpenSSL
    if($download_files){
        Write-Host "Downloading OpenSSL..."
        Invoke-WebRequest -Uri https://www.openssl.org/source/openssl-$openssl_ver.tar.gz -OutFile $base_dir\openssl-$openssl_ver.tar.gz -ErrorAction Stop
        if ($LASTEXITCODE -ne 0) { Throw "Error downloading OpenSSL to $base_dir" }
    }

    ## 4.1 Extract OpenSSL
    Write-Host "Extracting OpenSSL..."
    $openssl_tar = "$base_dir\openssl-$openssl_ver.tar.gz"
    Write-Host "Extracting $openssl_tar"
    Start-Process -FilePath '7z.exe' -ArgumentList "x `"$openssl_tar`" `-o`"$base_dir`" -y" -Wait
    $openssl_tar_extracted = ($openssl_tar -replace '.tar.gz', '.tar')
    Write-Host "Extracting $tar2"
    Start-Process -FilePath '7z.exe' -ArgumentList "x `"$openssl_tar_extracted`" `-o`"$base_dir`" -y" -Wait
    if ($LASTEXITCODE -ne 0) { Throw "Error extracting openssl-$openssl_ver.tar.gz" }

    if (-not $preserve_files){
        Remove-Item -Path $openssl_tar, ($openssl_tar -replace '\.tar.gz', '.tar')
    }
    if ($LASTEXITCODE -ne 0) { Throw "Error removing OpenSSL files" }

    cd openssl-$openssl_ver # $base_dir\openssl-$openssl_ver

    ## 4.2 Build & Install OpenSSL
    Write-Host "Building and installing OpenSSL..."
    cmd /c "`"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat`" -arch=amd64 && perl Configure VC-WIN64A --prefix=$openssl_dir && nmake && nmake test && nmake install"
    $env:OPENSSL_ROOT_DIR = "$base_url\OpenSSL"
    $env:OPENSSL_DIR = "$base_url\OpenSSL"
    if ($LASTEXITCODE -ne 0) { Throw "Error configuring/building/installing OpenSSL" }
}

### 5. Build Python
cd $base_dir
if ($download_files -and $false){ #TODO: remove false
    ## 5.0 Download Python
    Write-Host "Downloading Python..."
    Invoke-WebRequest -Uri https://www.python.org/ftp/python/$python_ver/Python-$python_ver.tgz -OutFile $base_dir\Python-$python_ver.tgz -ErrorAction Stop
    if ($LASTEXITCODE -ne 0) { Throw "Error downloading Python to $base_dir" }

    ## 5.1 Extract Python
    Write-Host "Extracting Python..."
    $python_tar = "$base_dir\Python-$python_ver.tgz"
    Start-Process -FilePath '7z.exe' -ArgumentList "x `"$python_tar`" `-o`"$base_dir`" -y" -Wait
    $python_tar_extracted = $python_tar -replace '\.tgz$', '.tar'
    Start-Process -FilePath '7z.exe' -ArgumentList "x `"$python_tar_extracted`" `-o`"$base_dir\Python-$python_ver`" -y" -Wait
}

# Remove the .tgz and .tar files
if (-not $preserve_files){
    Remove-Item -Path $python_tar, $python_tar_extracted
}
if ($LASTEXITCODE -ne 0) { Throw "Error extracting Python-$python_ver.tgz" }

$cpython_dir = "$base_dir\Python-$python_ver\Python-$python_ver\"

## 5.2 Add custom OpenSSL to the Python build
# 5.2.0 Copy OpenSSL files from
#   $base_url\OpenSSL
#     to
#   $base_url\Python-$python_ver\Python-$python_ver\externals\openssl-bin-version\your_cpu_architecture

Write-Host "Copying custom OpenSSL to Python build externals"
Copy-Item -Path "$base_dir\OpenSSL\include\openssl\applink.c" -Destination "$base_dir\OpenSSL\include\applink.c" -Force
$cpu_arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
switch($cpu_arch){
    "AMD64" { $cpu_arch = "amd64" }
    "x86"   { $cpu_arch = "win32" }
    "ARM64" { $cpu_arch = "arm64" }
}
$python_ssl_pattern = "openssl-bin-*"
$python_ssl = Get-ChildItem -Path "$cpython_dir\externals" `
    -Filter $python_ssl_pattern | Select-Object -ExpandProperty FullName
Copy-Item -Path "$python_ssl\$cpu_arch"     -Destination "$python_ssl\$cpu_arch-backup" -Force -Recurse
Copy-Item -Path "$base_dir\OpenSSL\include" -Destination "$python_ssl\$cpu_arch"        -Force -Recurse

$openssl_binfiles = "libcrypto-3-x64.dll", "libcrypto-3-x64.pdb", "libssl-3-x64.dll", "libssl-3-x64.pdb"
foreach ($binfile in $openssl_binfiles) {
    Copy-Item -Path "$base_dir\OpenSSL\bin\$binfile" -Destination "$python_ssl\$cpu_arch" -Force
}
$openssl_libfiles = "libcrypto.lib", "libssl.lib"
foreach ($libfile in $openssl_libfiles) {
    Copy-Item -Path "$base_dir\OpenSSL\lib\$libfile" -Destination "$python_ssl\$cpu_arch" -Force
}

# 5.2.1 Rewrite PCbuild\openssl.props to use our added OpenSSL 3 files instead of the old 1.1.1
Write-Host "Rewriting PCbuild\openssl.props"
$openssl_props = "$cpython_dir\PCbuild\openssl.props"
$content = Get-Content "$openssl_props" -Raw
$content = $content -replace '<_DLLSuffix>-1_1</_DLLSuffix>', '<_DLLSuffix>-3</_DLLSuffix>'
$content = $content -replace '<OpenSSLDLLSuffix>\$\(.*?\)</OpenSSLDLLSuffix>', '<_DLLSuffix Condition="$(Platform) == ''x64''">$(_DLLSuffix)-x64</_DLLSuffix>'
$content = $content -replace '<Target Name="_CopySSLDLL"\s+Inputs="\$\(.*?\)"\s+Outputs="\$\(.*?\)"\s+Condition="\$\(SkipCopySSLDLL\) == ''''"\s+AfterTargets="Build">', '<Target Name="_CopySSLDLL" Inputs="@(_SSLDLL)" Outputs="@(_SSLDLL->''$(OutDir)%(Filename)%(Extension)'')" AfterTargets="Build">'
$content = $content -replace '<Target Name="_CleanSSLDLL" Condition="\$\(SkipCopySSLDLL\) == ''''" BeforeTargets="Clean">', '<Target Name="_CleanSSLDLL" BeforeTargets="Clean">'
$content | Set-Content -Path $openssl_props


## 5.3 Build Python
# Add openssl to build:
Write-Host "Building Python..."
cmd /c "`"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat`" -arch=amd64 && $cpython_dir\PCbuild\build.bat"
Write-Host $pwd
if ($LASTEXITCODE -ne 0) { Throw "Error building Python" }

# return python executable for build_windows.bat
return "$cpython_dir\PCbuild\$cpu_arch\python.exe"