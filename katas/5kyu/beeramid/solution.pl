% Beeramid (5 kyu) — SWI-Prolog 8.0+
% https://www.codewars.com/kata/51e04f6b544cf3f6550000c1
%
% Given a referral Bonus and the Price of a beer can, compute the number of
% complete levels of a square-base pyramid (1^2 + 2^2 + ... + L^2 cans)
% that can be purchased.

% Primary solution: idiomatic deterministic tail-recursive accumulator.
beeramid(Bonus, Price, Levels) :-
    Cans is max(0, floor(Bonus / Price)),
    beeramid_levels(Cans, 1, Levels).

beeramid_levels(Cans, Level, Levels) :-
    Needed is Level * Level,
    (   Cans >= Needed
    ->  Remaining is Cans - Needed,
        NextLevel is Level + 1,
        beeramid_levels(Remaining, NextLevel, Levels)
    ;   Levels is Level - 1
    ).

% O(1) closed-form solution via the square pyramidal sandwich inequality:
%   For all n >= 1:  n^3 < 3 * P(n) = n*(n+1)*(2*n+1)/2 < (n+1)^3
%   Hence floor((3*Cans)^(1/3)) is always either Levels or Levels + 1.
beeramid_o1(Bonus, Price, Levels) :-
    Cans is max(0, floor(Bonus / Price)),
    K is floor((3 * Cans) ** (1 / 3)),
    (   K * (K + 1) * (2 * K + 1) =< 6 * Cans
    ->  Levels = K
    ;   Levels is K - 1
    ).
