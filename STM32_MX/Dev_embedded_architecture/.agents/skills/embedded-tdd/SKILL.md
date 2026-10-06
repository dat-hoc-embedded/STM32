---
name: embedded-tdd
description: >-
  Executes the Test-Driven Development (TDD) Red-Green-Refactor loop for STM32
  embedded C modules and peripheral drivers.
---

# STM32 Embedded TDD Workflow (`/embedded-tdd`)

Use this skill during Phase 4 (Isolated Execution) to implement STM32 features with high reliability and zero regressions.

---

## 1. The Red-Green-Refactor Cycle for STM32 Embedded Systems

```text
┌────────────────────────────────────────────────────────┐
│ 1. RED: Define minimal interface & failing assertion   │
│    - Define function prototypes in Core/User/module.h  │
│    - Add boundary test or state assertion in test/harness│
└─────────────────────────┬──────────────────────────────┘
                          ▼
┌────────────────────────────────────────────────────────┐
│ 2. GREEN: Implement minimal working code               │
│    - Implement functions in Core/User/module.c         │
│    - Compile with CMake / Ninja loop (build/Debug)     │
└─────────────────────────┬──────────────────────────────┘
                          ▼
┌────────────────────────────────────────────────────────┐
│ 3. REFACTOR: Harden architecture & optimize            │
│    - Encapsulate private functions with static         │
│    - Check buffer boundaries & zero dynamic allocation │
│    - Run static analysis (cppcheck Core/User/)         │
└────────────────────────────────────────────────────────┘
```

---

## 2. STM32 Testing & Decoupling Strategy

### Decouple Logic from Raw HAL Hardware Registers
- To make code easily testable and clean, separate pure algorithmic logic (e.g. ring buffers, protocol parsers, command decoders) from raw hardware register calls (`HAL_UART_Transmit`, `USART2->DR`).
- Keep pure logic in `Core/User/<module>/` with clean functions taking byte arrays or pointers.
- Feed hardware events into the module via standard callbacks.

---

## 3. Fast Local Feedback Loop Commands

1. **Trigger Quick Build Check:**
   ```powershell
   cmake --build build/Debug
   ```

2. **Run Cppcheck Static Analysis:**
   ```powershell
   cppcheck --enable=warning,style,performance,portability --inline-suppr --error-exitcode=1 Core/User/
   ```

3. **Verify Target Memory Consumption:**
   ```powershell
   arm-none-eabi-size build/Debug/Dev_embedded_architecture.elf
   ```
