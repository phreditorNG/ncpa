### 3.0 Build OpenSSL
# navigate to the OpenSSL/Python building directory
Set-Location $base_dir
## 3.0 Download OpenSSL
if($download_files){
    Write-Host "Downloading OpenSSL..."
    Invoke-WebRequest -Uri https://www.openssl.org/source/openssl-$openssl_ver.tar.gz -OutFile $base_dir\openssl-$openssl_ver.tar.gz -ErrorAction Stop
    if ($LASTEXITCODE -ne 0) { Throw "Error downloading OpenSSL to $base_dir" }

    # Wait for file system to catch up
    Start-Sleep -Seconds 30
}

if ($build_openssl_python) {
    ## 3.1 Extract OpenSSL
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