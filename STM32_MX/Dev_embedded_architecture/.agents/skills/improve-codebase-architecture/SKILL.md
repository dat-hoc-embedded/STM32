---
name: improve-codebase-architecture
description: >-
  Audits codebase for shallow modules, leaky abstractions, and oversized interfaces,
  refactoring them into robust Deep Modules.
---

# Codebase Architecture Refactoring (`/improve-codebase-architecture`)

Use this skill during Phase 5 (Architecture Refactoring) to eliminate technical debt, minimize public header interfaces, and lower AI context consumption.

---

## 1. Deep Module Audit Checklist

Audit every module in `Core/User/` against these criteria:

| Check | Target Standard | Violation Trigger |
| :--- | :--- | :--- |
| **Public API Surface** | 3-7 functions max per `.h` file | > 10 function declarations |
| **Encapsulation** | All internal helpers declared `static` in `.c` | Helper functions exposed in public header |
| **State Storage** | File-scoped static struct in `.c` | Global non-static variables / arrays |
| **Context Cost** | Agent understands interface reading <= 2 files | Agent must read 3+ headers to call module |
| **Hardware Leaks** | Clean function arguments / buffers | Raw peripheral register addresses (`USART2->DR`) in public `.h` |

---

## 2. Refactoring Procedure

### Step 1: Interface Thinning
1. Review `Core/User/<module>/<module>.h`.
2. Move any function prototype not meant to be called by external modules (e.g. `main.c`) into `Core/User/<module>/<module>.c` and mark it `static`.
3. Move internal typedefs, macros, and internal buffer sizes into `<module>.c`.

### Step 2: State Consolidation
1. Group scattered variables into a single static context structure:
   ```c
   // Inside Core/User/<module>/<module>.c
   typedef struct {
     bool initialized;
     uint8_t buffer[BUFFER_LEN];
     uint16_t sequence_num;
   } module_context_t;

   static module_context_t s_ctx = {0};
   ```

### Step 3: Verification
1. Recompile with CMake: `cmake --build build/Debug`
2. Run `cppcheck Core/User/` to ensure no unused static functions or scope leaks exist.
