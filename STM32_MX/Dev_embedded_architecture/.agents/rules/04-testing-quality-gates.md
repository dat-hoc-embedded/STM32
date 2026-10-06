# Quality Gates & Verification Standards

All code delivered by AI agents must pass the following verification gates before completion.

---

## 1. Quality Gates Checklist

- [ ] **Firmware Build:** Clean compilation with ARM GCC via CMake/Ninja without errors (`cmake --build build/Debug`).
- [ ] **Static Analysis:** `cppcheck` passes on `Core/User/` with zero critical warnings (no null pointer dereferences, buffer overflows, or uninitialized variables).
- [ ] **Autogen Protection:** Zero modifications to `cmake/stm32cubemx/`, `.mxproject`, or `Drivers/`.
- [ ] **User Code Preservation:** Code in `Core/Src/` and `Core/Inc/` strictly bounded within `/* USER CODE BEGIN */` ... `/* USER CODE END */`.
- [ ] **Interface Footprint:** Public headers adhere to Deep Module standards (<= 7 public functions).
- [ ] **Documentation:** `walkthrough.md` generated with build logs, test proofs, or hardware verification evidence.

---

## 2. Standard Build & Verification Commands

### Firmware Compilation (CMake + Ninja)
```powershell
# Configure preset (Debug)
cmake --preset Debug

# Build project
cmake --build build/Debug
```

### Static Analysis (Cppcheck)
```powershell
# Analyze custom modules in Core/User/
cppcheck --enable=warning,style,performance,portability --inline-suppr --error-exitcode=1 Core/User/
```

### Hardware Flashing & Diagnostics (STM32CubeProgrammer CLI)
```powershell
# Check connected ST-Link probes
STM32_Programmer_CLI --list

# Flash compiled binary over SWD and reset target
STM32_Programmer_CLI --connect port=swd --download build/Debug/Dev_embedded_architecture.elf -hardRst -rst --start
```
