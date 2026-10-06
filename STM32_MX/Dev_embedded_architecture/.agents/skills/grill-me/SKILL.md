---
name: grill-me
description: >-
  Runs a structured recursive interview to resolve ambiguities and lock requirements
  for STM32 embedded firmware features before writing any code.
---

# STM32 Requirements Alignment Interview (`/grill-me`)

Use this skill when receiving a new feature request, architecture change, or peripheral driver definition.
You must conduct a multi-stage interview using the `ask_question` tool, walking down each branch of the design tree one question at a time.

---

## 5-Stage Embedded STM32 Interview Tree

### Stage 1: Hardware & Peripherals Context
- **Target Chip & Board:** STM32 family (e.g. STM32F411xE, BlackPill, or custom board pinout).
- **Peripherals Involved:** GPIO, USART/UART, SPI, I2C, ADC, DAC, Timers (`TIMx`), DMA streams.
- **Clock & Timing Requirements:** Core frequency, AHB/APB prescalers, sampling rates, baud rates.
- **Memory Budget:** Target flash and RAM limits for the new module.

### Stage 2: Driver Level & Data Processing
- **Driver Layer:** STM32Cube HAL (high portability) vs STM32 LL (low latency / direct register access) vs CMSIS.
- **DMA Strategy:** Polling vs Interrupt-driven vs Circular DMA (`DMA_CIRCULAR`) with Half-Transfer / Transfer-Complete.
- **Buffer & Data Formats:** Ring buffer capacity, byte order (Little-Endian), packet frames, framing bytes.

### Stage 3: Concurrency & Lifecycle Architecture
- **Execution Model:** Bare-metal non-blocking superloop (`main.c` + state machine) vs FreeRTOS (CMSIS-RTOS v2 tasks/queues).
- **Interrupts & Callbacks:** Required HAL callbacks (e.g. `HAL_UART_RxCpltCallback`, `HAL_GPIO_EXTI_Callback`).
- **Critical Sections:** Protection via CMSIS interrupt masking (`__disable_irq()` / `__set_PRIMASK()`) or RTOS mutexes.

### Stage 4: Public Interface & Module Encapsulation
- **Directory Location:** `Core/User/<module_name>/`.
- **Public API Surface:** Target maximum of 3–7 public functions in `<module_name>.h`.
- **Return Codes:** Standard `HAL_StatusTypeDef` (`HAL_OK`, `HAL_ERROR`, `HAL_BUSY`, `HAL_TIMEOUT`) or module `bool`.

### Stage 5: Verification & Failure Modes
- **Edge Cases:** Buffer overflow, overrun errors (`ORE`), frame errors (`FE`), timeout handling.
- **Verification Strategy:** CMake build check (`cmake --build build/Debug`), Cppcheck static analysis, hardware flashing via `STM32_Programmer_CLI`.

---

## Interview Rules

1. **Ask One Question at a Time:** Use `ask_question` with structured multiple-choice options and clear recommendations.
2. **Explore Codebase First:** Check `Dev_embedded_architecture.ioc`, `Core/Inc/main.h`, and `CMakeLists.txt` before asking questions that the code already answers.
3. **Transition to PRD:** Once all ambiguities are resolved, summarize the locked requirements and transition to `/write-a-prd`.
