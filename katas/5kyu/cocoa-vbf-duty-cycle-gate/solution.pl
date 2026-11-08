% CoCoA Variable Backoff Factor (VBF) & EU868 Duty-Cycle Gate (P1..P6) — SWI-Prolog 8.0+
% SPDX-License-Identifier: BSD-3-Clause
% Copyright (c) 2012 Terence Parr (antlr/stringtemplate4)
% Copyright (c) 2026 8b-is / ADA-Lang (StringTemplate5 p/q + OMNI P1..P6)
%
% Implements:
%   1. CoCoA VBF Regimes (fast_3x < 1000ms, medium_2x 1000..3000ms, slow_1_3x > 3000ms)
%      using pure dyadic shift-add arithmetic:
%        - fast_3x        : Rto + (Rto << 1)
%        - medium_2x      : Rto << 1
%        - slow_1_3x (Q8) : (Rto * 333) >> 8
%        - slow_1_3x (3t) : Rto + (Rto >> 2) + (Rto >> 5) + (Rto >> 6)
%   2. OMNI P1..P6 EU868 Duty-Cycle Arithmetic (Band 10%, 1%, 0.1%):
%        - P1 Prescaled Unit Swap : 3_600_000 credits (1 credit == 1 ms)
%        - P2 Shift-Add T_off     : 9*ToA, 99*ToA, 999*ToA via <= 4 bit-shifts
%        - P2 Shift-Add Cost      : 10*ToA, 100*ToA, 1000*ToA via <= 3 bit-shifts
%        - P3 Gate-Before-Mutate  : consume_airtime BEFORE step_vbf_on_timeout
%        - P4 Deferral Outcome    : deferred(Seq, WaitMs) vs transmit_ready(Seq, NextRtoMs)
%        - P6 Check-Then-Commit   : check_ready/4 is read-only; consume_airtime/5 commits.

hour_credits_max(3600000).

% --- CoCoA VBF Regime Selection & Adaptive Step Cap ---
vbf_regime(RtoBaseMs, fast_3x) :-
    RtoBaseMs < 1000, !.
vbf_regime(RtoBaseMs, medium_2x) :-
    RtoBaseMs =< 3000, !.
vbf_regime(_RtoBaseMs, slow_1_3x).

max_backoffs_for_base(RtoBaseMs, 4) :- RtoBaseMs < 3000, !.
max_backoffs_for_base(RtoBaseMs, 3) :- RtoBaseMs < 6000, !.
max_backoffs_for_base(RtoBaseMs, 2) :- RtoBaseMs =< 12000, !.
max_backoffs_for_base(_RtoBaseMs, 1).

% vbf_scale(+Regime, +UsePureShifts, +Rto, -Scaled)
vbf_scale(fast_3x, _Pure, Rto, Scaled) :- !,
    Scaled is Rto + (Rto << 1).
vbf_scale(medium_2x, _Pure, Rto, Scaled) :- !,
    Scaled is Rto << 1.
vbf_scale(slow_1_3x, true, Rto, Scaled) :- !,
    Scaled is Rto + (Rto >> 2) + (Rto >> 5) + (Rto >> 6).
vbf_scale(slow_1_3x, false, Rto, Scaled) :- !,
    Scaled is (Rto * 333) >> 8.

% step_vbf_on_timeout(+vbf(Base, Cur, Min, Max, Count), +PureShifts, -vbf(Base, NextCur, Min, Max, NextCount))
step_vbf_on_timeout(vbf(Base, Cur, Min, Max, Count), PureShifts, vbf(Base, NextCur, Min, Max, NextCount)) :-
    max_backoffs_for_base(Base, MaxSteps),
    (   Count >= MaxSteps
    ->  NextCur = Cur,
        NextCount = Count
    ;   vbf_regime(Base, Regime),
        vbf_scale(Regime, PureShifts, Cur, Scaled),
        NextCur is max(Min, min(Max, Scaled)),
        NextCount is Count + 1
    ).

% --- P2 Shift-Add Decomposition for EU868 Sub-Bands (10%, 1%, 0.1%) ---
quiet_time_ms(band_10pct, Toa, Toff) :-
    Toff is (Toa << 3) + Toa.
quiet_time_ms(band_1pct, Toa, Toff) :-
    Toff is (Toa << 6) + (Toa << 5) + (Toa << 1) + Toa.
quiet_time_ms(band_0_1pct, Toa, Toff) :-
    Toff is (Toa << 10) - (Toa << 4) - (Toa << 3) - Toa.

credit_cost(band_10pct, Toa, Cost) :-
    Cost is (Toa << 3) + (Toa << 1).
credit_cost(band_1pct, Toa, Cost) :-
    Cost is (Toa << 6) + (Toa << 5) + (Toa << 2).
credit_cost(band_0_1pct, Toa, Cost) :-
    Cost is (Toa << 10) - (Toa << 4) - (Toa << 3).

% --- P1 & P6 Read-Only Projected Credits and Check-Ready ---
projected_credits(gate(_Band, Credits, LastRefillMs, _NextTxMs), NowMs, EffectiveCredits) :-
    hour_credits_max(Cap),
    Elapsed is NowMs - LastRefillMs,
    (   Elapsed > 0
    ->  EffectiveCredits is min(Cap, Credits + Elapsed)
    ;   EffectiveCredits = Credits
    ).

% check_ready(+Gate, +NowMs, +ToaMs, -Result) -> Result is ok or err(WaitMs)
check_ready(Gate, NowMs, ToaMs, Result) :-
    Gate = gate(Band, _Credits, _LastRefillMs, NextTxMs),
    projected_credits(Gate, NowMs, EffectiveCredits),
    WaitQuiet is max(0, NextTxMs - NowMs),
    credit_cost(Band, ToaMs, Cost),
    WaitCredit is max(0, Cost - EffectiveCredits),
    TotalWait is max(WaitQuiet, WaitCredit),
    (   TotalWait =:= 0
    ->  Result = ok
    ;   Result = err(TotalWait)
    ).

% consume_airtime(+GateIn, +NowMs, +ToaMs, -GateOut, -Result)
consume_airtime(GateIn, NowMs, ToaMs, GateOut, Result) :-
    check_ready(GateIn, NowMs, ToaMs, Check),
    (   Check == ok
    ->  GateIn = gate(Band, _Credits, _LastRefill, _NextTx),
        projected_credits(GateIn, NowMs, Refilled),
        credit_cost(Band, ToaMs, Cost),
        quiet_time_ms(Band, ToaMs, Toff),
        NewCredits is max(0, Refilled - Cost),
        NewNextTx is NowMs + ToaMs + Toff,
        GateOut = gate(Band, NewCredits, NowMs, NewNextTx),
        Result = ok
    ;   GateOut = GateIn,
        Result = Check
    ).

% --- P3 Gate-Before-Mutate & P4 Deferral Outcome ---
poll_expired_hole_gated(
    slot(Seq, FirstTx, LastTx, Deadline, Retries),
    VbfIn,
    GateIn,
    ToaMs,
    NowMs,
    SlotOut,
    VbfOut,
    GateOut,
    Outcome
) :-
    (   NowMs >= Deadline
    ->  consume_airtime(GateIn, NowMs, ToaMs, GateOut, GateRes),
        (   GateRes == ok
        ->  step_vbf_on_timeout(VbfIn, false, VbfOut),
            VbfOut = vbf(_Base, NextRtoMs, _Min, _Max, _Cnt),
            NextRetries is Retries + 1,
            NextDeadline is NowMs + NextRtoMs,
            SlotOut = slot(Seq, FirstTx, NowMs, NextDeadline, NextRetries),
            Outcome = transmit_ready(Seq, NextRtoMs)
        ;   GateRes = err(WaitMs),
            DeferredDeadline is NowMs + WaitMs,
            SlotOut = slot(Seq, FirstTx, LastTx, DeferredDeadline, Retries),
            VbfOut = VbfIn,
            Outcome = deferred_by_duty_cycle(Seq, WaitMs)
        )
    ;   SlotOut = slot(Seq, FirstTx, LastTx, Deadline, Retries),
        VbfOut = VbfIn,
        GateOut = GateIn,
        Outcome = no_expired_holes
    ).
