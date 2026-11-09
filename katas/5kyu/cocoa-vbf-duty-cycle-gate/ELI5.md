# ELI5 · CoCoA Variable Backoff Factor (`VBF`) & EU868 1% Duty-Cycle Gate-Before-Mutate (`5 kyu`)

## 1. The Kid-Friendly Story
In Europe (`EU868`), a LoRa radio is only allowed to transmit **1% of the time** (36 seconds per hour).
- If you send a `500 ms` packet, your radio must wait **`49,500 ms`** before sending again.
- Meanwhile, CoCoA (CoAP Congestion Control) increases its retry timer (`RTO`) every time an acknowledgment doesn't arrive in time.
- **The Trap**: What if your `1,200 ms` retry timer goes off while the radio is still locked out for `48,300 ms`?
  - If you increment your retry counter (`tx_count`) and multiply your retry timer (`rto_current_ms`) **before** checking if the radio is allowed to transmit, you burn through all your retries during the quiet period without sending a single packet!

## 2. Step-by-Step Breakdown
1. **Prescaled 100× Bucket (`3,600,000` Capacity, `0` Floats)**:
   - The bucket holds `3,600,000` units and refills at `+1 unit/ms`.
   - A `1%` (`1/100`) duty cycle means every `1 ms` of TX airtime costs `100 units` (`airtime_ms * 100`).
2. **Shift-Add CoCoA VBF (`3x`, `2x`, `1.3x`)**:
   - `< 1,000 ms` (`3x`): `rto + (rto << 1)`
   - `1,000..=3,000 ms` (`2x`): `rto << 1`
   - `> 3,000 ms` (`1.3x`): `(rto * 333) >> 8` (`(rto << 8) + (rto << 6) + (rto << 3) + (rto << 2) + rto`) or 3-tap `rto + (rto >> 2) + (rto >> 5)`.
3. **Gate-Before-Mutate (`P3` Ordering Invariant)**:
   - Always call `consume_airtime(now_ms, tx_airtime_ms)` **before** mutating `tx_count`, `rto_current_ms`, or `rto_deadline_ms`.
   - If the bucket doesn't have enough tokens, return `Deferred { wait_ms }` with the exact millisecond deficit and leave the retry state untouched!
