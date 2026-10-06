# build_check.ps1 - Fast CMake + ARM GCC Build Verification for STM32
param (
    [string]$Preset = "Debug"
)

$ErrorActionPreference = "Continue"

Write-Host "=== Starting STM32 Firmware Build Verification ===" -ForegroundColor Cyan

# Check if build directory exists
if (-not (Test-Path "build/$Preset")) {
    Write-Host "Configuring CMake with preset '$Preset'..." -ForegroundColor Yellow
    cmake --preset $Preset
}

# Run build
Write-Host "Compiling STM32 firmware target with CMake..." -ForegroundColor Yellow
cmake --build "build/$Preset"

if ($LASTEXITCODE -eq 0) {
    Write-Host "=== Build Successful! Binary ready in build/$Preset/ ===" -ForegroundColor Green
    exit 0
} else {
    Write-Host "=== Build FAILED with exit code $LASTEXITCODE ===" -ForegroundColor Red
    exit 1
}
