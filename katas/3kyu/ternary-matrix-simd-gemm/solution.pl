% Ternary Matrix SIMD Contraction & Kleene NAND Semiring (3 kyu) — SWI-Prolog 8.0+
% SPDX-License-Identifier: BSD-3-Clause
%
% Relational Horn-clause reference oracle for:
%   1. spqt_pack_5(+Trits5, -Byte) & spqt_unpack_5(+Byte, -Trits5)
%   2. ternary_dot_branchless(+Acts, +Trits, -Dot) using bitwise xor/and/sub
%   3. tgemm_pq(+WRows, +XCols, +ScaleP-ScaleQ, -YMatrixPq)
%   4. kleene_nand_gemm(+ARows, +BCols, -CMatrix)

% --- 1. SPQT Base-243 5-Trit Codec ---
spqt_pack_5([T0, T1, T2, T3, T4], Byte) :-
    Byte is (T0 + 1) + 3 * (T1 + 1) + 9 * (T2 + 1) + 27 * (T3 + 1) + 81 * (T4 + 1).

spqt_unpack_5(Byte, [T0, T1, T2, T3, T4]) :-
    T0 is (Byte mod 3) - 1, B1 is Byte // 3,
    T1 is (B1 mod 3) - 1,   B2 is B1 // 3,
    T2 is (B2 mod 3) - 1,   B3 is B2 // 3,
    T3 is (B3 mod 3) - 1,   B4 is B3 // 3,
    T4 is (B4 mod 3) - 1.

% --- 2. Zero-Multiplier Branchless Ternary Dot Product ---
ternary_dot_branchless(Acts, Trits, Dot) :-
    ternary_dot_acc(Acts, Trits, 0, Dot).

ternary_dot_acc([], [], Acc, Acc) :- !.
ternary_dot_acc([A | As], [T | Ts], Acc, Dot) :-
    Sign is T >> 31,
    Nz is -(T /\ 1),
    Term is ((A xor Sign) - Sign) /\ Nz,
    NextAcc is Acc + Term,
    ternary_dot_acc(As, Ts, NextAcc, Dot).

% --- 3. Exact Rational p/q Reduction & TGEMM ---
reduce_pq(P, Q, Pn-Qn) :-
    Q =\= 0,
    (Q < 0 -> P1 is -P, Q1 is -Q ; P1 = P, Q1 = Q),
    G is gcd(abs(P1), Q1),
    G1 is max(1, G),
    Pn is P1 // G1,
    Qn is Q1 // G1.

tgemm_pq(WRows, XCols, ScaleP-ScaleQ, YMatrix) :-
    maplist(tgemm_row(XCols, ScaleP-ScaleQ), WRows, YMatrix).

tgemm_row(XCols, ScaleP-ScaleQ, WRow, YRow) :-
    maplist(tgemm_cell(WRow, ScaleP-ScaleQ), XCols, YRow).

tgemm_cell(WRow, ScaleP-ScaleQ, XCol, CellPq) :-
    ternary_dot_branchless(XCol, WRow, RawDot),
    Num is RawDot * ScaleP,
    reduce_pq(Num, ScaleQ, CellPq).

% --- 4. Kleene Strong-3 Ternary NAND Semiring Matrix Product ---
kleene_nand3(A, B, Nand) :-
    Nand is -min(A, B).

kleene_nand_dot([A | As], [B | Bs], Best) :-
    kleene_nand3(A, B, Init),
    kleene_nand_dot_acc(As, Bs, Init, Best).

kleene_nand_dot_acc([], [], Best, Best) :- !.
kleene_nand_dot_acc([A | As], [B | Bs], Cur, Best) :-
    kleene_nand3(A, B, Cand),
    Next is max(Cur, Cand),
    kleene_nand_dot_acc(As, Bs, Next, Best).

kleene_nand_gemm(ARows, BCols, CMatrix) :-
    maplist(kleene_nand_row(BCols), ARows, CMatrix).

kleene_nand_row(BCols, ARow, CRow) :-
    maplist(kleene_nand_dot(ARow), BCols, CRow).
