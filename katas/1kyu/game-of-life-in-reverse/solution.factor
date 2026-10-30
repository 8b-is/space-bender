USING: arrays hash-sets kernel locals math math.order sequences sets vectors ;
IN: reverse-life

:: transpose-grid ( grid -- grid' )
    grid length :> h
    grid first length :> w
    w <iota> [| c | h <iota> [| r | c r grid nth nth ] map ] map ;

:: weighted-diff ( grid -- d )
    grid length :> m
    0 m <iota> [| r |
        r grid nth sum r 2 * m 1 - - * +
    ] each ;

:: cell-valid? ( q target state cnt rem -- ? )
    q cnt nth :> c
    q rem nth :> r
    q state nth :> s
    q target nth 1 =
    [ c 3 <= [ c r + s + 3 >= ] [ f ] if ]
    [ c s + 3 < [ t ] [ c r + 3 > ] if ] if ;

:: all-valid? ( p ns target state cnt rem -- ? )
    p target state cnt rem cell-valid?
    [ ns [ target state cnt rem cell-valid? ] all? ]
    [ f ] if ;

:: frontier-key ( idx w state cnt -- key )
    idx w - 1 - :> base
    idx w 1 + <iota> [
        base + :> q
        4 shift
        q cnt nth 4 min 1 shift bitor
        q state nth bitor
    ] each ;

:: dfs ( idx k w target state cnt rem nbrs dead -- ? )
    idx k = [ t ] [
        idx w 1 + >= [ idx w state cnt frontier-key ] [ f ] if :> key
        key [ key dead ?adjoin not ] [ f ] if [ f ] [
            idx nbrs nth :> ns
            ns [| q | q rem [ 1 - ] change-nth ] each
            0 idx state set-nth
            idx ns target state cnt rem all-valid? [
                idx 1 + k w target state cnt rem nbrs dead dfs
            ] [ f ] if
            [ t ] [
                1 idx state set-nth
                ns [| q | q cnt [ 1 + ] change-nth ] each
                idx ns target state cnt rem all-valid? [
                    idx 1 + k w target state cnt rem nbrs dead dfs
                ] [ f ] if
                dup [
                    ns [| q |
                        q cnt [ 1 - ] change-nth
                        q rem [ 1 + ] change-nth
                    ] each
                    idx target nth idx state set-nth
                ] unless
            ] if
        ] if
    ] if ;

:: find-predecessor ( goal -- pred )
    goal first length goal length > :> trans?
    trans? [ goal transpose-grid ] [ goal ] if :> g1
    g1 weighted-diff 0 > :> flip?
    flip? [ g1 reverse ] [ g1 ] if :> g2
    g2 length :> m
    g2 first length :> n
    m 2 + :> h
    n 2 + :> w
    h w * :> k
    k 0 <array> :> target
    m <iota> [| r |
        n <iota> [| c |
            c r g2 nth nth
            r 1 + w * c + 1 + target set-nth
        ] each
    ] each
    k <iota> [| p |
        p w /mod :> ( r c )
        V{ } clone :> acc
        3 <iota> [| dr |
            3 <iota> [| dc |
                dr 1 - :> ddr
                dc 1 - :> ddc
                ddr 0 = ddc 0 = and [
                    r ddr + :> nr
                    c ddc + :> nc
                    nr 0 >= nr h < and nc 0 >= and nc w < and [
                        nr w * nc + acc push
                    ] when
                ] unless
            ] each
        ] each
        acc >array
    ] map :> nbrs
    target clone :> state
    k 0 <array> :> cnt
    nbrs [ length ] map >array :> rem
    HS{ } clone :> dead
    0 k w target state cnt rem nbrs dead dfs [
        h <iota> [| r |
            w <iota> [| c | r w * c + state nth ] map
        ] map
        flip? [ reverse ] when
        trans? [ transpose-grid ] when
    ] [ f ] if ;
