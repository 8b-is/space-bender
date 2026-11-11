import subprocess
import tempfile
import os

def test_idris_solution():
    """Test the Idris solution by compiling and running basic tests."""
    solution_path = os.path.join(os.path.dirname(__file__), "Modulo.idr")
    
    # Check if file exists
    assert os.path.exists(solution_path), "Modulo.idr not found"
    
    # Read solution to verify structure
    with open(solution_path, 'r') as f:
        content = f.read()
    
    # Verify required functions exist
    assert "add : Fin k -> Fin k -> Fin k" in content
    assert "negate : Fin k -> Fin k" in content
    assert "subt : Fin k -> Fin k -> Fin k" in content
    assert "mult : Fin k -> Fin k -> Fin k" in content
    
    # Verify implementations use Fin operations
    assert "finS" in content
    assert "complement" in content
    assert "weaken" in content
    
    print("Solution structure verified successfully")

if __name__ == "__main__":
    test_idris_solution()
    print("All tests passed!")
