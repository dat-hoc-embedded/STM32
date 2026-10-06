---
name: audit-reviewer
description: >-
  Acts as an independent code reviewer with clean context to perform quality gate audits,
  verify STM32 security/memory standards, and generate the walkthrough.md report.
---

# Clean-Context Reviewer & Verification Audit (`/audit-reviewer`)

Use this skill during Phase 6 (Verification & Delivery) before finalizing changes or opening a PR.

---

## 1. Reviewer Audit Criteria

The reviewer agent must audit the changeset against 5 strict criteria:

### A. Memory & Pointer Safety
- [ ] No `malloc`, `calloc`, `free`, or `realloc` anywhere in firmware code.
- [ ] Array indexing bounded by compile-time constant bounds.
- [ ] Pointers validated against `NULL` before dereferencing.

### B. Concurrency & Interrupt Safety
- [ ] Shared state modified in ISRs or across FreeRTOS tasks protected by atomic blocks (`__disable_irq()` / `__set_PRIMASK()`) or mutexes.
- [ ] All variables modified in ISRs marked `volatile`.
- [ ] No blocking delays (`HAL_Delay()` / `while(1)`) in main loop or ISR callbacks.

### C. STM32CubeMX & Vendor File Integrity
- [ ] Zero modifications to files inside `cmake/stm32cubemx/`, `.mxproject`, or `Drivers/`.
- [ ] Any modifications in `Core/Src/` and `Core/Inc/` strictly bounded within `/* USER CODE BEGIN */` ... `/* USER CODE END */`.
- [ ] STM32 HAL return codes (`HAL_StatusTypeDef`) properly checked.

### D. Deep Module Architecture
- [ ] Public headers in `Core/User/<module>/` contain only essential interface functions (<= 7 functions).
- [ ] Private implementation functions declared `static`.

### E. Test & Build Proof
- [ ] Firmware compiles cleanly with CMake (`cmake --build build/Debug`).
- [ ] Static analysis passes (`cppcheck Core/User/`).

---

## 2. Verification Report (`walkthrough.md`)

Generate or update `walkthrough.md` with the following structure:

```markdown
# Verification Walkthrough: [Feature / Change Title]

## Summary of Changes
- Summary of modules modified and features implemented.

## Verification Evidence
### 1. Build Verification
```powershell
cmake --build build/Debug
# Output: [100%] Built target Dev_embedded_architecture
```

### 2. Static Analysis Proof
```powershell
cppcheck --enable=warning,style,performance,portability --inline-suppr --error-exitcode=1 Core/User/
```

### 3. Hardware Flashing Proof
```powershell
STM32_Programmer_CLI --connect port=swd --download build/Debug/Dev_embedded_architecture.elf -hardRst -rst --start
```
```
