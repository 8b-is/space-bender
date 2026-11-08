# CoCoA VBF & EU868 Duty-Cycle Gate (`P1..P6` — SWI-Prolog 8.0+)

- **SPDX-License-Identifier**: `BSD-3-Clause` (`Terence Parr / antlr/stringtemplate4` & `8b-is / ADA-Lang StringTemplate5 p/q`)
- **Language**: SWI-Prolog (`solution.pl`, `test.pl`)

## Overview

Relational Horn-clause encoding of **CoCoA's Variable Backoff Factor (`VBF`)** (`3.0x` `< 1000 ms`, `2.0x` `1000..=3000 ms`, `1.3x` `> 3000 ms` via Q8 `(Rto * 333) >> 8` and 3-tap shift `Rto + (Rto >> 2) + (Rto >> 5) + (Rto >> 6)`) paired with the **OMNI One-Shot Architectural Pattern (`P1..P6`)** for division-free ETSI EN 300 220 EU868 duty-cycle gating (`10%`, `1%`, `0.1%`).
