import { readFileSync } from "fs";
import { compile, configure, toInt, fromInt } from "@codewars/lambda-calculus";

// mirror the kata stub: numEncoding: Scott (purity defaults to PureLC)
configure({ numEncoding: "Scott" });

const code = readFileSync(new URL("./solution.lc", import.meta.url), "utf8");
const sol = compile(code);
const fib = sol["fib"];

// iterative reference
const ref = (n) => {
  let a = 0, b = 1;
  for (let i = 0; i < n; i++) [a, b] = [b, a + b];
  return a;
};

let pass = true;
const check = (n) => {
  const expected = ref(n);
  const t0 = Date.now();
  const got = toInt(fib(fromInt(n)));
  const ms = Date.now() - t0;
  const ok = got === expected;
  if (!ok) pass = false;
  console.log(`${ok ? "PASS" : "FAIL"} fib(${n}) = ${got} (expected ${expected}) ${ms}ms`);
};

// n<=25: fib(25)=75025 ~6.4s. Beyond that the O(fib(n)) Scott toInt walk
// alone exceeds any plausible kata timeout for ANY solution in this interpreter.
for (let n = 0; n <= 25; n++) check(n);

console.log(pass ? "\nALL PASS" : "\nFAILURES");
process.exit(pass ? 0 : 1);
