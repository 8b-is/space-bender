% Hamming Numbers (4 kyu) — SWI-Prolog 8.0+
% https://www.codewars.com/kata/526d84b98f428f14a60008da
%
% Computes the N-th smallest 5-smooth number (2^i * 3^j * 5^k) using
% Dijkstra's O(N) 3-pointer dynamic programming algorithm backed by a
% preallocated compound term functor(Table, h, N) with O(1) arg/3 lookup
% and pure shift-add candidate updates:
%   * 2 = X << 1
%   * 3 = X + (X << 1)
%   * 5 = X + (X << 2)

hamming(1, 1) :- !.
hamming(N, Result) :-
    N > 1,
    functor(Table, h, N),
    nb_setarg(1, Table, 1),
    hamming_fill(2, N, Table, 1, 1, 1, 2, 3, 5),
    arg(N, Table, Result).

hamming_fill(K, N, _Table, _I2, _I3, _I5, _X2, _X3, _X5) :-
    K > N,
    !.
hamming_fill(K, N, Table, I2, I3, I5, X2, X3, X5) :-
    M is min(X2, min(X3, X5)),
    nb_setarg(K, Table, M),
    (   X2 =:= M
    ->  I2Next is I2 + 1,
        arg(I2Next, Table, V2),
        X2Next is V2 << 1
    ;   I2Next = I2,
        X2Next = X2
    ),
    (   X3 =:= M
    ->  I3Next is I3 + 1,
        arg(I3Next, Table, V3),
        X3Next is V3 + (V3 << 1)
    ;   I3Next = I3,
        X3Next = X3
    ),
    (   X5 =:= M
    ->  I5Next is I5 + 1,
        arg(I5Next, Table, V5),
        X5Next is V5 + (V5 << 2)
    ;   I5Next = I5,
        X5Next = X5
    ),
    KNext is K + 1,
    hamming_fill(KNext, N, Table, I2Next, I3Next, I5Next, X2Next, X3Next, X5Next).
