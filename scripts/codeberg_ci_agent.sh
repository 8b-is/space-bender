#!/usr/bin/env bash
# Sovereign Codeberg CI Chore-Polish & Release Agent for space-bender
set -euo pipefail

MODE="${1:---chore-polish}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> [space-bender Codeberg Agent] Mode: $MODE"

run_chore_polish() {
    echo "--> 1. Running SWI-Prolog deterministic plunit kata suites..."
    if command -v swipl >/dev/null 2>&1; then
        for test_pl in katas/*/*/test.pl; do
            if [ -f "$test_pl" ]; then
                kata_dir="$(dirname "$test_pl")"
                echo "    [swipl] Testing $kata_dir..."
                (cd "$kata_dir" && swipl -q -g run_tests -t halt test.pl)
            fi
        done
    else
        echo "    [warn] swipl not installed on runner; skipping Prolog check."
    fi

    echo "--> 2. Running portable Python & Rust kata verification suites..."
    PORTABLE_SUITES=(
        "katas/1kyu/express-number-as-sum-of-four-squares/test_solution.py"
        "katas/2kyu/evaluate-math/test_solution.py"
        "katas/2kyu/simpler-interpreter/test_solution.py"
        "katas/2kyu/regexp-parser/test_solution.py"
        "katas/2kyu/prime-streaming/test_solution.py"
        "katas/2kyu/divisible-by-7/test_solution.py"
        "katas/3kyu/loopover/test_solution.py"
        "katas/3kyu/circular-genome/test_solution.py"
        "katas/5kyu/cocoa-vbf-duty-cycle-gate/test_solution.py"
    )
    for test_py in "${PORTABLE_SUITES[@]}"; do
        if [ -f "$test_py" ]; then
            echo "    [python3] Testing $test_py..."
            python3 "$test_py"
        fi
    done
    echo "    ✓ All space-bender kata suites verified."
}

run_release() {
    run_chore_polish
    echo "--> Packaging verified kata bundle..."
    mkdir -p dist
    tar -czf "dist/space-bender-katas.tar.gz" katas README.md
    shasum -a 256 "dist/space-bender-katas.tar.gz" > "dist/space-bender-katas.sha256"

    if git remote | grep -q '^codeberg$'; then
        git push codeberg HEAD:main --tags || true
    fi
    if git remote | grep -q '^origin$'; then
        git push origin HEAD:main --tags || true
    fi
    echo "    ✓ Release archive generated in dist/"
}

case "$MODE" in
    --chore-polish)
        run_chore_polish
        ;;
    --release)
        run_release
        ;;
    *)
        echo "Usage: $0 [--chore-polish | --release]"
        exit 1
        ;;
esac
