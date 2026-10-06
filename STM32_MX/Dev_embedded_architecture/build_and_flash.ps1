<#
.SYNOPSIS
    Automated Clean Rebuild and Flash script for STM32 firmware using CMake and STM32CubeProgrammer CLI.

.DESCRIPTION
    Builds and optionally flashes the STM32 project.
    Supports clean rebuilds, CMake preset configuration, and hardware flashing via SWD/ST-Link.

.PARAMETER Preset
    CMake preset to use. Defaults to "Debug". Options: Debug, Release, RelWithDebInfo, MinSizeRel.

.PARAMETER Clean
    Switch to force a clean rebuild (rebuilds all targets from scratch). Default is true if called without -Clean:$false.

.PARAMETER Flash
    Switch to flash the built ELF binary to the target MCU via STM32_Programmer_CLI.

.PARAMETER Port
    Flashing port. Default is "swd".

.EXAMPLE
    .\build_and_flash.ps1
    Performs a clean rebuild of Debug preset.

.EXAMPLE
    .\build_and_flash.ps1 -Flash
    Performs a clean rebuild and flashes the target MCU over SWD.

.EXAMPLE
    .\build_and_flash.ps1 -Preset Release -Flash
    Performs clean rebuild with Release preset and flashes target.
#>

[CmdletBinding()]
param (
    [string]$Preset = "Debug",
    [switch]$Clean = $true,
    [switch]$Flash = $false,
    [string]$Port = "swd"
)

$ErrorActionPreference = "Stop"

# Paths
$WorkspaceRoot = $PSScriptRoot
$BuildDir = Join-Path $WorkspaceRoot "build\$Preset"
$ElfPath = Join-Path $BuildDir "Dev_embedded_architecture.elf"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[STEP] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Host "============================================================" -ForegroundColor Magenta
Write-Host "  STM32 Build & Flash Orchestrator                          " -ForegroundColor Magenta
Write-Host "  Preset: $Preset | Clean: $Clean | Flash: $Flash           " -ForegroundColor Magenta
Write-Host "============================================================" -ForegroundColor Magenta

# --- 1. Verify CMake and Generator ---
Write-Step "Checking build prerequisites..."
if (-not (Get-Command "cmake" -ErrorAction SilentlyContinue)) {
    Write-ErrorMsg "CMake not found in PATH! Ensure CMake is installed and added to PATH."
    exit 1
}

# --- 2. Configure CMake Preset if needed ---
if (-not (Test-Path $BuildDir)) {
    Write-Step "Configuring CMake preset '$Preset'..."
    Push-Location $WorkspaceRoot
    try {
        cmake --preset $Preset
        if ($LASTEXITCODE -ne 0) { throw "CMake configuration failed." }
    }
    finally {
        Pop-Location
    }
}

# --- 3. Compile / Clean Rebuild ---
Push-Location $WorkspaceRoot
try {
    if ($Clean) {
        Write-Step "Executing Clean Rebuild for preset '$Preset'..."
        cmake --build $BuildDir --clean-first
    } else {
        Write-Step "Compiling target for preset '$Preset'..."
        cmake --build $BuildDir
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Compilation failed with exit code $LASTEXITCODE."
    }
    Write-Success "Firmware compiled successfully: $ElfPath"
}
catch {
    Write-ErrorMsg $_.Exception.Message
    Pop-Location
    exit 1
}
finally {
    Pop-Location
}

# Display binary size summary
if (Test-Path $ElfPath) {
    if (Get-Command "arm-none-eabi-size" -ErrorAction SilentlyContinue) {
        Write-Step "Memory consumption summary:"
        arm-none-eabi-size $ElfPath
    }
} else {
    Write-ErrorMsg "Binary ELF file not found at: $ElfPath"
    exit 1
}

# --- 4. Flash Target if -Flash is specified ---
if ($Flash) {
    Write-Step "Preparing to flash target via STM32_Programmer_CLI (Port: $Port)..."

    # Locate STM32_Programmer_CLI executable
    $ProgrammerCli = Get-Command "STM32_Programmer_CLI" -ErrorAction SilentlyContinue
    $ProgrammerPath = if ($ProgrammerCli) {
        $ProgrammerCli.Source
    } elseif (Test-Path "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe") {
        "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
    } else {
        $null
    }

    if (-not $ProgrammerPath) {
        Write-ErrorMsg "STM32_Programmer_CLI not found in PATH or standard installation directory!"
        Write-ErrorMsg "Please install STM32CubeProgrammer or add its bin directory to PATH."
        exit 1
    }

    Write-Host "Using programmer: $ProgrammerPath" -ForegroundColor DarkGray

    # Execute download & run
    & $ProgrammerPath --connect "port=$Port" --download $ElfPath -hardRst -rst --start
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMsg "Flashing failed with exit code $LASTEXITCODE. Ensure ST-Link is connected."
        exit $LASTEXITCODE
    }

    Write-Success "Target flashed and started successfully!"
}

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "  Done!                                                    " -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
exit 0
