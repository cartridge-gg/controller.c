from pathlib import Path
from setuptools import setup, Extension
import nanobind
import platform
import os

# Get project root and library directory
project_root = Path(__file__).parent.parent.parent
lib_dir = project_root / "target" / "release"

# Source files
sources = ["controller_c_ext.cpp"] + list(Path("sub_modules").glob("*.cpp"))
sources = [str(s) for s in sources]

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
