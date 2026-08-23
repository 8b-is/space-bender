"""Loopover (Codewars 3 kyu) — sliding puzzle solver.

A grid of unique tiles; moves rotate a row (R/L) or column (U/D) with
wrap-around. Returns a list of moves to transform mixed into solved, or
None for unsolvable configurations.

Strategy: transpose so the even dimension is the columns (parity-friendly),

then recursively fix the first misplaced cell with local 3-cycles
(swap_adj, three_slip) that never disturb already-solved cells.
"""


def transpose(board):
    return list(map(list, zip(*board)))


def trns_sol(sol):
    if sol is None:
        return None
    return [
        s.replace("U", "l")
        .replace("D", "r")
        .replace("R", "D")
        .replace("L", "U")
        .replace("r", "R")
        .replace("l", "L")
        for s in sol
    ]


def change(board, moves):
    b = [list(r) for r in board]
    for move in moves:
        d, i = move[0], int(move[1:])
        if d == "R":
            b[i] = [b[i][-1]] + b[i][:-1]
        elif d == "L":
            b[i] = b[i][1:] + [b[i][0]]
        elif d == "U":
            col = [b[r][i] for r in range(len(b))]
            col = col[1:] + [col[0]]
            for r in range(len(b)):
                b[r][i] = col[r]
        else:  # D
            col = [b[r][i] for r in range(len(b))]
            col = [col[-1]] + col[:-1]
            for r in range(len(b)):
                b[r][i] = col[r]
    return b


def final_swap(rows, columns):
    if columns == 2:
        return ["R" + str(rows - 1)]
    return (
        ["U" + str(columns - 1), "R" + str(rows - 1)]
        + ["U" + str(i) for i in range(1, columns - 1)]
        + ["R" + str(rows - 1)]
        + ["D" + str(i) for i in range(1, columns)]
        + ["L" + str(rows - 1)]
    ) * (columns - 1)


def swap_adj(coord):
    return [
        "U" + str(coord[1]),
        "U" + str(coord[1] + 1),
        "R" + str(coord[0] - 1),
        "D" + str(coord[1] + 1),
        "L" + str(coord[0] - 1),
        "L" + str(coord[0] - 1),
        "D" + str(coord[1]),
        "R" + str(coord[0] - 1),
    ]


def three_slip(coord):
    return (
        ["U" + str(coord[1]), "U" + str(coord[1] + 1), "U" + str(coord[1] + 2)]
        + ["R" + str(coord[0] - 1), "D" + str(coord[1] + 1), "D" + str(coord[1] + 2)]
        + ["L" + str(coord[0] - 1)] * 3
        + ["D" + str(coord[1])]
        + ["R" + str(coord[0] - 1)] * 2
        + swap_adj([coord[0], coord[1] + 1])
        + swap_adj(coord)
    )


def loopover(mixed_up_board, solved_board):
    if mixed_up_board == solved_board:
        return []
    my_board = [list(r) for r in mixed_up_board]
    rows = len(solved_board)
    columns = len(solved_board[0])

    # single-column board: only U/D moves rotate the column. Solvable iff
    # the column is a rotation of the solved column (always, by construction).
    if columns == 1:
        col = [my_board[i][0] for i in range(rows)]
        target = [solved_board[i][0] for i in range(rows)]
        # after k U0 moves, col becomes col[k:] + col[:k]
        for k in range(rows):
            if col[k:] + col[:k] == target:
                return ["U0"] * k if k else []
        return None

    # single-row board: only R/L moves rotate the row.
    if rows == 1:
        row = my_board[0]
        target = solved_board[0]
        # after k R0 moves, row becomes row[-k:] + row[:-k]
        for k in range(columns):
            if row[-k:] + row[:-k] == target:
                return ["R0"] * k if k else []
        return None

    # if there is an even dimension, let it be the columns.
    if columns % 2 != 0 and rows % 2 == 0:
        return trns_sol(loopover(transpose(mixed_up_board), transpose(solved_board)))

    # find the first place that the cell is misplaced.
    row = 0
    column = 0
    while solved_board[row][column] == mixed_up_board[row][column]:
        if column < columns - 1:
            column += 1
        else:
            column = 0
            row += 1

    # find the misplaced cell.
    mixed_row = row
    mixed_column = column
    while solved_board[row][column] != mixed_up_board[mixed_row][mixed_column]:
        if mixed_column < columns - 1:
            mixed_column += 1
        else:
            mixed_column = 0
            mixed_row += 1

    # based on the positions decide what move to make or if unsolvable.
    if row == rows - 1 and column == columns - 2:
        if columns % 2 == 1:
            return None
        else:
            my_move = final_swap(rows, columns)
    elif row == mixed_row:
        if row != rows - 1:
            my_move = ["D" + str(mixed_column), "L" + str(mixed_row + 1), "U" + str(mixed_column)]
        elif column == 0:
            my_move = ["L" + str(mixed_row)] * mixed_column
        else:
            my_move = three_slip([row, max(column, mixed_column - 2)])
    elif column == mixed_column:
        my_move = ["R" + str(mixed_row)]
    else:
        my_move = (
            ["D" + str(column)] * (mixed_row - row)
            + ["R" + str(mixed_row) if mixed_column < column else "L" + str(mixed_row)] * abs(mixed_column - column)
            + ["U" + str(column)] * (mixed_row - row)
        )

    my_board = change(my_board, my_move)
    rest_of_solution = loopover(my_board, solved_board)
    return my_move + rest_of_solution if rest_of_solution is not None else None
