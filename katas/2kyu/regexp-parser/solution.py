"""Regular expression parser — build an AST from a regex string.

Grammar (precedence high → low):
    expr   := sequence ('|' sequence)?        # Or, non-associative
    sequence := star*                         # concatenation
    star   := atom '*'*                       # ZeroOrMore
    atom   := Normal | Any | '(' expr ')'

Or is non-associative: only one '|' at the top level of an expression.
Returns None for invalid regexps.
"""

from preloaded import Any, Normal, Or, Str, ZeroOrMore


def parse_regexp(indata):
    if not indata:
        return None

    pos = 0

    def peek():
        return indata[pos] if pos < len(indata) else None

    def parse_expr():
        nonlocal pos
        left = parse_sequence()
        if left is None:
            return None
        if peek() == "|":
            pos += 1
            right = parse_sequence()
            if right is None:
                return None
            if peek() == "|":  # a|b|c — non-associative, invalid
                return None
            return Or(left, right)
        return left

    def parse_sequence():
        nonlocal pos
        items = []
        while True:
            c = peek()
            if c is None or c in ")|":
                break
            node = parse_star()
            if node is None:
                return None
            items.append(node)
        if not items:
            return None
        if len(items) == 1:
            return items[0]
        return Str(items)

    def parse_star():
        nonlocal pos
        atom = parse_atom()
        if atom is None:
            return None
        if peek() == "*":
            pos += 1
            atom = ZeroOrMore(atom)
            if peek() == "*":  # a** — invalid, only one star allowed
                return None
        return atom

    def parse_atom():
        nonlocal pos
        c = peek()
        if c is None:
            return None
        if c == "(":
            pos += 1
            inner = parse_expr()
            if inner is None or peek() != ")":
                return None
            pos += 1
            return inner
        if c == ")":
            return None
        if c == "|":
            return None
        if c == "*":
            return None
        if c == ".":
            pos += 1
            return Any()
        pos += 1
        return Normal(c)

    result = parse_expr()
    if result is None or pos != len(indata):
        return None
    return result
