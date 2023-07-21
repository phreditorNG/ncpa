### 3.0 Build OpenSSL
# navigate to the OpenSSL/Python building directory
Set-Location $base_dir
## 3.0 Download OpenSSL
if($download_files){
    Write-Host "Downloading OpenSSL..."
    Invoke-WebRequest -Uri https://www.openssl.org/source/openssl-$openssl_ver.tar.gz -OutFile $base_dir\openssl-$openssl_ver.tar.gz -ErrorAction Stop
    if ($LASTEXITCODE -ne 0) { Throw "Error downloading OpenSSL to $base_dir" }

    # Wait for file system to catch up
    Start-Sleep -Seconds 5
}

if ($build_openssl) {
    ## 3.1 Extract OpenSSL
    Write-Host "Extracting OpenSSL..."
    #verify that the OpenSSL tar file exists
    if (-not (Test-Path -Path "$base_dir\openssl-$openssl_ver.tar.gz")) {
        Throw "OpenSSL tar file does not exist: $base_dir\openssl-$openssl_ver.tar.gz"
    }
    # verify 7zextractor exists
    if (-not (Test-Path -Path $7zextractor)) {
        Throw "7z.exe not found: $7zextractor"
    }
    $openssl_tar = "$base_dir\openssl-$openssl_ver.tar.gz"
    Write-Host "Extracting $openssl_tar"
    Start-Process -FilePath $7zextractor -ArgumentList "x `"$openssl_tar`" `-o`"$base_dir`" -y" -Wait
    $openssl_tar_extracted = ($openssl_tar -replace '.tar.gz', '.tar')
    Write-Host "Extracting $openssl_tar_extracted"
    Start-Process -FilePath $7zextractor -ArgumentList "x `"$openssl_tar_extracted`" `-o`"$base_dir`" -y" -Wait
    if ($LASTEXITCODE -ne 0) { Throw "Error extracting openssl-$openssl_ver.tar.gz" }

    ## 3.2 Build & Install OpenSSL
    Set-Location $base_dir\openssl-$openssl_ver
    Write-Host "Building and installing OpenSSL..."
    cmd /c "`"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat`" -arch=amd64 && perl Configure VC-WIN64A --prefix=$openssl_dir && cmd /c `"`"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat`" -arch=amd64 && nmake && nmake test && nmake install`""
    $env:OPENSSL_ROOT_DIR = "$base_url\OpenSSL"
    $env:OPENSSL_DIR = "$base_url\OpenSSL"
    if ($LASTEXITCODE -ne 0) { Throw "Error configuring/building/installing OpenSSL" }

    Write-Host "----------------------------------------"
    Write-Host "OpenSSL build complete"
    Write-Host "----------------------------------------"
} else {
    Write-Host "Skipping OpenSSL build"
}