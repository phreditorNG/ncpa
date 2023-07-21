<#
    choco_prereqs.ps1

    This script downloads and installs Chocolatey and the necessary
    prerequisites to build Python with a custom OpenSSL version
    as well as the necessary prerequisites to build NCPA.
#>

# Force PowerShell to use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

### 1. Install Chocolatey
try {
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
    refreshenv
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
if(-not (Get-Command git    -ErrorAction SilentlyContinue)){ choco install git -y }
if(-not (Get-Command perl   -ErrorAction SilentlyContinue)){ choco install strawberryperl -y }
if(-not (Get-Command nasm   -ErrorAction SilentlyContinue)){ choco install nasm -y }
if(-not (Get-Command python -ErrorAction SilentlyContinue)){ choco install python -y }

#choco install visualstudio2019buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools;includeRecommended" -y
choco install visualstudio2022buildtools -y --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.Windows10SDK.18362"
choco install visualstudio2022community -y --package-parameters "--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 --add Microsoft.VisualStudio.Component.Windows10SDK.18362"

Write-Host "----------------------------------------"
Write-Host "Chocolatey install script complete"
Write-Host "----------------------------------------"

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv