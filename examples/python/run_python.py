#!/usr/bin/env python3
"""
Runner script for the Python controller example.

This script handles the Python path setup and runs the main example.
"""

import sys
import os
from pathlib import Path

def main():
    # Get the project structure
    script_dir = Path(__file__).parent
    project_root = script_dir.parent.parent
    bindings_py_dir = project_root / "bindings" / "py"
    
    # Add the bindings directory to Python path
    sys.path.insert(0, str(bindings_py_dir))
    
    # Check if the library exists
    library_path = project_root / "target" / "release" / "libcontroller_c.dylib"
    if not library_path.exists():
        print("❌ Library not found. Please run the build script first:")
        print("   ./scripts/build.sh")
        return 1
    
    # Set the library path for dynamic loading
    os.environ["DYLD_LIBRARY_PATH"] = str(library_path.parent) + ":" + os.environ.get("DYLD_LIBRARY_PATH", "")
    
    # Import and run the main example
    try:
        # Import the example module
        example_path = script_dir / "test_controller.py"
        spec = importlib.util.spec_from_file_location("test_controller", example_path)
        test_controller = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(test_controller)
        
        # Run the main function
        return test_controller.main()
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        print("\nTroubleshooting:")
        print("1. Make sure the build script has been run: ./scripts/build.sh")
        print("2. Check if the nanobind bindings are built correctly")
        print("3. Try running setup_python.py first")
        return 1
    except Exception as e:
        print(f"❌ Error running example: {e}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    import importlib.util
    sys.exit(main())
