"""Simpler Interactive Interpreter — Codewars 2 kyu (REPL).

Recursive descent interpreter with persistent variable state. No eval.

Grammar (EBNF from the kata):
    expression ::= factor | expression operator expression
    factor     ::= number | identifier | assignment | '(' expression ')'
    assignment ::= identifier '=' expression
    operator   ::= '+' | '-' | '*' | '/' | '%'

Precedence (low → high): assignment, additive (+ -), multiplicative (* / %).
Left-associative. Whitespace-only input returns "".
"""


class Interpreter:
    def __init__(self):
        self.vars: dict[str, float] = {}
        self.tokens: list[tuple[str, float | str]] = []
        self.pos = 0

    def input(self, expression: str) -> float | str:
        if not expression.strip():
            return ""
        self.tokens = self._tokenize(expression)
        self.pos = 0
        value = self._parse_expression()
        if self.pos != len(self.tokens):
            raise Exception("Invalid input")
        return value

    # --- tokenizer ---------------------------------------------------------

    def _tokenize(self, s: str) -> list[tuple[str, float | str]]:
        tokens: list[tuple[str, float | str]] = []
        i, n = 0, len(s)
        while i < n:
            c = s[i]
            if c.isspace():
                i += 1
            elif c.isalpha() or c == "_":
                j = i
                while j < n and (s[j].isalnum() or s[j] == "_"):
                    j += 1
                tokens.append(("id", s[i:j]))
                i = j
            elif c.isdigit() or c == ".":
                j = i
                while j < n and (s[j].isdigit() or s[j] == "."):
                    j += 1
                tokens.append(("num", float(s[i:j])))
                i = j
            elif c in "+-*/%=":
                tokens.append((c, c))
                i += 1
            elif c in "()":
                tokens.append((c, c))
                i += 1
            else:
                i += 1
        return tokens

    # --- parser ------------------------------------------------------------

    def _peek(self) -> str | None:
        return self.tokens[self.pos][0] if self.pos < len(self.tokens) else None

    def _parse_expression(self) -> float:
        # assignment has the lowest precedence: identifier '=' expression
        if (
            self._peek() == "id"
            and self.pos + 1 < len(self.tokens)
            and self.tokens[self.pos + 1][0] == "="
        ):
            name = self.tokens[self.pos][1]
            self.pos += 2
            value = self._parse_expression()
            self.vars[name] = value  # type: ignore[assignment]
            return value
        return self._parse_additive()

    def _parse_additive(self) -> float:
        value = self._parse_multiplicative()
        while self._peek() in ("+", "-"):
            op = self._peek()
            self.pos += 1
            rhs = self._parse_multiplicative()
            value = value + rhs if op == "+" else value - rhs
        return value

    def _parse_multiplicative(self) -> float:
        value = self._parse_factor()
        while self._peek() in ("*", "/", "%"):
            op = self._peek()
            self.pos += 1
            rhs = self._parse_factor()
            if op == "*":
                value = value * rhs
            elif op == "/":
                value = value / rhs
            else:
                value = value % rhs
        return value

    def _parse_factor(self) -> float:
        if self._peek() == "-":
            self.pos += 1
            return -self._parse_factor()
        if self._peek() == "+":
            self.pos += 1
            return self._parse_factor()
        tok = self.tokens[self.pos]
        if tok[0] == "num":
            self.pos += 1
            return tok[1]  # type: ignore[return-value]
        if tok[0] == "id":
            name = tok[1]
            self.pos += 1
            if name not in self.vars:
                raise Exception(
                    f"Invalid identifier. No variable with name '{name}' was found."
                )
            return self.vars[name]
        if tok[0] == "(":
            self.pos += 1
            value = self._parse_additive()
            self.pos += 1  # consume ')'
            return value
        raise Exception("Invalid input")
