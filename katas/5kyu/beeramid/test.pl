% PLUnit verification suite for Beeramid (5 kyu, SWI-Prolog)
:- use_module(library(plunit)).

:- begin_tests(example).
:- include(solution).

test(example_test_1)  :- beeramid(9, 2, R), assertion(R == 1).
test(example_test_2)  :- beeramid(10, 2, R), assertion(R == 2).
test(example_test_3)  :- beeramid(11, 2, R), assertion(R == 2).
test(example_test_4)  :- beeramid(21, 1.5, R), assertion(R == 3).
test(example_test_5)  :- beeramid(454, 5, R), assertion(R == 5).
test(example_test_6)  :- beeramid(455, 5, R), assertion(R == 6).
test(example_test_7)  :- beeramid(4, 4, R), assertion(R == 1).
test(example_test_8)  :- beeramid(3, 4, R), assertion(R == 0).
test(example_test_9)  :- beeramid(0, 4, R), assertion(R == 0).
test(example_test_10) :- beeramid(-1, 4, R), assertion(R == 0).
test(example_test_11) :- beeramid(1500, 2, R), assertion(R == 12).
test(example_test_12) :- beeramid(5000, 3, R), assertion(R == 16).

test(pyramidal_boundaries) :-
    forall(
        between(1, 200, N),
        (
            Pn is N * (N + 1) * (2 * N + 1) // 6,
            PnMinus1 is Pn - 1,
            PnPlus1 is Pn + 1,
            beeramid(PnMinus1, 1, R0),
            beeramid(Pn, 1, R1),
            beeramid(PnPlus1, 1, R2),
            NMinus1 is N - 1,
            assertion(R0 == NMinus1),
            assertion(R1 == N),
            assertion(R2 == N)
        )
    ).

test(o1_closed_form_equivalence) :-
    forall(
        between(0, 2000, Cans),
        (
            beeramid(Cans, 1, R1),
            beeramid_o1(Cans, 1, R2),
            assertion(R1 == R2)
        )
    ).

:- end_tests(example).
