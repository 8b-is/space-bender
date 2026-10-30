import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { compile, configure, toInt, fromInt } from "@codewars/lambda-calculus";

configure({ purity: "Let", numEncoding: "Church" });

const code = readFileSync(new URL("./solution.lc", import.meta.url), "utf8");
const sol = compile(code);
const { a, b, d, i, l, m, o, p, s, u, v, w } = sol;
const { id: lcNum } = compile("id = \\ x . x");

const evalInfix = (x, c1, c2, c3, y) =>
  toInt(lcNum(x)(c1)(c2)(c3)(y));

// 1. Sample tests from the kata description
assert.equal(evalInfix(2, a, d, d, 3), 5, "2 add 3 == 5");
assert.equal(evalInfix(5, s, u, b, 4), 1, "5 sub 4 == 1");
assert.equal(evalInfix(3, m, u, l, 4), 12, "3 mul 4 == 12");
assert.equal(evalInfix(5, d, i, v, 2), 2, "5 div 2 == 2");
assert.equal(evalInfix(7, m, o, d, 4), 3, "7 mod 4 == 3");
assert.equal(evalInfix(2, p, o, w, 3), 8, "2 pow 3 == 8");
assert.equal(evalInfix(0, p, o, w, 0), 1, "0 pow 0 == 1");

// 2. Exhaustive sweep across all 6 operations (including 0 edge cases)
let totalChecks = 7;
for (let x = 0; x <= 10; x++) {
  for (let y = 0; y <= 10; y++) {
    assert.equal(evalInfix(x, a, d, d, y), x + y, `${x} add ${y}`);
    assert.equal(evalInfix(x, s, u, b, y), Math.max(0, x - y), `${x} sub ${y}`);
    assert.equal(evalInfix(x, m, u, l, y), x * y, `${x} mul ${y}`);
    totalChecks += 3;

    if (y >= 1) {
      assert.equal(evalInfix(x, d, i, v, y), Math.floor(x / y), `${x} div ${y}`);
      assert.equal(evalInfix(x, m, o, d, y), x % y, `${x} mod ${y}`);
      totalChecks += 2;
    }

    if (x <= 5 && y <= 5) {
      assert.equal(evalInfix(x, p, o, w, y), x ** y, `${x} pow ${y}`);
      totalChecks += 1;
    }
  }
}

console.log(`ALL PASS (${totalChecks} Church infix evaluations verified)`);
