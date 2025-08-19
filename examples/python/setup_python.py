#!/usr/bin/env python3
"""
Setup script to build and install the controller_c Python bindings using nanobind.

This script will:
1. Build the nanobind extension
2. Install it in development mode
3. Verify the installation
"""

import subprocess
import sys
import os
from pathlib import Path

def run_command(cmd, cwd=None):
    """Run a command and return the result."""
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"❌ Command failed with return code {result.returncode}")
        print(f"stdout: {result.stdout}")
        print(f"stderr: {result.stderr}")
        return False
    print(f"✅ Command succeeded")
    if result.stdout:
        print(f"Output: {result.stdout}")
    return True

def main():
    print("🔧 Setting up Controller Python bindings")
    print("=" * 50)
    
    # Get the project root directory
    script_dir = Path(__file__).parent
    project_root = script_dir.parent.parent
    bindings_py_dir = project_root / "bindings" / "py"
    
    print(f"📁 Project root: {project_root}")
    print(f"📁 Python bindings directory: {bindings_py_dir}")
    
    # Check if nanobind is installed
    print("\n📦 Checking for nanobind...")
    try:
        import nanobind
        print(f"✅ nanobind is installed: {nanobind.__version__}")
    except ImportError:
        print("❌ nanobind is not installed")
        print("Installing nanobind...")
        if not run_command([sys.executable, "-m", "pip", "install", "nanobind"]):
            return 1
    
    # Check if the bindings directory exists
    if not bindings_py_dir.exists():
        print(f"❌ Python bindings directory not found: {bindings_py_dir}")
        print("Make sure to run the build script first to generate bindings!")
        return 1
    
    # Create a simple setup.py for the nanobind extension
    setup_py_content = '''
import nanobind
from pybind11.setup_helpers import build_ext
from pathlib import Path

ext_modules = [
    nanobind.extension.Extension(
        "controller_c",
        [
            "controller_c_ext.cpp",
        ] + list(Path("sub_modules").glob("*.cpp")),
        include_dirs=[
            "include",
            nanobind.include_dir(),
        ],
        libraries=["controller_c"],
        library_dirs=["../../target/release"],
        language="c++",
        cxx_std=17,
    ),
]

if __name__ == "__main__":
    from setuptools import setup
    setup(
        name="controller_c",
        ext_modules=ext_modules,
        zip_safe=False,
    )
'''
    
    setup_py_path = bindings_py_dir / "setup.py"
    print(f"\n📝 Creating setup.py at {setup_py_path}")
    with open(setup_py_path, "w") as f:
        f.write(setup_py_content)
    
    # Build the extension
    print("\n🔨 Building the extension...")
    if not run_command([sys.executable, "setup.py", "build_ext", "--inplace"], cwd=bindings_py_dir):
        return 1
    
    # Test the import
    print("\n🧪 Testing the import...")
    sys.path.insert(0, str(bindings_py_dir))
    try:
        import controller_c
        print("✅ controller_c module imported successfully")
        
        # Test basic functionality
        print("🔍 Testing basic functionality...")
        version = controller_c.Version.LATEST
        print(f"✅ Version enum works: {version}")
        
        signer_type = controller_c.SignerType.Starknet
        print(f"✅ SignerType enum works: {signer_type}")
        
        print("🎉 Setup completed successfully!")
        print(f"\n📋 To use the bindings, add this to your Python path:")
        print(f"   sys.path.insert(0, '{bindings_py_dir}')")
        print(f"   import controller_c")
        
    except ImportError as e:
        print(f"❌ Failed to import controller_c: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
