#!/bin/bash

# Simple test script to debug the build process

set -e

echo "🔧 Testing Controller Python Build"
echo "=================================="

# Check if library exists
echo "📁 Checking for Rust library..."
if [[ -f "target/release/libcontroller_c.dylib" ]]; then
    echo "✅ Found libcontroller_c.dylib"
    ls -la target/release/libcontroller_c.dylib
else
    echo "❌ libcontroller_c.dylib not found, building..."
    ./scripts/build.sh
fi

# Check bindings
echo "📁 Checking Python bindings..."
if [[ -d "bindings/py" ]]; then
    echo "✅ Found Python bindings directory"
    ls bindings/py/
else
    echo "❌ Python bindings not found"
    exit 1
fi

# Try simple build
echo "🔧 Testing simple Python build..."
cd bindings/py

# Create test venv
python3 -m venv test_venv
source test_venv/bin/activate

# Install dependencies
pip install nanobind setuptools wheel

# Create simple setup.py
cat > simple_setup.py << 'EOF'
from pathlib import Path
from setuptools import setup, Extension
import nanobind
import platform

# Get project root and library directory
project_root = Path(__file__).parent.parent.parent
lib_dir = project_root / "target" / "release"

print(f"Project root: {project_root}")
print(f"Library dir: {lib_dir}")
print(f"Library exists: {(lib_dir / 'libcontroller_c.dylib').exists()}")

# Source files
sources = ["controller_c_ext.cpp"] + list(Path("sub_modules").glob("*.cpp"))
sources = [str(s) for s in sources]
print(f"Found {len(sources)} source files")

# Compiler flags
extra_compile_args = ["-std=c++17"]
extra_link_args = []

if platform.system() == "Darwin":
    extra_compile_args.extend(["-stdlib=libc++", "-mmacosx-version-min=10.14"])
    extra_link_args.extend([f"-Wl,-rpath,{lib_dir}"])

# Create extension
ext = Extension(
    "controller_c",
    sources,
    include_dirs=["include", nanobind.include_dir()],
    libraries=["controller_c"],
    library_dirs=[str(lib_dir)],
    language="c++",
    extra_compile_args=extra_compile_args,
    extra_link_args=extra_link_args,
)

setup(
    name="controller_c",
    ext_modules=[ext],
    zip_safe=False,
    python_requires=">=3.8",
)
EOF

echo "🔨 Building extension..."
python3 simple_setup.py build_ext --inplace

echo "🧪 Testing import..."
python3 -c "import controller_c; print('✅ Success!')"

echo "🎉 Build test completed!"
