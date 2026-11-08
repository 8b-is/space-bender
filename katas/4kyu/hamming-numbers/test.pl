% PLUnit verification suite for Hamming Numbers (4 kyu, SWI-Prolog)
:- use_module(library(plunit)).

:- begin_tests(hamming_numbers).
:- include(solution).

test(first_twenty_hamming_numbers) :-
    Expected = [1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18, 20, 24, 25, 27, 30, 32, 36],
    findall(H, (between(1, 20, K), hamming(K, H)), Actual),
    assertion(Actual == Expected).

test(large_benchmarks) :-
    hamming(1691, H1691),
    assertion(H1691 == 2125764000),
    hamming(5000, H5000),
    assertion(H5000 == 50837316566580),
    hamming(13282, H13282),
    assertion(H13282 == 18432000000000000000).

:- end_tests(hamming_numbers).
