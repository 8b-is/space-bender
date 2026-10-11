import { readFileSync } from "fs";
import { compile, configure, toInt, fromInt } from "@codewars/lambda-calculus";

// mirror the kata stub: only numEncoding is specified (purity defaults to PureLC)
configure({ numEncoding: "BinaryScott" });

const code = readFileSync(new URL("./solution.lc", import.meta.url), "utf8");
const sol = compile(code);
const next = sol["next-higher"];

// Gosper's hack reference
const snoob = (x) => {
  const smallest = x & -x;
  const ripple = x + smallest;
  let ones = x ^ ripple;
  ones = (ones >>> 2) / smallest;
  return (ripple | ones) >>> 0; // unsigned: handles 1<<30 -> 1<<31
};

let pass = true;
const check = (n) => {
  const expected = snoob(n);
  const t0 = Date.now();
  const got = toInt(next(fromInt(n)));
  const ms = Date.now() - t0;
  const ok = got === expected;
  if (!ok) pass = false;
  console.log(`${ok ? "PASS" : "FAIL"} ${n} -> ${got} (expected ${expected}) ${ms}ms`);
};

// description examples
for (const n of [129, 127, 1, 323423]) check(n);
// small sweep
for (let n = 1; n <= 64; n++) check(n);
// edge: top of input range
check(1 << 30);
check((1 << 30) + (1 << 29)); // 110...0 -> 1010...0
// deterministic randoms across the range
{
  let seed = 42;
  const rnd = () => (seed = (seed * 1103515245 + 12345) & 0x7fffffff);
  for (let i = 0; i < 20; i++) check((rnd() % (1 << 30)) + 1);
}

console.log(pass ? "\nALL PASS" : "\nFAILURES");
process.exit(pass ? 0 : 1);
