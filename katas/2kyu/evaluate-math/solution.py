"""Evaluate mathematical expression — Codewars 2 kyu.

Recursive descent parser, no eval/exec. Grammar:

    expression := term (('+' | '-') term)*
    term       := factor (('*' | '/') factor)*
    factor     := '-' factor | primary
    primary    := number | '(' expression ')'

Unary minus is a factor, so `1--1`, `1 - -1`, `-(4)`, `6 + -(-4)` all parse.
* and / bind tighter than + and -, and everything is left-associative.
"""


def calc(expression: str) -> float:
    # tokenize: numbers (whole/decimal), operators, parens; whitespace ignored
    tokens: list[tuple[str, float | str]] = []
    i, n = 0, len(expression)
    while i < n:
        c = expression[i]
        if c.isspace():
            i += 1
        elif c.isdigit() or c == ".":
            j = i
            while j < n and (expression[j].isdigit() or expression[j] == "."):
                j += 1
            tokens.append(("num", float(expression[i:j])))
            i = j
        elif c in "+-*/()":
            tokens.append((c, c))
            i += 1
        else:
            i += 1

    pos = 0

    def peek() -> str | None:
        return tokens[pos][0] if pos < len(tokens) else None

    def parse_expression() -> float:
        nonlocal pos
        value = parse_term()
        while peek() in ("+", "-"):
            op = tokens[pos][0]
            pos += 1
            rhs = parse_term()
            value = value + rhs if op == "+" else value - rhs
        return value

    def parse_term() -> float:
        nonlocal pos
        value = parse_factor()
        while peek() in ("*", "/"):
            op = tokens[pos][0]
            pos += 1
            rhs = parse_factor()
            value = value * rhs if op == "*" else value / rhs
        return value

    def parse_factor() -> float:
        nonlocal pos
        if peek() == "-":
            pos += 1
            return -parse_factor()
        return parse_primary()

    def parse_primary() -> float:
        nonlocal pos
        tok = tokens[pos]
        if tok[0] == "(":
            pos += 1
            val = parse_expression()
            pos += 1  # consume ')'
            return val
        if tok[0] == "num":
            pos += 1
            return tok[1]  # type: ignore[return-value]
        raise ValueError(f"unexpected token: {tok}")

    return parse_expression()
