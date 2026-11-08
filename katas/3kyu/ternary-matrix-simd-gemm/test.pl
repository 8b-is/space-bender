% PLUnit verification suite for Ternary Matrix SIMD Contraction (3 kyu, SWI-Prolog)
:- use_module(library(plunit)).

:- begin_tests(ternary_matrix_simd_gemm).
:- include(solution).

test(spqt_base243_bijection_243_pentads) :-
    forall(
        between(0, 242, Byte),
        (
            spqt_unpack_5(Byte, Trits),
            spqt_pack_5(Trits, Roundtrip),
            assertion(Roundtrip == Byte)
        )
    ).

test(zero_multiplier_branchless_dot) :-
    Acts  = [10, 20, 30, 40, 50, 60, 70, 80, 90],
    Trits = [ 1, -1,  0,  1, -1,  1,  1,  0,  1],
    ternary_dot_branchless(Acts, Trits, Dot),
    assertion(Dot == 200).

test(tgemm_exact_pq_contraction) :-
    WRows = [
        [1, -1, 0, 1, -1, 1, 1, 0, 1],
        [1, -1, 1, 0, -1, 1, 1, 1, 0]
    ],
    XCols = [
        [ 10, 20,  30, 40,  50, 60,  70, 80,  90],
        [-15, 25, -35, 45, -55, 65, -75, 85, -95]
    ],
    tgemm_pq(WRows, XCols, 3-8, Y),
    assertion(Y == [[75-1, -135-8], [135-2, 165-8]]).

test(kleene_nand_semiring_gemm) :-
    ARows = [[1, 0], [-1, 1]],
    BCols = [[1, 0], [-1, 1]],
    kleene_nand_gemm(ARows, BCols, C),
    assertion(C == [[0, 1], [1, 1]]).

:- end_tests(ternary_matrix_simd_gemm).
