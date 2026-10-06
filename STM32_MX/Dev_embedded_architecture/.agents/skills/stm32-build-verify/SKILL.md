---
name: stm32-build-verify
description: >-
  Builds, flashes, and verifies STM32 firmware using CMake Presets, ARM GCC,
  STM32CubeProgrammer CLI, and Cppcheck static analysis.
---

# STM32 Build & Verification Guide (`/stm32-build-verify`)

Use this skill to compile firmware, run static analysis on user modules, and verify flashing on target STM32 hardware.

---

## 1. Automated Build Pipeline

### Configure & Build with CMake Presets
```powershell
# From project root directory:
# Step 1: Configure project preset (Debug)
cmake --preset Debug

# Step 2: Compile target binary (Dev_embedded_architecture.elf)
cmake --build build/Debug
```

### Static Analysis with Cppcheck
```powershell
# Run cppcheck on custom user modules in Core/User/
cppcheck --enable=warning,style,performance,portability --inline-suppr --error-exitcode=1 Core/User/
```

---

## 2. Hardware Flashing & Diagnostics (STM32CubeProgrammer CLI)

STM32CubeProgrammer CLI is typically installed at:
`C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe` (or in system PATH).

### Common STM32_Programmer_CLI Commands
```powershell
# 1. Inspect connected ST-Link debug probes
STM32_Programmer_CLI --list

# 2. Connect and read device ID
STM32_Programmer_CLI --connect port=SWD

# 3. Flash compiled ELF binary, perform hardware reset, and start execution
STM32_Programmer_CLI --connect port=swd --download build/Debug/Dev_embedded_architecture.elf -hardRst -rst --start

# 4. Read memory range (e.g. Option bytes or Flash start)
STM32_Programmer_CLI --connect port=SWD --read 0x08000000 0x100
```

---

## 3. Troubleshooting Build Failures

- **Undefined Reference in User Module:** Ensure the `.c` source file is added to `target_sources()` and the include directory is added to `target_include_directories()` in the root `CMakeLists.txt`.
- **Flash/RAM Overflow:** Check map file (`build/Debug/Dev_embedded_architecture.map`). Compare memory section sizes against `STM32F411XX_FLASH.ld`. Reduce statically allocated buffer sizes if necessary.
- **Header Not Found:** Check that include directories in `CMakeLists.txt` match the actual folder structure in `Core/User/<module>/`.
- **Overwritten Code:** If code disappeared after running STM32CubeMX, ensure custom code was placed in `Core/User/` or within `/* USER CODE BEGIN */` ... `/* USER CODE END */`.
