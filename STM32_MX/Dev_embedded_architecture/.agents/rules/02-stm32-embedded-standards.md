# STM32 Embedded C & Architecture Standards

> **Target MCU:** STM32 Series (STM32F411xE / ARM Cortex-M4 with FPU)  
> **Framework:** STM32Cube HAL, LL Drivers & CMSIS  
> **Toolchain:** ARM GCC (`arm-none-eabi-gcc`) + CMake / Ninja  

---

## 1. Application Lifecycle & Architecture

### A. Bare-Metal Super-Loop & State Machines
- **CubeMX Entry Point:** Respect the initialization flow in `Core/Src/main.c`:
  - `HAL_Init()`: Resets all peripherals, initializes Flash interface and Systick.
  - `SystemClock_Config()`: Configures PLL, AHB/APB prescalers, and core system clock.
  - `MX_GPIO_Init()`, `MX_USART2_UART_Init()`, etc.: Peripheral initialization.
  - `while (1)`: Main application loop.
- **Rule:** Never insert long blocking delays (`HAL_Delay()`) inside the main loop. Implement non-blocking state machines using `HAL_GetTick()` or hardware timer interrupts (`TIMx`).
- **User Code Isolation:** Implement application logic inside modular directories under `Core/User/<module>/` (e.g. `Core/User/ring_buffer/`). Only call module `init()` and `process()` functions from `main.c`.

### B. RTOS Multi-Tasking Architecture (CMSIS-RTOS v2 / FreeRTOS)
- **Task Isolation:** When an RTOS is enabled, assign each independent peripheral manager or service to its own task with a dedicated static stack.
- **Inter-Task Communication:** Use Queues (`osMessageQueueId_t`), Event Flags (`osEventFlagsId_t`), or Direct-to-Task Notifications.
- **Synchronization:** Protect shared peripherals and data structures with Mutexes (`osMutexId_t`) or Semaphores.
- **ISR to Task:** Never invoke blocking RTOS APIs inside ISRs. Use `FromISR` variants or release semaphores/flags.

---

## 2. STM32 Peripheral & Driver Conventions

### A. HAL vs LL Driver Usage
- **HAL (Hardware Abstraction Layer):** Preferred for standard peripheral operations, complex state management, and portable driver logic.
- **LL (Low-Layer Drivers):** Preferred for time-critical, low-latency, and high-frequency paths (e.g. high-speed SPI, fast GPIO bit-banging, direct register reads).
- **Callback Pattern:** Override weak HAL callbacks in user modules, e.g.:
  - `HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)`
  - `HAL_UART_TxCpltCallback(UART_HandleTypeDef *huart)`
  - `HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)`
  - `HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)`

### B. DMA & Buffer Management
- Always use circular DMA (`DMA_CIRCULAR`) or double-buffering with half-transfer / transfer-complete interrupts for continuous streams (e.g. UART RX, ADC).
- Keep DMA buffers word-aligned and sized to powers of two.

---

## 3. Power Management & Low Power Modes

- Support standard STM32 low-power modes:
  - **Sleep Mode:** Core stopped, peripherals keep running; wake up by any interrupt or event.
  - **Stop Mode:** All high-speed clocks stopped, 1.2V domain powered, SRAM and registers retained; wake up by EXTI, RTC, or low-power timer.
  - **Standby Mode:** Entire 1.2V domain powered off, lowest power consumption; wake up via WKUP pin, NRST, or RTC alarm.
- Disable unused peripheral clocks via `__HAL_RCC_<PERIPH>_CLK_DISABLE()` when peripherals are inactive.

---

## 4. Interrupt Safety & Memory Standards

- **Interrupt Disabling:** Protect critical sections accessed by both ISR and background code using CMSIS primitives:
  ```c
  uint32_t primask = __get_PRIMASK();
  __disable_irq();
  // Critical section code
  __set_PRIMASK(primask);
  ```
- **Volatile Qualifiers:** Any variable modified inside an ISR and read outside must be marked `volatile`.
- **Minimal ISR Duration:** Keep interrupt service routines minimal. Transfer data into static ring buffers, clear interrupt flags, and notify main loop/task.
- **Zero Dynamic Allocation:** `malloc()`, `calloc()`, and `free()` are strictly forbidden. Use statically allocated structures and arrays with compile-time bounds.
- **Error Propagation:** Return and check `HAL_StatusTypeDef` (`HAL_OK`, `HAL_ERROR`, `HAL_BUSY`, `HAL_TIMEOUT`) or module-specific status enums.
