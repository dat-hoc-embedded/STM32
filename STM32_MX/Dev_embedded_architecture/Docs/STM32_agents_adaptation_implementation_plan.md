# Implementation Plan: Adapt `.agents` Framework for STM32 Microcontrollers

Transform the existing Silicon Labs (EFR32 / Simplicity SDK) `.agents` environment into an **STM32-native AI development framework** tailored for STM32CubeMX, ARM GCC, CMake/Ninja, STM32 HAL/LL, and STM32CubeProgrammer CLI.

---

## User Review Required

> [!IMPORTANT]
> **Scope of Target Hardware & Tooling:**
>
> - **Target Family:** STM32 Series (defaulted to STM32F411 / Cortex-M4 with FPU based on current repository configuration).
> - **Driver Level:** STM32Cube HAL & LL Drivers + CMSIS.
> - **Module Directory:** Custom user features live in `Core/User/<module>/` (e.g. `Core/User/ring_buffer/`).
> - **Flashing / Debugging CLI:** `STM32_Programmer_CLI` (via ST-Link / SWD) as configured in `.vscode/tasks.json`.
> - **Build System:** CMake (Presets `Debug`, `Release`, etc.) + Ninja + ARM GNU Toolchain (`arm-none-eabi-gcc`).

---

## Proposed Changes

### Core Rules & Entry Points

#### [MODIFY] [.agents/AGENTS.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/AGENTS.md)

- Replace all EFR32 / Simplicity SDK references with STM32 (STM32F4 / Cortex-M4, STM32CubeMX, HAL/LL).
- Update repository structure mapping (`Core/`, `Core/User/`, `Drivers/`, `cmake/stm32cubemx/`).
- Update Embedded C coding standards:
  - Return types: `HAL_StatusTypeDef` / boolean / module-specific status enums.
  - Safe CubeMX regeneration: User code must remain in `Core/User/` or between `/* USER CODE BEGIN */` / `/* USER CODE END */`.
  - Interrupt safety: CMSIS `__disable_irq()` / `__enable_irq()` or `__set_PRIMASK()`.
  - Flashing: `STM32_Programmer_CLI`.

#### [MODIFY] [.agents/GEMINI.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/GEMINI.md)

- Fix legacy hardcoded path links (`e:/CODE/Silicon_Labs/Simplicity6/empty/`) to point to current workspace forward-slash links.
- Update rule file references.

#### [MODIFY] [.agents/rules/01-workflow-guardrails.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/rules/01-workflow-guardrails.md)

- Update forbidden boundaries:
  - **NEVER** edit `cmake/stm32cubemx/` or `.mxproject`.
  - In `Core/Src/` and `Core/Inc/`, only write code inside `USER CODE BEGIN` / `USER CODE END` blocks.
  - Keep custom features isolated in `Core/User/`.

#### [RENAME & MODIFY] [.agents/rules/02-silabs-embedded-standards.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/rules/02-silabs-embedded-standards.md) -> `02-stm32-embedded-standards.md`

- STM32Cube HAL/LL lifecycle, clock configuration, and non-blocking state machine practices.
- STM32 Interrupt Handling & DMA callbacks (`HAL_UART_RxCpltCallback`, `HAL_GPIO_EXTI_Callback`).
- Power Modes: Run, Sleep, Stop, Standby.
- Zero dynamic memory allocation (`malloc`/`free`), compile-time static buffers.

#### [MODIFY] [.agents/rules/03-deep-module-architecture.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/rules/03-deep-module-architecture.md)

- Update embedded C layout to `Core/User/<module_name>/`.
- Define clean public headers (minimal API, max 3-7 functions) and static internal implementations.

#### [MODIFY] [.agents/rules/04-testing-quality-gates.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/rules/04-testing-quality-gates.md)

- Update verification commands: `cmake --preset Debug`, `cmake --build build/Debug`, `cppcheck Core/User/`, and `STM32_Programmer_CLI`.

---

### Scripts & PreToolUse Protection Hooks

#### [MODIFY] [.agents/scripts/guard_autogen.ps1](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/scripts/guard_autogen.ps1) and [guard_autogen.py](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/scripts/guard_autogen.py)

- Protect `cmake/stm32cubemx/`, `.mxproject`, `Drivers/STM32F4xx_HAL_Driver/`, and `Drivers/CMSIS/` from accidental AI modification.

#### [MODIFY] [.agents/scripts/build_check.ps1](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/scripts/build_check.ps1)

- Adapt build script to run `cmake --preset Debug` and `cmake --build build/Debug`.

---

### Specialized Skills (`.agents/skills/`)

#### [RENAME & MODIFY] `silabs-build-verify` -> `stm32-build-verify`

- Build firmware via `cmake --preset Debug` and `cmake --build build/Debug`.
- Flash via `STM32_Programmer_CLI --connect port=SWD --download build/Debug/Dev_embedded_architecture.elf -hardRst -rst --start`.
- Run static analysis via `cppcheck` on `Core/User/`.

#### [MODIFY] [.agents/skills/grill-me/SKILL.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/skills/grill-me/SKILL.md)

- Adapt 5-stage interview to STM32 peripherals (TIM, USART, SPI, I2C, DMA, ADC, USB), clock tree, HAL vs LL drivers, and CubeMX pin mapping.

#### [MODIFY] [.agents/skills/write-a-prd/SKILL.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/skills/write-a-prd/SKILL.md)

- Adapt PRD template for STM32 hardware resources, pinouts, DMA streams, and `Core/User` module architecture.

#### [MODIFY] [.agents/skills/prd-to-issues/SKILL.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/skills/prd-to-issues/SKILL.md)

- Align DAG decomposition with STM32 architecture (CubeMX setup -> User Module TDD -> Integration in `main.c` / FreeRTOS).

#### [MODIFY] [.agents/skills/embedded-tdd/SKILL.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/skills/embedded-tdd/SKILL.md)

- Align TDD cycle with `Core/User/` module testing and CMake builds.

#### [MODIFY] [.agents/skills/improve-codebase-architecture/SKILL.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/skills/improve-codebase-architecture/SKILL.md)

- Direct refactoring towards `Core/User/` and decoupling user code from hardware HAL calls.

#### [MODIFY] [.agents/skills/audit-reviewer/SKILL.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/skills/audit-reviewer/SKILL.md)

- Verify CubeMX user code block preservation, STM32 HAL return codes, memory safety, and `STM32_Programmer_CLI` flashing.

---

### Documentation & Guides

#### [RENAME & MODIFY] `SILABS_ANTIGRAVITY_GUIDE.md` -> `STM32_ANTIGRAVITY_GUIDE.md`

- Comprehensive developer manual for STM32 embedded software on Antigravity 2.0.

#### [MODIFY] [.agents/Describe_agents.md](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/Describe_agents.md)

- Update system architecture summary to STM32.

---

## Verification Plan

### Automated Verification

1. **Validation of Build Check Script:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .agents/scripts/build_check.ps1
   ```
2. **Validation of Autogen Guard Script:**
   Test `guard_autogen.ps1` with simulated tool input attempting to modify `cmake/stm32cubemx/CMakeLists.txt` (must return `"decision": "deny"`).
3. **Link and Syntax Audit:**
   Verify all Markdown files have valid syntax and forward-slash clickable file links.
