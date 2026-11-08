% PLUnit verification suite for CoCoA VBF & EU868 Duty-Cycle Gate (P1..P6)
:- use_module(library(plunit)).

:- begin_tests(cocoa_vbf_duty_cycle_gate).
:- include(solution).

test(vbf_three_regimes_shift_add_and_q8) :-
    VbfFast0 = vbf(400, 400, 200, 60000, 0),
    step_vbf_on_timeout(VbfFast0, false, VbfFast1),
    step_vbf_on_timeout(VbfFast1, false, VbfFast2),
    assertion(VbfFast1 == vbf(400, 1200, 200, 60000, 1)),
    assertion(VbfFast2 == vbf(400, 3600, 200, 60000, 2)),

    VbfMed0 = vbf(1500, 1500, 200, 60000, 0),
    step_vbf_on_timeout(VbfMed0, false, VbfMed1),
    step_vbf_on_timeout(VbfMed1, false, VbfMed2),
    assertion(VbfMed1 == vbf(1500, 3000, 200, 60000, 1)),
    assertion(VbfMed2 == vbf(1500, 6000, 200, 60000, 2)),

    VbfSlow0 = vbf(4000, 4000, 200, 60000, 0),
    step_vbf_on_timeout(VbfSlow0, false, VbfSlowQ8),
    step_vbf_on_timeout(VbfSlow0, true, VbfSlowShift),
    assertion(VbfSlowQ8 == vbf(4000, 5203, 200, 60000, 1)),
    assertion(VbfSlowShift == vbf(4000, 5187, 200, 60000, 1)).

test(p2_shift_add_exact_algebraic_identities) :-
    forall(
        between(1, 1000, Toa),
        (
            quiet_time_ms(band_10pct, Toa, Q10),
            Credit10Expected is 10 * Toa,
            Q10Expected is 9 * Toa,
            credit_cost(band_10pct, Toa, C10),
            assertion(Q10 == Q10Expected),
            assertion(C10 == Credit10Expected),

            quiet_time_ms(band_1pct, Toa, Q1),
            Credit1Expected is 100 * Toa,
            Q1Expected is 99 * Toa,
            credit_cost(band_1pct, Toa, C1),
            assertion(Q1 == Q1Expected),
            assertion(C1 == Credit1Expected),

            quiet_time_ms(band_0_1pct, Toa, Q01),
            Credit01Expected is 1000 * Toa,
            Q01Expected is 999 * Toa,
            credit_cost(band_0_1pct, Toa, C01),
            assertion(Q01 == Q01Expected),
            assertion(C01 == Credit01Expected)
        )
    ).

test(p1_p6_duty_cycle_1pct_10pct_boundaries_and_window_refill) :-
    Gate0 = gate(band_1pct, 3600000, 0, 0),
    consume_airtime(Gate0, 0, 500, Gate1, Res0),
    assertion(Res0 == ok),
    assertion(Gate1 == gate(band_1pct, 3550000, 0, 50000)),

    % P6 read-only check at t = 49,999 ms vs 50,000 ms
    check_ready(Gate1, 49999, 500, R49999),
    assertion(R49999 == err(1)),
    check_ready(Gate1, 50000, 500, R50000),
    assertion(R50000 == ok),

    % Refill back to 3_600_000 after 1 hour
    projected_credits(Gate1, 3600000, FullCredits),
    assertion(FullCredits == 3600000),

    % 10% sub-band boundary check at t = 4,999 ms vs 5,000 ms
    Gate10_0 = gate(band_10pct, 3600000, 0, 0),
    consume_airtime(Gate10_0, 0, 500, Gate10_1, Res10),
    assertion(Res10 == ok),
    check_ready(Gate10_1, 4999, 500, R4999),
    assertion(R4999 == err(1)),
    check_ready(Gate10_1, 5000, 500, R5000),
    assertion(R5000 == ok).

test(p3_p4_gate_before_mutate_preserves_vbf_and_retries_during_lockout) :-
    Slot0 = slot(0, 0, 0, 1200, 0),
    Vbf0  = vbf(1200, 1200, 300, 60000, 0),
    Gate0 = gate(band_1pct, 3600000, 0, 0),
    consume_airtime(Gate0, 0, 500, GateLocked, ok),

    % Poll at t = 1200 ms during 49,500 ms quiet lockout -> deferred by 48,800 ms, retries=0, backoff_count=0!
    poll_expired_hole_gated(Slot0, Vbf0, GateLocked, 500, 1200, SlotDef, VbfDef, GateDef, OutDef),
    assertion(OutDef == deferred_by_duty_cycle(0, 48800)),
    assertion(SlotDef == slot(0, 0, 0, 50000, 0)),
    assertion(VbfDef == vbf(1200, 1200, 300, 60000, 0)),

    % Poll at t = 50,000 ms once lockout clears -> transmit_ready(0, 2400), retries=1, backoff_count=1!
    poll_expired_hole_gated(SlotDef, VbfDef, GateDef, 500, 50000, SlotReady, VbfReady, _GateFinal, OutReady),
    assertion(OutReady == transmit_ready(0, 2400)),
    assertion(SlotReady == slot(0, 0, 50000, 52400, 1)),
    assertion(VbfReady == vbf(1200, 2400, 300, 60000, 1)).

:- end_tests(cocoa_vbf_duty_cycle_gate).
