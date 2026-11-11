import subprocess
import tempfile
import os

def test_idris_solution():
    """Test the Idris solution by verifying structure."""
    solution_path = os.path.join(os.path.dirname(__file__), "Modulo.idr")
    
    assert os.path.exists(solution_path), "Modulo.idr not found"
    
    with open(solution_path, 'r') as f:
        content = f.read()
    
    # Verify required functions exist (with explicit {k : Nat} syntax)
    assert "add : {k : Nat} -> Fin k -> Fin k -> Fin k" in content
    assert "negate : {k : Nat} -> Fin k -> Fin k" in content
    assert "subt : {k : Nat} -> Fin k -> Fin k -> Fin k" in content
    assert "mult : {k : Nat} -> Fin k -> Fin k -> Fin k" in content
    
    # Verify implementations use addImpl, negateImpl, etc.
    assert "addImpl" in content
    assert "negateImpl" in content
    assert "subtImpl" in content
    assert "multImpl" in content
    
    print("Solution structure verified successfully")

if __name__ == "__main__":
    test_idris_solution()
    print("All tests passed!")
