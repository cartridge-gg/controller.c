cmake_minimum_required(VERSION 3.15)
project(controller_c)

# Find required packages
find_package(Python 3.8 COMPONENTS Interpreter Development.Module REQUIRED)
find_package(nanobind CONFIG REQUIRED)

# Get the project root directory
get_filename_component(PROJECT_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)
set(LIB_DIR "${PROJECT_ROOT}/target/release")

# Collect all source files
file(GLOB SOURCES 
    "${CMAKE_CURRENT_SOURCE_DIR}/controller_c_ext.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/sub_modules/*.cpp"
)

# Create the nanobind module
nanobind_add_module(controller_c ${SOURCES})

# Set include directories
target_include_directories(controller_c PRIVATE 
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

# Try to find and add robin_map headers if available
execute_process(
    COMMAND ${Python_EXECUTABLE} -c "import nanobind; from pathlib import Path; print(Path(nanobind.__file__).parent / 'ext' / 'robin_map' / 'include')"
    OUTPUT_VARIABLE ROBIN_MAP_INCLUDE_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)

if(EXISTS "${ROBIN_MAP_INCLUDE_DIR}")
    message(STATUS "Found robin_map headers: ${ROBIN_MAP_INCLUDE_DIR}")
    target_include_directories(controller_c PRIVATE "${ROBIN_MAP_INCLUDE_DIR}")
else()
    message(WARNING "robin_map headers not found, build may fail")
endif()

# Find the controller_c library
find_library(CONTROLLER_C_LIB 
    NAMES controller_c libcontroller_c
    PATHS "${LIB_DIR}"
    NO_DEFAULT_PATH
)

if(CONTROLLER_C_LIB)
    message(STATUS "Found controller_c library: ${CONTROLLER_C_LIB}")
    target_link_libraries(controller_c PRIVATE "${CONTROLLER_C_LIB}")
else()
    message(FATAL_ERROR "Could not find controller_c library in ${LIB_DIR}")
endif()

# Set C++ standard
target_compile_features(controller_c PRIVATE cxx_std_17)

# Platform-specific settings
if(APPLE)
    target_compile_options(controller_c PRIVATE 
        -stdlib=libc++
        -mmacosx-version-min=10.14
    )
    # Set RPATH for macOS
    set_target_properties(controller_c PROPERTIES
        INSTALL_RPATH "${LIB_DIR}"
        BUILD_WITH_INSTALL_RPATH TRUE
    )
endif()

# Install the module
install(TARGETS controller_c LIBRARY DESTINATION .)
