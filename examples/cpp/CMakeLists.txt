cmake_minimum_required(VERSION 3.20)
project(controller_cpp_test)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add the test executable
add_executable(controller_test
    controller_test.cpp
    ../../bindings/cpp/controller.cpp
)

# Include directories
target_include_directories(controller_test PRIVATE
    ../../bindings/cpp
)

# Link against the controller library
if(APPLE)
    target_link_libraries(controller_test
        ${CMAKE_SOURCE_DIR}/../../target/release/libcontroller_uniffi.dylib
    )
    # Set rpath for macOS
    set_target_properties(controller_test PROPERTIES
        BUILD_RPATH "${CMAKE_SOURCE_DIR}/../../target/release"
        INSTALL_RPATH "${CMAKE_SOURCE_DIR}/../../target/release"
    )
elseif(UNIX)
    target_link_libraries(controller_test
        ${CMAKE_SOURCE_DIR}/../../target/release/libcontroller_uniffi.so
    )
    # Set rpath for Linux
    set_target_properties(controller_test PROPERTIES
        BUILD_RPATH "${CMAKE_SOURCE_DIR}/../../target/release"
        INSTALL_RPATH "${CMAKE_SOURCE_DIR}/../../target/release"
    )
elseif(WIN32)
    target_link_libraries(controller_test
        ${CMAKE_SOURCE_DIR}/../../target/release/controller_uniffi.dll
    )
endif()

