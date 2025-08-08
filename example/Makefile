# Makefile for Controller C/C++ Examples

# Compiler settings
CC = clang
CXX = clang++
CFLAGS = -Wall -Wextra -O2 -std=c99
CXXFLAGS = -Wall -Wextra -O2 -std=c++17

# Platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    LIB_PATH = ../target/release/libcontroller_c.so
    LDFLAGS = -L../target/release -lcontroller_c -Wl,-rpath,../target/release
endif
ifeq ($(UNAME_S),Darwin)
    LIB_PATH = ../target/release/libcontroller_c.dylib
    LDFLAGS = -L../target/release -lcontroller_c
endif

# Targets
all: example_c example_cpp

example_c: main.c $(LIB_PATH)
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

example_cpp: main.cpp $(LIB_PATH)
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDFLAGS)

$(LIB_PATH):
	@echo "Building Rust library..."
	cd .. && cargo build --release

run_c: example_c
	./example_c

run_cpp: example_cpp
	./example_cpp

clean:
	rm -f example_c example_cpp

.PHONY: all clean run_c run_cpp