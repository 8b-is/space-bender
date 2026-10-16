"""Test-only shim mirroring the kata's preloaded AST node classes.

On Codewars these classes are provided by the platform (the `preloaded`
module); this file reproduces them locally so `solution.py` imports
unchanged. Node semantics: structural equality, deterministic repr.
"""


class Normal:
    """A single normal (literal) character."""

    def __init__(self, char):
        self.char = char

    def __eq__(self, other):
        return isinstance(other, Normal) and self.char == other.char

    def __repr__(self):
        return f"Normal({self.char!r})"


class Any:
    """`.` — any single character."""

    def __eq__(self, other):
        return isinstance(other, Any)

    def __repr__(self):
        return "Any()"


class ZeroOrMore:
    """`x*` — zero or more of the wrapped node."""

    def __init__(self, node):
        self.node = node

    def __eq__(self, other):
        return isinstance(other, ZeroOrMore) and self.node == other.node

    def __repr__(self):
        return f"ZeroOrMore({self.node!r})"


class Or:
    """`a|b` — alternation of two nodes."""

    def __init__(self, left, right):
        self.left = left
        self.right = right

    def __eq__(self, other):
        return (
            isinstance(other, Or)
            and self.left == other.left
            and self.right == other.right
        )

    def __repr__(self):
        return f"Or({self.left!r}, {self.right!r})"


class Str:
    """Concatenation of a sequence of nodes."""

    def __init__(self, items):
        self.items = list(items)

    def __eq__(self, other):
        return isinstance(other, Str) and self.items == other.items

    def __repr__(self):
        inner = ", ".join(repr(i) for i in self.items)
        return f"Str([{inner}])"
