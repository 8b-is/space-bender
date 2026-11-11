import subprocess
import tempfile
import os

def test_idris_solution():
    """Test the Idris solution by verifying structure."""
    solution_path = os.path.join(os.path.dirname(__file__), "Modulo.idr")
    
    assert os.path.exists(solution_path), "Modulo.idr not found"
    
    with open(solution_path, 'r') as f:
        content = f.read()
    
    # Verify required functions exist
    assert "add : Fin k -> Fin k -> Fin k" in content
    assert "negate : Fin k -> Fin k" in content
    assert "subt : Fin k -> Fin k -> Fin k" in content
    assert "mult : Fin k -> Fin k -> Fin k" in content
    
    # Verify no finS (not in Idris 1.3)
    assert "finS" not in content
    
    print("Solution structure verified successfully")

if __name__ == "__main__":
    test_idris_solution()
    print("All tests passed!")
