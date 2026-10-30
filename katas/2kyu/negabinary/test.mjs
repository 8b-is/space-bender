import nodeAssert from "node:assert/strict";
import { readFileSync } from "node:fs";
import * as LC from "@codewars/lambda-calculus";

const assert = Object.assign(
  (cond, msg) => nodeAssert.ok(cond, msg),
  {
    strictEqual: (a, e, msg) => nodeAssert.ok(a === e, `${msg}: expected ${a} === ${e}`),
    numEql: (a, e, msg) => {
      const actual = LC.toInt(a);
      nodeAssert.ok(actual === e, `${msg}: expected ${actual} === ${e}`);
    },
    throws: (fn, _err, _reg, msg) => nodeAssert.throws(fn, msg),
  }
);

const getSolution = () =>
  readFileSync(new URL("./solution.lc", import.meta.url), "utf8");

const { Zero, Bit0, Bit1 } = LC.compile(String.raw`
Zero =       \ zero _bit0 _bit1 . zero
Bit0 = \ n . \ _zero bit0 _bit1 . bit0 n
Bit1 = \ n . \ _zero _bit0 bit1 . bit1 n
`);
const fromInt = (n) =>
  n ? (n & 1 ? Bit1(fromInt(-(n >> 1))) : Bit0(fromInt(-(n >> 1)))) : Zero;
const padded = (m) =>
  m(false)((n) => n(true)(() => padded(n))(padded))(padded);
const unsafeToInt = (m) =>
  m(LC.Primitive(0))((n) => -2 * unsafeToInt(n))(
    (n) => 1 - 2 * unsafeToInt(n)
  );
const toInt = (n) => {
  if (LC.configure().enforceBinaryScottInvariant && padded(n))
    throw new TypeError(`toInt: padded number ${unsafeToInt(n)}`);
  else return unsafeToInt(n);
};
LC.configure({
  purity: "LetRec",
  numEncoding: { fromInt, toInt },
  enforceBinaryScottInvariant: true,
  verbosity: "Calm",
});

const t0 = performance.now();
const solution = LC.compile(getSolution());
const {
  succ,
  pred,
  add,
  mul,
  neg,
  sub,
  abs,
  sign,
  dbl,
  hlf,
  div,
  mod,
  gcd,
  lcm,
  pow,
} = solution;
const {
  zero,
  "not-zero": notZero,
  eq,
  ne,
  lt0,
  le0,
  ge0,
  gt0,
  compare,
  lt,
  le,
  ge,
  gt,
  min,
  max,
} = solution;
const {
  "to-binary-scott": toBinaryScott,
  "from-binary-scott": fromBinaryScott,
  times,
} = solution;
const { "bit-and": bitAnd, "bit-or": bitOr, "bit-xor": bitXor } = solution;
const {
  "set-bit": setBit,
  "clear-bit": clearBit,
  "invert-bit": invertBit,
} = solution;
const {
  "test-bit": testBit,
  bit,
  "pop-count": popCount,
  "bit-clz": bitClz,
  even,
  odd,
} = solution;
const { if: iff, order } = solution;
const toBoolean = (p) => iff(p)(true)(false);
const toOrdering = (cmp) => order(cmp)(-1)(0)(1);

const refFromBinaryScottToInt = (m) =>
  m(LC.Primitive(0))((n) => 2 * refFromBinaryScottToInt(n))(
    (n) => 1 + 2 * refFromBinaryScottToInt(n)
  );
const refToBinaryScottFromInt = (n) =>
  n
    ? n & 1
      ? Bit1(refToBinaryScottFromInt(n >> 1))
      : Bit0(refToBinaryScottFromInt(n >> 1))
    : Zero;
const refFromNB = (n) => n && -2 * refFromNB(n >> 1) + (n & 1);
const refToNB = (n) => (n + 0xaaaaaaaa) ^ 0xaaaaaaaa;
const refPopCount = (n) => n && 1 + refPopCount(n & (n - 1));
const refClz = (n) => n && 31 - Math.clz32(n & -n);
const refGCD = (m, n) => (n ? refGCD(n, m % n) : m);
const refLCM = (m, n) => m && (m / refGCD(m, n)) * n;

const rnd = (m, n = 0) => Math.floor(Math.random() * (n - m) + m);

let suites = 0;
function describe(_name, fn) {
  fn();
}
function it(name, fn) {
  const s0 = performance.now();
  fn();
  suites++;
}

describe("NegaBinaryScott", function () {
  it("import checks", function () {
    for (const name of [
      "succ",
      "pred",
      "add",
      "mul",
      "neg",
      "sub",
      "abs",
      "sign",
      "dbl",
      "hlf",
      "div",
      "mod",
      "gcd",
      "lcm",
      "pow",
      "zero",
      "not-zero",
      "eq",
      "ne",
      "lt0",
      "le0",
      "ge0",
      "gt0",
      "compare",
      "lt",
      "le",
      "ge",
      "gt",
      "min",
      "max",
      "bit-and",
      "bit-or",
      "bit-xor",
      "set-bit",
      "clear-bit",
      "invert-bit",
      "test-bit",
      "bit",
      "pop-count",
      "bit-clz",
      "even",
      "odd",
      "to-binary-scott",
      "from-binary-scott",
      "times",
      "if",
      "order",
    ])
      assert(solution[name], `import ${name} was not defined`);
  });
  describe("fixed tests", function () {
    it("succ, pred", function () {
      for (let n = -10; n <= 10; n++)
        assert.numEql(succ(n), n + 1, `succ ${n}`),
          assert.numEql(pred(n), n - 1, `pred ${n}`);
    });
    it("add", function () {
      for (let m = -5; m <= 5; m++)
        for (let n = -5; n <= 5; n++)
          assert.numEql(add(m)(n), m + n, `add ${m} ${n}`);
    });
    it("mul", function () {
      for (let m = -5; m <= 5; m++)
        for (let n = -5; n <= 5; n++)
          assert.numEql(mul(m)(n), m * n, `mul ${m} ${n}`);
    });
    it("neg", function () {
      for (let n = -10; n <= 10; n++) assert.numEql(neg(n), -n, `neg ${n}`);
    });
    it("sub", function () {
      for (let m = -5; m <= 5; m++)
        for (let n = -5; n <= 5; n++)
          assert.numEql(sub(m)(n), m - n, `sub ${m} ${n}`);
    });
    it("abs, sign", function () {
      for (let n = -10; n <= 10; n++)
        assert.numEql(abs(n), Math.abs(n), `abs ${n}`),
          assert.numEql(sign(n), Math.sign(n), `sign ${n}`);
    });
    it("dbl, hlf", function () {
      for (let n = -10; n <= 10; n++)
        assert.numEql(dbl(n), n << 1, `dbl ${n}`),
          assert.numEql(hlf(n), n >> 1, `hlf ${n}`);
    });
    it("div, mod", function () {
      for (let m = -5; m <= 5; m++)
        for (let n = -5; n <= 5; n++)
          if (n) {
            const q = Math.floor(m / n);
            const r = m - q * n;
            assert.numEql(div(m)(n), q, `div ${m} ${n}`);
            assert.numEql(mod(m)(n), r, `mod ${m} ${n}`);
          } else
            assert.throws(() => div(m)(n), null, null, `div ${m} ${n}`),
              assert.throws(() => mod(m)(n), null, null, `mod ${m} ${n}`);
    });
    it("gcd, lcm", function () {
      for (let m = 0; m <= 5; m++)
        for (let n = 0; n <= 5; n++)
          assert.numEql(gcd(m)(n), Math.abs(refGCD(m, n)), `gcd ${m} ${n}`),
            assert.numEql(lcm(m)(n), Math.abs(refLCM(m, n)), `lcm ${m} ${n}`);
    });
    it("pow", function () {
      for (let m = -5; m <= 5; m++)
        for (let n = -1; n <= 5; n++)
          if (n >= 0) assert.numEql(pow(m)(n), m ** n, `pow ${m} ${n}`);
          else assert.throws(() => pow(m)(n), null, null, `pow ${m} ${n}`);
    });
    it("eq, uneq 0", function () {
      for (let n = -10; n <= 10; n++)
        assert.strictEqual(toBoolean(zero(n)), n == 0, `zero ${n}`),
          assert.strictEqual(toBoolean(notZero(n)), n != 0, `not-zero ${n}`),
          assert.strictEqual(toBoolean(lt0(n)), n < 0, `lt0 ${n}`),
          assert.strictEqual(toBoolean(le0(n)), n <= 0, `le0 ${n}`),
          assert.strictEqual(toBoolean(ge0(n)), n >= 0, `ge0 ${n}`),
          assert.strictEqual(toBoolean(gt0(n)), n > 0, `gt0 ${n}`);
    });
    it("compare", function () {
      for (let m = -5; m <= 5; m++)
        for (let n = -5; n <= 5; n++)
          assert.numEql(
            toOrdering(compare(m)(n)),
            Math.sign(m - n),
            `compare ${m} ${n}`
          );
    });
    it("lt, le, eq, ge, gt, ne", function () {
      for (let m = -5; m <= 5; m++)
        for (let n = -5; n <= 5; n++)
          assert.strictEqual(toBoolean(lt(m)(n)), m < n, `lt ${m} ${n}`),
            assert.strictEqual(toBoolean(le(m)(n)), m <= n, `le ${m} ${n}`),
            assert.strictEqual(toBoolean(eq(m)(n)), m == n, `eq ${m} ${n}`),
            assert.strictEqual(toBoolean(ge(m)(n)), m >= n, `ge ${m} ${n}`),
            assert.strictEqual(toBoolean(gt(m)(n)), m > n, `gt ${m} ${n}`),
            assert.strictEqual(toBoolean(ne(m)(n)), m != n, `ne ${m} ${n}`);
    });
    it("min, max", function () {
      for (let m = -5; m <= 5; m++)
        for (let n = -5; n <= 5; n++)
          assert.numEql(min(m)(n), Math.min(m, n), `min ${m} ${n}`),
            assert.numEql(max(m)(n), Math.max(m, n), `max ${m} ${n}`);
    });
    it("fromBinaryScott", function () {
      for (let n = 0; n <= 10; n++)
        assert.numEql(
          fromBinaryScott(refToBinaryScottFromInt(n)),
          n,
          `from-binary-scott ${n}`
        );
    });
    it("toBinaryScott", function () {
      for (let n = -10; n < 0; n++)
        assert.throws(
          () => refFromBinaryScottToInt(toBinaryScott(n)),
          null,
          null,
          `to-binary-scott ${n}`
        );
      for (let n = 0; n <= 10; n++)
        assert.strictEqual(
          refFromBinaryScottToInt(toBinaryScott(n)),
          n,
          `to-binary-scott ${n}`
        );
    });
    it("times", function () {
      for (let n = 0; n <= 10; n++)
        assert.numEql(times(n)(succ)(0), n, `times ${n} succ 0`),
          assert.numEql(times(n)(pred)(0), -n, `times ${n} pred 0`);
    });
    it("and, or, xor", function () {
      for (let m = -5; m <= 5; m++)
        for (let n = -5; n <= 5; n++)
          assert.numEql(
            bitAnd(m)(n),
            refFromNB(refToNB(m) & refToNB(n)),
            `bit-and ${m} ${n}`
          ),
            assert.numEql(
              bitOr(m)(n),
              refFromNB(refToNB(m) | refToNB(n)),
              `bit-or ${m} ${n}`
            ),
            assert.numEql(
              bitXor(m)(n),
              refFromNB(refToNB(m) ^ refToNB(n)),
              `bit-xor ${m} ${n}`
            );
    });
    it("set-bit, clear-bit, invert-bit", function () {
      for (let n = -10; n <= 10; n++)
        for (let i = 0; i <= 5; i++)
          assert.numEql(
            setBit(i)(n),
            refFromNB(refToNB(n) | (1 << i)),
            `set-bit ${i} ${n}`
          ),
            assert.numEql(
              clearBit(i)(n),
              refFromNB(refToNB(n) & ~(1 << i)),
              `clear-bit ${i} ${n}`
            ),
            assert.numEql(
              invertBit(i)(n),
              refFromNB(refToNB(n) ^ (1 << i)),
              `invert-bit ${i} ${n}`
            );
    });
    it("test-bit", function () {
      for (let n = -10; n <= 10; n++)
        for (let i = 0; i <= 6; i++)
          assert.strictEqual(
            toBoolean(testBit(i)(n)),
            Boolean(refToNB(n) & (1 << i)),
            `test-bit ${i} ${n}`
          );
    });
    it("bit", function () {
      for (let i = 0; i <= 10; i++)
        assert.numEql(bit(i), (-2) ** i, `bit ${i}`);
    });
    it("pop-count", function () {
      for (let n = -10; n <= 10; n++)
        assert.numEql(popCount(n), refPopCount(refToNB(n)), `pop-count ${n}`);
    });
    it("bit-clz", function () {
      for (let n = -10; n <= 10; n++)
        assert.numEql(bitClz(n), refClz(n), `bit-clz ${n}`);
    });
    it("even, odd", function () {
      for (let n = -10; n <= 10; n++)
        assert.strictEqual(toBoolean(even(n)), !(n & 1), `even ${n}`),
          assert.strictEqual(toBoolean(odd(n)), Boolean(n & 1), `odd ${n}`);
    });
  });
  describe("random tests", function () {
    it("succ, pred", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        assert.numEql(succ(n), n + 1, `succ ${n}`),
          assert.numEql(pred(n), n - 1, `pred ${n}`);
      }
      const n = rnd(1024, 2048);
      assert.numEql(succ(n), n + 1, `succ ${n}`),
        assert.numEql(succ(-n), -n + 1, `succ ${-n}`),
        assert.numEql(pred(n), n - 1, `pred ${n}`),
        assert.numEql(pred(-n), -n - 1, `pred ${-n}`);
    });
    it("add", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i, i);
        assert.numEql(add(m)(n), m + n, `add ${m} ${n}`);
      }
      const m = rnd(1024, 2048);
      const n = rnd(1024, 2048);
      assert.numEql(add(m)(n), m + n, `add ${m} ${n}`),
        assert.numEql(add(-m)(-n), -m - n, `add ${-m} ${-n}`);
    });
    it("mul", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i, i);
        assert.numEql(mul(m)(n), m * n, `mul ${m} ${n}`);
      }
      const m = rnd(1024, 2048);
      const n = rnd(1024, 2048);
      assert.numEql(mul(m)(n), m * n, `mul ${m} ${n}`),
        assert.numEql(mul(m)(-n), -m * n, `mul ${m} ${-n}`),
        assert.numEql(mul(-m)(n), -m * n, `mul ${-m} ${n}`),
        assert.numEql(mul(-m)(-n), m * n, `mul ${-m} ${-n}`);
    });
    it("neg", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        assert.numEql(neg(n), -n, `neg ${n}`);
      }
      const n = rnd(1024, 2048);
      assert.numEql(neg(n), -n, `neg ${n}`),
        assert.numEql(neg(-n), n, `neg ${-n}`);
    });
    it("sub", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i, i);
        assert.numEql(sub(m)(n), m - n, `sub ${m} ${n}`);
      }
      const m = rnd(1024, 2048);
      const n = rnd(1024, 2048);
      assert.numEql(sub(m)(n), m - n, `sub ${m} ${n}`);
      assert.numEql(sub(-m)(-n), n - m, `sub ${-m} ${-n}`);
    });
    it("abs, sign", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        assert.numEql(abs(n), Math.abs(n), `abs ${n}`),
          assert.numEql(sign(n), Math.sign(n), `sign ${n}`);
      }
      const n = rnd(1024, 2048);
      assert.numEql(abs(n), n, `abs ${n}`),
        assert.numEql(abs(-n), n, `abs ${-n}`),
        assert.numEql(sign(n), Math.sign(n), `sign ${n}`),
        assert.numEql(sign(-n), -Math.sign(n), `sign ${-n}`);
    });
    it("dbl, hlf", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        assert.numEql(dbl(n), n << 1, `dbl ${n}`),
          assert.numEql(hlf(n), n >> 1, `hlf ${n}`);
      }
      const n = rnd(1024, 2048);
      assert.numEql(dbl(n), n << 1, `dbl ${n}`),
        assert.numEql(dbl(-n), -n << 1, `dbl ${-n}`),
        assert.numEql(hlf(n), n >> 1, `hlf ${n}`),
        assert.numEql(hlf(-n), -n >> 1, `hlf ${-n}`);
    });
    it("div, mod", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i, i);
        if (n) {
          const q = Math.floor(m / n);
          const r = m - q * n;
          assert.numEql(div(m)(n), q, `div ${m} ${n}`),
            assert.numEql(mod(m)(n), r, `mod ${m} ${n}`);
        } else
          assert.throws(() => div(m)(n), null, null, `div ${m} ${n}`),
            assert.throws(() => mod(m)(n), null, null, `mod ${m} ${n}`);
      }
      const m = rnd(1024, 2048);
      const n = rnd(32, 64);
      const q = Math.floor(m / n),
        qq = Math.floor(-m / n);
      const r = m - q * n,
        rr = m + qq * n;
      assert.numEql(div(m)(n), q, `div ${m} ${n}`),
        assert.numEql(div(m)(-n), qq, `div ${m} ${-n}`),
        assert.numEql(div(-m)(n), qq, `div ${-m} ${n}`),
        assert.numEql(div(-m)(-n), q, `div ${-m} ${-n}`),
        assert.numEql(mod(m)(n), r, `mod ${m} ${n}`),
        assert.numEql(mod(m)(-n), rr, `mod ${m} ${-n}`),
        assert.numEql(mod(-m)(n), -rr, `mod ${-m} ${n}`),
        assert.numEql(mod(-m)(-n), -r, `mod ${-m} ${-n}`);
    });
    it("gcd, lcm", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i, i);
        assert.numEql(gcd(m)(n), Math.abs(refGCD(m, n)), `gcd ${m} ${n}`),
          assert.numEql(lcm(m)(n), Math.abs(refLCM(m, n)), `lcm ${m} ${n}`);
      }
      const m = rnd(1024, 2048);
      const n = rnd(1024, 2048);
      assert.numEql(gcd(m)(n), Math.abs(refGCD(m, n)), `gcd ${m} ${n}`),
        assert.numEql(gcd(m)(-n), Math.abs(refGCD(m, -n)), `gcd ${m} ${-n}`),
        assert.numEql(lcm(m)(n), Math.abs(refLCM(m, n)), `lcm ${m} ${n}`),
        assert.numEql(lcm(m)(-n), Math.abs(refLCM(m, -n)), `lcm ${m} ${-n}`);
    });
    it("pow", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i / 4, i / 2);
        if (n >= 0) assert.numEql(pow(m)(n), m ** n, `pow ${m} ${n}`);
        else assert.throws(() => pow(m)(n), null, null, `pow ${m} ${n}`);
      }
      const n = rnd(1024, 1553);
      assert.numEql(pow(n)(5), n ** 5, `pow ${n} ${5}`),
        assert.numEql(pow(-n)(5), -(n ** 5), `pow ${-n} ${5}`);
    });
    it("eq, uneq 0", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        assert.strictEqual(toBoolean(zero(n)), n == 0, `zero ${n}`),
          assert.strictEqual(toBoolean(notZero(n)), n != 0, `not-zero ${n}`),
          assert.strictEqual(toBoolean(lt0(n)), n < 0, `lt0 ${n}`),
          assert.strictEqual(toBoolean(le0(n)), n <= 0, `le0 ${n}`),
          assert.strictEqual(toBoolean(ge0(n)), n >= 0, `ge0 ${n}`),
          assert.strictEqual(toBoolean(gt0(n)), n > 0, `gt0 ${n}`);
      }
      const n = rnd(1024, 2048);
      assert.strictEqual(toBoolean(zero(n)), false, `zero ${n}`),
        assert.strictEqual(toBoolean(notZero(n)), true, `not-zero ${n}`),
        assert.strictEqual(toBoolean(lt0(n)), false, `lt0 ${n}`),
        assert.strictEqual(toBoolean(le0(n)), false, `le0 ${n}`),
        assert.strictEqual(toBoolean(ge0(n)), true, `ge0 ${n}`),
        assert.strictEqual(toBoolean(gt0(n)), true, `gt0 ${n}`),
        assert.strictEqual(toBoolean(zero(-n)), false, `zero ${-n}`),
        assert.strictEqual(toBoolean(notZero(-n)), true, `not-zero ${-n}`),
        assert.strictEqual(toBoolean(lt0(-n)), true, `lt0 ${-n}`),
        assert.strictEqual(toBoolean(le0(-n)), true, `le0 ${-n}`),
        assert.strictEqual(toBoolean(ge0(-n)), false, `ge0 ${-n}`),
        assert.strictEqual(toBoolean(gt0(-n)), false, `gt0 ${-n}`);
    });
    it("compare", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i, i);
        assert.numEql(
          toOrdering(compare(m)(n)),
          Math.sign(m - n),
          `compare ${m} ${n}`
        );
      }
      const m = rnd(1024, 2048);
      const n = rnd(1024, 2048);
      assert.numEql(
        toOrdering(compare(m)(n)),
        Math.sign(m - n),
        `compare ${m} ${n}`
      );
      assert.numEql(
        toOrdering(compare(-m)(-n)),
        Math.sign(n - m),
        `compare ${-m} ${-n}`
      );
    });
    it("lt, le, eq, ge, gt, ne", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i, i);
        assert.strictEqual(toBoolean(lt(m)(n)), m < n, `lt ${m} ${n}`),
          assert.strictEqual(toBoolean(le(m)(n)), m <= n, `le ${m} ${n}`),
          assert.strictEqual(toBoolean(eq(m)(n)), m == n, `eq ${m} ${n}`),
          assert.strictEqual(toBoolean(ge(m)(n)), m >= n, `ge ${m} ${n}`),
          assert.strictEqual(toBoolean(gt(m)(n)), m > n, `gt ${m} ${n}`),
          assert.strictEqual(toBoolean(ne(m)(n)), m != n, `ne ${m} ${n}`);
      }
      const m = rnd(1024, 2048);
      const n = rnd(1024, 2048);
      assert.strictEqual(toBoolean(lt(m)(n)), m < n, `lt ${m} ${n}`),
        assert.strictEqual(toBoolean(le(m)(n)), m <= n, `le ${m} ${n}`),
        assert.strictEqual(toBoolean(eq(m)(n)), m == n, `eq ${m} ${n}`),
        assert.strictEqual(toBoolean(ge(m)(n)), m >= n, `ge ${m} ${n}`),
        assert.strictEqual(toBoolean(gt(m)(n)), m > n, `gt ${m} ${n}`),
        assert.strictEqual(toBoolean(ne(m)(n)), m != n, `ne ${m} ${n}`),
        assert.strictEqual(toBoolean(lt(-m)(-n)), m > n, `lt ${-m} ${-n}`),
        assert.strictEqual(toBoolean(le(-m)(-n)), m >= n, `le ${-m} ${-n}`),
        assert.strictEqual(toBoolean(eq(-m)(-n)), m == n, `eq ${-m} ${-n}`),
        assert.strictEqual(toBoolean(ge(-m)(-n)), m <= n, `ge ${-m} ${-n}`),
        assert.strictEqual(toBoolean(gt(-m)(-n)), m < n, `gt ${-m} ${-n}`),
        assert.strictEqual(toBoolean(ne(-m)(-n)), m != n, `ne ${-m} ${-n}`);
    });
    it("min, max", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i, i);
        assert.numEql(min(m)(n), Math.min(m, n), `min ${m} ${n}`),
          assert.numEql(max(m)(n), Math.max(m, n), `max ${m} ${n}`);
      }
      const m = rnd(1024, 2048);
      const n = rnd(1024, 2048);
      assert.numEql(min(m)(n), Math.min(m, n), `min ${m} ${n}`),
        assert.numEql(min(-m)(-n), -Math.max(m, n), `min ${-m} ${-n}`),
        assert.numEql(max(m)(n), Math.max(m, n), `max ${m} ${n}`),
        assert.numEql(max(-m)(-n), -Math.min(m, n), `max ${-m} ${-n}`);
    });
    it("fromBinaryScott", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(i);
        assert.numEql(
          fromBinaryScott(refToBinaryScottFromInt(n)),
          n,
          `from-binary-scott ${n}`
        );
      }
      const n = rnd(1024, 2048);
      assert.numEql(
        fromBinaryScott(refToBinaryScottFromInt(n)),
        n,
        `from-binary-scott ${n}`
      );
    });
    it("toBinaryScott", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        if (n < 0)
          assert.throws(
            () => refFromBinaryScottToInt(toBinaryScott(n)),
            null,
            null,
            `to-binary-scott ${n}`
          );
        else
          assert.strictEqual(
            refFromBinaryScottToInt(toBinaryScott(n)),
            n,
            `to-binary-scott ${n}`
          );
      }
      const n = rnd(1024, 2048);
      assert.strictEqual(
        refFromBinaryScottToInt(toBinaryScott(n)),
        n,
        `to-binary-scott ${n}`
      );
    });
    it("times", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(i);
        assert.numEql(times(n)(succ)(0), n, `times ${n} succ 0`),
          assert.numEql(times(n)(pred)(0), -n, `times ${n} pred 0`);
      }
      const n = rnd(1024, 2048);
      assert.numEql(times(n)(succ)(0), n, `times ${n} succ 0`);
    });
    it("and, or, xor", function () {
      for (let i = 1; i <= 20; i++) {
        const m = rnd(-i, i);
        const n = rnd(-i, i);
        assert.numEql(
          bitAnd(m)(n),
          refFromNB(refToNB(m) & refToNB(n)),
          `bit-and ${m} ${n}`
        ),
          assert.numEql(
            bitOr(m)(n),
            refFromNB(refToNB(m) | refToNB(n)),
            `bit-or ${m} ${n}`
          ),
          assert.numEql(
            bitXor(m)(n),
            refFromNB(refToNB(m) ^ refToNB(n)),
            `bit-xor ${m} ${n}`
          );
      }
      const m = rnd(1024, 2048);
      const n = rnd(1024, 2048);
      assert.numEql(
        bitAnd(m)(n),
        refFromNB(refToNB(m) & refToNB(n)),
        `bit-and ${m} ${n}`
      ),
        assert.numEql(
          bitAnd(m)(-n),
          refFromNB(refToNB(m) & refToNB(-n)),
          `bit-and ${m} ${-n}`
        ),
        assert.numEql(
          bitOr(m)(n),
          refFromNB(refToNB(m) | refToNB(n)),
          `bit-or ${m} ${n}`
        ),
        assert.numEql(
          bitOr(m)(-n),
          refFromNB(refToNB(m) | refToNB(-n)),
          `bit-or ${m} ${-n}`
        ),
        assert.numEql(
          bitXor(m)(n),
          refFromNB(refToNB(m) ^ refToNB(n)),
          `bit-xor ${m} ${n}`
        ),
        assert.numEql(
          bitXor(m)(-n),
          refFromNB(refToNB(m) ^ refToNB(-n)),
          `bit-xor ${m} ${-n}`
        );
    });
    it("set-bit, clear-bit, invert-bit", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        const j = rnd(i / 2);
        assert.numEql(
          setBit(j)(n),
          refFromNB(refToNB(n) | (1 << j)),
          `set-bit ${j} ${n}`
        ),
          assert.numEql(
            clearBit(j)(n),
            refFromNB(refToNB(n) & ~(1 << j)),
            `clear-bit ${j} ${n}`
          ),
          assert.numEql(
            invertBit(j)(n),
            refFromNB(refToNB(n) ^ (1 << j)),
            `invert-bit ${j} ${n}`
          );
      }
      const n = rnd(1024, 2048);
      const j = 7;
      assert.numEql(
        setBit(j)(n),
        refFromNB(refToNB(n) | (1 << j)),
        `set-bit ${j} ${n}`
      ),
        assert.numEql(
          setBit(j)(-n),
          refFromNB(refToNB(-n) | (1 << j)),
          `set-bit ${j} ${-n}`
        ),
        assert.numEql(
          clearBit(j)(n),
          refFromNB(refToNB(n) & ~(1 << j)),
          `clear-bit ${j} ${n}`
        ),
        assert.numEql(
          clearBit(j)(-n),
          refFromNB(refToNB(-n) & ~(1 << j)),
          `clear-bit ${j} ${-n}`
        ),
        assert.numEql(
          invertBit(j)(n),
          refFromNB(refToNB(n) ^ (1 << j)),
          `invert-bit ${j} ${n}`
        ),
        assert.numEql(
          invertBit(j)(-n),
          refFromNB(refToNB(-n) ^ (1 << j)),
          `invert-bit ${j} ${-n}`
        );
    });
    it("test-bit", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        const j = rnd(i);
        assert.strictEqual(
          toBoolean(testBit(j)(n)),
          Boolean(refToNB(n) & (1 << j)),
          `test-bit ${j} ${n}`
        );
      }
      const n = rnd(1024, 2048);
      const j = 7;
      assert.strictEqual(
        toBoolean(testBit(j)(n)),
        Boolean(refToNB(n) & (1 << j)),
        `test-bit ${j} ${n}`
      ),
        assert.strictEqual(
          toBoolean(testBit(j)(-n)),
          Boolean(refToNB(-n) & (1 << j)),
          `test-bit ${j} ${-n}`
        );
    });
    it("bit", function () {
      for (let i = 1; i <= 20; i++) {
        const j = rnd(i);
        assert.numEql(bit(j), (-2) ** j, `bit ${j}`);
      }
    });
    it("pop-count", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        assert.numEql(popCount(n), refPopCount(refToNB(n)), `pop-count ${n}`);
      }
      const n = rnd(1024, 2048);
      assert.numEql(popCount(n), refPopCount(refToNB(n)), `pop-count ${n}`),
        assert.numEql(
          popCount(-n),
          refPopCount(refToNB(-n)),
          `pop-count ${-n}`
        );
    });
    it("bit-clz", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        assert.numEql(bitClz(n), refClz(n), `bit-clz ${n}`);
      }
      const n = rnd(1024, 2048);
      assert.numEql(bitClz(n), refClz(n), `bit-clz ${n}`);
      assert.numEql(bitClz(-n), refClz(n), `bit-clz ${-n}`);
    });
    it("even, odd", function () {
      for (let i = 1; i <= 20; i++) {
        const n = rnd(-i, i);
        assert.strictEqual(toBoolean(even(n)), !(n & 1), `even ${n}`),
          assert.strictEqual(toBoolean(odd(n)), Boolean(n & 1), `odd ${n}`);
      }
      const n = rnd(1024, 2048);
      assert.strictEqual(toBoolean(even(n)), !(n & 1), `even ${n}`),
        assert.strictEqual(toBoolean(even(-n)), !(n & 1), `even ${-n}`),
        assert.strictEqual(toBoolean(odd(n)), Boolean(n & 1), `odd ${n}`),
        assert.strictEqual(toBoolean(odd(-n)), Boolean(n & 1), `odd ${-n}`);
    });
  });
});

const elapsed = (performance.now() - t0).toFixed(1);
console.log(`ALL PASS (${suites} test suites verified in ${elapsed} ms)`);
