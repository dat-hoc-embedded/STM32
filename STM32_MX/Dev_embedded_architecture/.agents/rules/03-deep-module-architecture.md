# Deep Module Architecture & Context Cost Optimization

> **Core Principle:** Maximize internal module depth; minimize public interface surface.  
> An AI agent or human developer should only need to read **at most 2 files** to fully understand how to interact with any module.

---

## 1. Embedded C Deep Modules (`Core/User/<module_name>/`)

### Directory Layout
```text
Core/User/<module_name>/
├── <module_name>.h   # PUBLIC: Minimal API interface (Max 3-7 functions)
└── <module_name>.c   # PRIVATE: Full implementation, static functions, static state
```

### Public Header (`<module_name>.h`) Rules
- **Include Guard:** Standard `#ifndef <MODULE_NAME>_H` / `#define <MODULE_NAME>_H`.
- **Public Functions:** Only expose lifecycle and essential operations:
  - `HAL_StatusTypeDef <module_name>_init(const <ModuleConfig>_t *config);`
  - `void <module_name>_process(void);`
  - `HAL_StatusTypeDef <module_name>_deinit(void);`
  - Minimal getters/setters or event push/pop operations.
- **Opaque Types / Minimal Structs:** Do not expose internal buffers, hardware register pointers, or private state in public headers.
- **Doxygen Documentation:** Every public function must document parameters, return status codes (`HAL_StatusTypeDef` or `bool`), and reentrancy/ISR safety.

### Private Source (`<module_name>.c`) Rules
- **Static Encapsulation:** Every internal function **MUST** be declared `static`.
- **Static Module State:** Module state is kept in a single file-scoped static struct:
  ```c
  static struct {
    bool is_initialized;
    uint32_t state_flags;
    uint8_t buffer[MODULE_BUFFER_SIZE];
  } s_module_ctx = {0};
  ```
- **No Global Variables:** Never expose non-static global variables.

---

## 2. Anti-Patterns (Shallow Modules) to Refactor
- ❌ Modules with 20+ public function prototypes in `.h` where 15 are internal helpers.
- ❌ Direct access to global arrays or peripheral registers from outside the owning module.
- ❌ Leaking hardware-specific register masks or raw register pointers into high-level business logic.
- ❌ Splitting simple logic across 5+ tiny files requiring jumping through deep call graphs.
