### 4. Build Python
# Note: $cpython_dir is $base_dir\Python-$python_ver\Python-$python_ver\

if ($download_files){
    ## 4.0 Download Python
    Write-Host "Downloading Python..."
    Invoke-WebRequest -Uri https://www.python.org/ftp/python/$python_ver/Python-$python_ver.tgz -OutFile $base_dir\Python-$python_ver.tgz -ErrorAction Stop
    if ($LASTEXITCODE -ne 0) { Throw "Error downloading Python to $base_dir" }

    # Wait for file system to catch up
    Start-Sleep -Seconds 15
}

if($build_python){
    ## 4.1 Extract Python
    Write-Host "Extracting Python..."
    #verify that the Python tar file exists
    if (-not (Test-Path -Path "$base_dir\Python-$python_ver.tgz")) {
        Throw "Python tar file does not exist: $base_dir\Python-$python_ver.tgz"
    }
    # verify 7zextractor exists
    if (-not (Test-Path -Path $7zextractor)) {
        Throw "7z.exe not found: $7zextractor"
    }
    $python_tar = "$base_dir\Python-$python_ver.tgz"
    Write-Host "Extracting $python_tar"
    Start-Process -FilePath $7zextractor -ArgumentList "x `"$python_tar`" `-o`"$base_dir`" -y" -Wait

    $python_tar_extracted = $python_tar -replace '\.tgz$', '.tar'
    Write-Host "Extracting $python_tar_extracted"
    Start-Process -FilePath $7zextractor -ArgumentList "x `"$python_tar_extracted`" `-o`"$base_dir\Python-$python_ver`" -y" -Wait

    if ($LASTEXITCODE -ne 0) { Throw "Error extracting Python-$python_ver.tgz" }
    # Wait for file system to catch up
    Start-Sleep -Seconds 15

    ## 4.2 Add custom OpenSSL to the Python build
    # 4.2.0 Copy OpenSSL files from
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

    # $python_ssl is the directory for the OpenSSL externals used in the CPython build
    # $python_ssl = "$cpython_dir\externals\openssl-bin-*"
    $python_ssl_pattern = "openssl-bin-*"
    $python_ssl = Get-ChildItem -Path "$cpython_dir\externals" `
        -Filter $python_ssl_pattern | Select-Object -ExpandProperty FullName

    # Backup the existing folder
    if (Test-Path "$python_ssl\$cpu_arch") {
        Copy-Item -Path "$python_ssl\$cpu_arch" -Destination "$python_ssl\$cpu_arch-backup" -Force -Recurse
    } else {
        Write-Host "Source folder does not exist: $python_ssl\$cpu_arch"
    }

    # Copy the new OpenSSL files to the Python build
    if (Test-Path "$base_dir\OpenSSL\include") {
        Copy-Item -Path "$base_dir\OpenSSL\include" -Destination "$python_ssl\$cpu_arch" -Force -Recurse
    } else {
        Write-Host "Destination folder does not exist: $base_dir\OpenSSL\include"
    }
    $openssl_binfiles = "libcrypto-3-x64.dll", "libcrypto-3-x64.pdb", "libssl-3-x64.dll", "libssl-3-x64.pdb"
    foreach ($binfile in $openssl_binfiles) {
        Copy-Item -Path "$base_dir\OpenSSL\bin\$binfile" -Destination "$python_ssl\$cpu_arch" -Force
    }
    $openssl_libfiles = "libcrypto.lib", "libssl.lib"
    foreach ($libfile in $openssl_libfiles) {
        Copy-Item -Path "$base_dir\OpenSSL\lib\$libfile" -Destination "$python_ssl\$cpu_arch" -Force
    }

    # 4.2.1 Rewrite PCbuild\openssl.props to use our moved OpenSSL 3 files instead of the old 1.1.1
    Write-Host "Rewriting PCbuild\openssl.props"
    $openssl_props = "$cpython_dir\PCbuild\openssl.props"
    $content = Get-Content "$openssl_props" -Raw
    $content = $content -replace '<_DLLSuffix>-1_1</_DLLSuffix>', '<_DLLSuffix>-3</_DLLSuffix>'
    $content = $content -replace '<OpenSSLDLLSuffix>\$\(.*?\)</OpenSSLDLLSuffix>', '<_DLLSuffix Condition="$(Platform) == ''x64''">$(_DLLSuffix)-x64</_DLLSuffix>'
    $content = $content -replace '<Target Name="_CopySSLDLL"\s+Inputs="\$\(.*?\)"\s+Outputs="\$\(.*?\)"\s+Condition="\$\(SkipCopySSLDLL\) == ''''"\s+AfterTargets="Build">', '<Target Name="_CopySSLDLL" Inputs="@(_SSLDLL)" Outputs="@(_SSLDLL->''$(OutDir)%(Filename)%(Extension)'')" AfterTargets="Build">'
    $content = $content -replace '<Target Name="_CleanSSLDLL" Condition="\$\(SkipCopySSLDLL\) == ''''" BeforeTargets="Clean">', '<Target Name="_CleanSSLDLL" BeforeTargets="Clean">'
    $content | Set-Content -Path $openssl_props

    ## 4.3 Build Python
    # Add openssl to build:
    Write-Host "Building Python..."
    cmd /c "`"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat`" -arch=amd64 && $cpython_dir\PCbuild\build.bat -p x64"
    Write-Host $pwd
    if ($LASTEXITCODE -ne 0) { Throw "Error building Python" }

    Write-Host "----------------------------------------"
    Write-Host "Python build complete"
    Write-Host "----------------------------------------"
} else {
    Write-Host "Skipping Python build, resorting to installed Python version $installed_version"
}