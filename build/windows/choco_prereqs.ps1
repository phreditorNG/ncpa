<#
    choco_prereqs.ps1

    This script downloads and installs Chocolatey and the necessary
    prerequisites to build Python with a custom OpenSSL version
    as well as the necessary prerequisites to build NCPA.
#>

# Force PowerShell to use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if (-not $download_files){
    if (-not (Test-Path -Path "$base_url\OpenSSL")){ # check ssl
        Write-Host "OpenSSL not found, setting $download_files to $true"
        $download_files = $true
    }
    if (-not (Test-Path -Path "$base_url\Python-$python_ver")){
        Write-Host "Python not found, setting $download_files to $true"
        $download_files = $true
    }
}

### 1. Install Chocolatey
try {
    choco -v
    Write-Host "Chocolatey already installed, passing..."
} catch {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Add Chocolatey to system path just in case
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "Machine") + ";C:\ProgramData\chocolatey\bin", "Machine")

### 2. Install Git, Perl and Visual Studio Build Tools
Write-Host "Chocolatey installing prerequisites"
choco install git -y
choco install strawberryperl -y
choco install visualstudio2019buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools;includeRecommended" -y
choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.Windows10SDK.18362"
choco install visualstudio2022community -y --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.Windows10SDK.18362"
choco install nasm -y
choco install python -y

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv