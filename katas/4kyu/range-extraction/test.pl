% PLUnit verification suite for Range Extraction (4 kyu, SWI-Prolog)
:- use_module(library(plunit)).

:- begin_tests(range_extraction).
:- include(solution).

test(empty_list) :-
    range_extraction([], R),
    assertion(R == "").

test(single_element) :-
    range_extraction([42], R),
    assertion(R == "42").

test(two_contiguous_elements_not_collapsed) :-
    range_extraction([-3, -2], R),
    assertion(R == "-3,-2").

test(three_contiguous_elements_collapsed) :-
    range_extraction([-3, -2, -1], R),
    assertion(R == "-3--1").

test(codewars_canonical_example) :-
    Input = [-10, -9, -8, -6, -3, -2, -1, 0, 1, 3, 4, 5, 7, 8, 9, 10, 11, 14, 15, 17, 18, 19, 20],
    Expected = "-10--8,-6,-3-1,3-5,7-11,14,15,17-20",
    range_extraction(Input, R),
    assertion(R == Expected).

test(codewars_sample_2) :-
    Input = [-6, -3, -2, -1, 0, 1, 3, 4, 5, 7, 8, 9, 10, 11, 14, 15, 17, 18, 19, 20],
    Expected = "-6,-3-1,3-5,7-11,14,15,17-20",
    range_extraction(Input, R),
    assertion(R == Expected).

:- end_tests(range_extraction).
