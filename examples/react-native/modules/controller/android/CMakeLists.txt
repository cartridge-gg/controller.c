cmake_minimum_required(VERSION 3.13)
project(controller)

set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_CXX_STANDARD 20)

# Find packages
find_package(ReactAndroid REQUIRED CONFIG)
find_package(fbjni REQUIRED CONFIG)

# Add the pre-built Rust library
add_library(controller_uniffi SHARED IMPORTED)
set_target_properties(controller_uniffi PROPERTIES
    IMPORTED_LOCATION ${CMAKE_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}/libcontroller_uniffi.so
)

# Define the shared library
add_library(${CMAKE_PROJECT_NAME} SHARED
    cpp-adapter.cpp
    ../cpp/controller.cpp
    ../cpp/generated/controller.cpp
)

# Include directories
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    ../cpp
    ../cpp/generated
    ../cpp/includes
)

# Link libraries
target_link_libraries(${CMAKE_PROJECT_NAME}
    controller_uniffi
    ReactAndroid::jsi
    ReactAndroid::turbomodulejsijni
    ReactAndroid::react_nativemodule_core
    android
    log
    fbjni::fbjni
)
