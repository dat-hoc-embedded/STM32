@echo off
rem Wrapper to run build_and_flash.ps1 bypassing PowerShell execution policy
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0build_and_flash.ps1" %*
