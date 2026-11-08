% Range Extraction (4 kyu) — SWI-Prolog 8.0+
% https://www.codewars.com/kata/51ba717bb08c1cd60f00002f
%
% Compresses a strictly increasing list of integers into comma-separated ranges:
% maximal contiguous runs [A..B] of length >= 3 (B - A >= 2) become "A-B",
% whereas runs of length 1 or 2 are emitted as individual numbers ("A" or "A,B").

range_extraction([], "") :- !.
range_extraction(Xs, Result) :-
    extract_runs(Xs, Tokens),
    atomic_list_concat(Tokens, ',', Atom),
    atom_string(Atom, Result).

extract_runs([], []).
extract_runs([X | Rest], Tokens) :-
    scan_contiguous(Rest, X, End, Tail),
    format_run(X, End, TailTokens, Tokens),
    extract_runs(Tail, TailTokens).

scan_contiguous([Y | Rest], Prev, End, Tail) :-
    Y =:= Prev + 1,
    !,
    scan_contiguous(Rest, Y, End, Tail).
scan_contiguous(Tail, End, End, Tail).

format_run(Start, End, TailTokens, [StartAtom | TailTokens]) :-
    Start =:= End,
    !,
    atom_number(StartAtom, Start).
format_run(Start, End, TailTokens, [StartAtom, EndAtom | TailTokens]) :-
    End =:= Start + 1,
    !,
    atom_number(StartAtom, Start),
    atom_number(EndAtom, End).
format_run(Start, End, TailTokens, [RangeAtom | TailTokens]) :-
    format(atom(RangeAtom), '~d-~d', [Start, End]).
