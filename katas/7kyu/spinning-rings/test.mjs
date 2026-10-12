import { readFileSync } from "fs";
import { compile, configure, toInt, fromInt } from "@codewars/lambda-calculus";

// platform config (confirmed by its runtime error): numEncoding: Scott, purity default PureLC
configure({ purity: "PureLC", numEncoding: "Scott" });

const code = readFileSync(new URL("./solution.lc", import.meta.url), "utf8");
const sol = compile(code);
const sr = sol["spinning-rings"];

// JS reference (the kata's own solution shape)
const ref = (im, om) => {
  const a = im + 1, b = om + 1;
  for (let i = 1; ; i++) if (im - ((i - 1) % a) === i % b) return i;
};

const app2 = (f, x, y) => f(x)(y);
let pass = true;
const check = (im, om) => {
  const expected = ref(im, om);
  const t0 = Date.now();
  const got = toInt(app2(sr, fromInt(im), fromInt(om)));
  const ms = Date.now() - t0;
  const ok = got === expected;
  if (!ok) pass = false;
  console.log(`${ok ? "PASS" : "FAIL"} spinningRings(${im},${om}) = ${got} (expected ${expected}) ${ms}ms`);
};

// kata examples
check(2, 3); // 5
check(3, 2); // 2
// full small sweep
for (let im = 1; im <= 12; im++) for (let om = 1; om <= 12; om++) check(im, om);
// edges / larger
check(1, 1);   // 1 — equal after the first move
check(1, 50);  // 1
check(50, 1);  // 101 — worst-ish case: im+1 moves
check(30, 7);  // 55
check(40, 39); // 61

console.log(pass ? "\nALL PASS" : "\nFAILURES");
process.exit(pass ? 0 : 1);
