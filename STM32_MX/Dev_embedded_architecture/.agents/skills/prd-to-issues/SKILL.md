---
name: prd-to-issues
description: >-
  Decomposes an approved STM32 PRD into Vertical Tracer Bullet tasks and builds a
  Directed Acyclic Graph (DAG) task plan.
---

# PRD Decomposition & DAG Builder (`/prd-to-issues`)

Use this skill after a PRD is approved to break down implementation into small, testable, vertical tracer bullets.

---

## 1. Vertical Tracer Bullet Philosophy

Avoid horizontal layering where you configure all hardware peripherals first without testing logic end-to-end.
Instead, build **thin vertical slices**:

```text
Tracer Bullet 1: Pure Logic / Data Structure
[Header Definition] ──> [Static Buffer / Algorithm] ──> [Build & Unit Check]

Tracer Bullet 2: CMake & Driver Wiring
[Register in CMakeLists.txt] ──> [HAL Peripheral Callback Hook] ──> [Integration in main.c]

Tracer Bullet 3: Hardware Verification & Diagnostics
[Flash Target via SWD] ──> [Verify Output / Logging] ──> [Handle Edge Cases (Overrun/Timeout)]
```

---

## 2. DAG Task Graph Template

Output the task breakdown with explicit dependencies in your task plan:

```mermaid
flowchart TD
    T1["Task 1: Define Public Header Interface (Core/User/module/module.h)"] --> T2["Task 2: Implement Static Logic & Buffer (Core/User/module/module.c)"]
    T2 --> T3["Task 3: Register in CMakeLists.txt & Build Check (build/Debug)"]
    T3 --> T4["Task 4: Wire Peripheral & HAL Callbacks in main.c / stm32f4xx_it.c"]
    T4 --> T5["Task 5: Flash Hardware & Verify (STM32_Programmer_CLI)"]
    T5 --> T6["Task 6: Static Analysis Audit (cppcheck Core/User/) & walkthrough.md"]
```

---

## 3. Issue Specification Format

For each task in the plan:
1. **Task ID & Name**: e.g., `Task 1: Define ring_buffer.h public interface`
2. **Inputs / Dependencies**: Which previous tasks must be complete.
3. **Files to touch**: Exact list of files (`Core/User/<module>/`, `CMakeLists.txt`, `Core/Src/main.c`).
4. **Verification Step**: Immediate automated command to verify completion (`cmake --build build/Debug`, etc.).
