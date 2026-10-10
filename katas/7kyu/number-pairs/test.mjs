import { readFileSync } from "fs";
import { compile, configure, toInt, fromInt } from "@codewars/lambda-calculus";

configure({ purity: "LetRec", numEncoding: "Church" });

const code = readFileSync(new URL("./solution.lc", import.meta.url), "utf8");
const sol = compile(code);
const { cons, nil, foldr } = sol;
const getLarger = sol["get-larger-numbers"];

const mk = (arr) => arr.reduceRight((t, x) => cons(fromInt(x))(t), nil);
const decode = (l) => {
  const out = [];
  foldr((x) => (acc) => {
    out.unshift(toInt(x));
    return acc;
  })(null)(l);
  return out;
};

let pass = true;
const check = (name, a1, a2, expected) => {
  const got = decode(getLarger(mk(a1))(mk(a2)));
  const ok = JSON.stringify(got) === JSON.stringify(expected);
  if (!ok) pass = false;
  console.log(`${ok ? "PASS" : "FAIL"} ${name}: got=${JSON.stringify(got)} expected=${JSON.stringify(expected)}`);
};

// kata example
check("example", [13, 64, 15, 17, 88], [23, 14, 53, 17, 80], [23, 64, 53, 17, 88]);
// edge cases
check("empty", [], [], []);
check("single", [7], [9], [9]);
check("equal", [5], [5], [5]);
check("ties/first-wins-order", [1, 100, 3], [2, 50, 4], [2, 100, 4]);
check("zeros", [0, 0], [0, 1], [0, 1]);
check("bigger", [999, 1, 500], [1000, 2, 499], [1000, 2, 500]);

// scale sanity (values <= 100, length 60)
{
  const n = 60, max = 100;
  let seed = 42;
  const rnd = () => (seed = (seed * 1103515245 + 12345) & 0x7fffffff) % max;
  const a = Array.from({ length: n }, rnd);
  const b = Array.from({ length: n }, rnd);
  const expected = a.map((x, i) => Math.max(x, b[i]));
  const t0 = Date.now();
  const got = decode(getLarger(mk(a))(mk(b)));
  const ms = Date.now() - t0;
  const ok = JSON.stringify(got) === JSON.stringify(expected);
  if (!ok) pass = false;
  console.log(`${ok ? "PASS" : "FAIL"} scale n=${n} max<${max} (${ms}ms)`);
}

console.log(pass ? "\nALL PASS" : "\nFAILURES");
process.exit(pass ? 0 : 1);
