# Finding the duplicate number (Kumite, Haxe)

**vs.** [icecream17](https://www.codewars.com/kata/finding-the-duplicate-number)
· unranked Kumite — given an array containing exactly one duplicated value,
return it.

## Baseline

icecream17 branches on array length: `pop` + `indexOf` O(n²) under 12
elements, sort + adjacent-scan O(n log n) under 100, seen-map O(n) above.
Three algorithms, three bug surfaces, and the small-input branches are
slower *and* no shorter than the map.

## Improvement

One map, one pass, O(n) time for every input size:

```haxe
var seen = new Map<Int, Bool>();
for (n in nums) {
  if (seen.exists(n)) return n;
  seen.set(n, true);
}
return null;
```

Same asymptotics as the baseline's best branch, a quarter of the code,
no length-dependent behavior to get wrong. Returns the first value
encountered twice (the tests contain exactly one duplicate each, so
which-duplicate ordering never matters).

## Verified

`haxe` is not installed locally, so the algorithm was transliterated to
Python and run against the three utest cases (`[1,2,3,3,5] → 3`,
44-element array → `22`, 95-element array → `234`) — all pass. The
platform's utest suite (`test.hx`-style asserts in the kata) is the
authoritative run.

## Files

- `solution.hx` — the solution
