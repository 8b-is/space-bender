import subprocess
from pathlib import Path


def test_cocoa_vbf_duty_cycle_gate_prolog():
    kata_dir = Path(__file__).parent
    res = subprocess.run(
        ["swipl", "-q", "-g", "run_tests", "-t", "halt", str(kata_dir / "test.pl")],
        capture_output=True,
        text=True,
        check=False,
    )
    assert res.returncode == 0, f"SWI-Prolog plunit failed:\nSTDOUT:\n{res.stdout}\nSTDERR:\n{res.stderr}"
