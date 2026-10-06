# STM32 Embedded Development Guide for Google Antigravity 2.0

Comprehensive manual for **Embedded Software Engineers** using the **Antigravity 2.0** AI pair programming platform for STM32 microcontrollers (STM32F4 / Cortex-M4, STM32CubeMX, HAL/LL, CMake/Ninja, and STM32CubeProgrammer CLI).

---

## 1. System Overview & 6-Phase Architecture

The AI pair programming workflow follows the 6-phase engineering lifecycle defined in [AI_Coding.mmd](file:///e:/CODE/STM32_IDE/STM32_MX/Dev_embedded_architecture/.agents/AI_Coding.mmd):

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. INITIALIZATION & GUARDRAILS                                              │
│    - .agents/rules/ (STM32 standards, CubeMX protection, Deep Modules)      │
│    - .agents/hooks.json & guard_autogen (Block modifications to autogen)     │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. REQUIREMENT ALIGNMENT                                                    │
│    - /grill-me (5-stage recursive interview: Pinout, Clocks, Peripherals)   │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. DECOMPOSITION                                                            │
│    - /write-a-prd (Generate PRD-<feature>.md tailored for STM32)            │
│    - /prd-to-issues (Vertical Tracer Bullets & DAG Task Breakdown)          │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 4. ISOLATED EXECUTION & TDD                                                 │
│    - /embedded-tdd (Red-Green-Refactor loop in Core/User/)                  │
│    - /stm32-build-verify (CMake Presets + ARM GCC + Cppcheck)               │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 5. ARCHITECTURE REFACTORING                                                 │
│    - /improve-codebase-architecture (Interface thinning, static hiding)     │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 6. VERIFICATION & DELIVERY                                                  │
│    - /audit-reviewer (Clean-Context Reviewer, STM32_Programmer_CLI flash)   │
│    - walkthrough.md (Final verification report with logs)                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Directory Layout of `.agents/`

```text
.agents/
├── rules/                                   # Rules automatically loaded into context
│   ├── 01-workflow-guardrails.md            # 6-phase pipeline & hard boundaries
│   ├── 02-stm32-embedded-standards.md       # STM32 HAL/LL, interrupts, DMA, power
│   ├── 03-deep-module-architecture.md       # Core/User layout, static encapsulation
│   └── 04-testing-quality-gates.md          # Acceptance checklist & CLI commands
├── skills/                                  # On-demand specialized skills
│   ├── grill-me/SKILL.md                    # Requirements alignment interview
│   ├── write-a-prd/SKILL.md                 # Firmware PRD generator
│   ├── prd-to-issues/SKILL.md               # DAG task breakdown
│   ├── embedded-tdd/SKILL.md                # Embedded TDD cycle
│   ├── stm32-build-verify/SKILL.md          # CMake compile & STM32_Programmer_CLI
│   ├── improve-codebase-architecture/SKILL.md # Deep module interface refactoring
│   └── audit-reviewer/SKILL.md              # Independent clean-context reviewer
├── scripts/                                 # Helper scripts and safety hooks
│   ├── guard_autogen.ps1                    # PowerShell hook guarding autogen files
│   ├── guard_autogen.py                     # Python cross-platform guard hook
│   └── build_check.ps1                      # Fast CMake build check script
├── hooks.json                               # PreToolUse hooks configuration
├── AGENTS.md                                # Workspace system rules & STM32 standards
├── GEMINI.md                                # Antigravity rules entry point
└── AI_Coding.mmd                            # Mermaid diagram of the 6-phase pipeline
```

---

## 3. How to Use Slash Commands

| Command | Phase | Purpose | Example Use Case |
| :--- | :--- | :--- | :--- |
| `/grill-me` | Phase 2 | Run a multi-stage technical interview to clarify ambiguous requirements. | "I want to add a circular UART ring buffer for CLI commands." |
| `/write-a-prd` | Phase 3 | Formulate a complete Product Requirements Document (`PRD-<feature>.md`). | "Generate the PRD for the ring buffer module." |
| `/prd-to-issues`| Phase 3 | Decompose PRD into a DAG of vertical tracer bullets. | "Break down PRD-ring-buffer into implementation tasks." |
| `/embedded-tdd`| Phase 4 | Implement logic using Red-Green-Refactor with immediate compile checks. | "Implement ring buffer push/pop with boundary tests." |
| `/stm32-build-verify` | Phase 4 | Compile with CMake presets, run Cppcheck, and flash target with ST-Link. | "Verify build and flash to connected STM32 board." |
| `/improve-codebase-architecture` | Phase 5 | Audit public headers in `Core/User/` to hide private helpers with `static`. | "Refactor ring_buffer module into a Deep Module." |
| `/audit-reviewer` | Phase 6 | Run an independent audit of memory safety, CubeMX integrity, and output `walkthrough.md`. | "Audit the completed UART driver before finalizing." |

---

## 4. Key Engineering Boundaries for STM32

1. **Keep Custom Code in `Core/User/`**: Never place custom business logic directly inside `Core/Src/` unless wiring peripheral calls in `main.c`.
2. **Respect `/* USER CODE */` Comments**: When editing `Core/Src/main.c` or `Core/Src/stm32f4xx_it.c`, always stay inside the marked sections so STM32CubeMX does not erase your code.
3. **Never Edit `cmake/stm32cubemx/`**: Register user sources and include paths in the root `CMakeLists.txt`.
4. **No Dynamic Memory Allocation**: Always allocate static buffers with compile-time `#define` sizes.
