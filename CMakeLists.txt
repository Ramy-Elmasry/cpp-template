cmake_minimum_required(VERSION 3.20)
project(MyProject CXX)

if(NOT CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  message(FATAL_ERROR "This project requires Clang. Got: ${CMAKE_CXX_COMPILER_ID}. "
                       "Configure with -DCMAKE_CXX_COMPILER=clang++")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ─────────────────────────────────────────────
#  Default to Debug if nothing is specified
# ─────────────────────────────────────────────
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type (Debug|Release)" FORCE)
endif()
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release")

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

# ─────────────────────────────────────────────
#  Source files — edit this list
# ─────────────────────────────────────────────
add_executable(${PROJECT_NAME}
  src/main.cpp
  src/util.cpp
)

# ─────────────────────────────────────────────
#  Include directories
# ─────────────────────────────────────────────
target_include_directories(${PROJECT_NAME} PRIVATE
  ${CMAKE_SOURCE_DIR}/include
)

# ─────────────────────────────────────────────
#  Flags shared by BOTH Debug and Release
# ─────────────────────────────────────────────
target_compile_options(${PROJECT_NAME} PRIVATE
  -Wall
  -Wextra
  -Wpedantic
  -Wshadow
  -Wformat=2
  -Wconversion
  -Wsign-conversion
  -Wnull-dereference
  -Wdouble-promotion
  -Wcast-align
  -Wstrict-overflow=4

  # Harden stack and heap
  -fstack-protector-strong
  -fstack-clash-protection

  # No undefined/uninitialized behavior
  -ftrivial-auto-var-init=zero
)

target_compile_definitions(${PROJECT_NAME} PRIVATE
  _FORTIFY_SOURCE=2       # libc buffer overflow detection
)

target_link_options(${PROJECT_NAME} PRIVATE
  -Wl,-z,relro            # Read-only relocations
  -Wl,-z,now              # Full RELRO (resolve all symbols at load)
  -Wl,-z,noexecstack      # Non-executable stack
)

# ─────────────────────────────────────────────
#  DEBUG — sanitizers + full debug info
# ─────────────────────────────────────────────
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  target_compile_options(${PROJECT_NAME} PRIVATE
    -g3                         # Maximum debug info
    -Og                         # No optimization (accurate backtraces)
    -Werror                     # Treat all warnings as errors
    -fsanitize=address          # Heap/stack overflows, use-after-free
    -fsanitize=undefined        # UB: overflow, null deref, misaligned ptr
    -fsanitize=leak             # Memory leak detection
    -fno-omit-frame-pointer     # Better stack traces under ASan
    -fno-optimize-sibling-calls # Accurate call stacks
  )
  target_link_options(${PROJECT_NAME} PRIVATE
    -fsanitize=address
    -fsanitize=undefined
    -fsanitize=leak
  )
  target_compile_definitions(${PROJECT_NAME} PRIVATE
    DEBUG=1
    _GLIBCXX_DEBUG           # STL bounds checking (vector::at, etc.)
    _GLIBCXX_DEBUG_PEDANTIC
  )

# ─────────────────────────────────────────────
#  RELEASE — optimized, hardened, no debug
# ─────────────────────────────────────────────
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
  target_compile_options(${PROJECT_NAME} PRIVATE
    -O2                     # Safe optimizations (prefer over -O3 for security)
    -DNDEBUG
    -fPIE                   # Position-independent executable (ASLR support)
    -fvisibility=hidden     # Hide symbols by default (reduces attack surface)
    -ffunction-sections     # Dead code elimination
    -fdata-sections
  )
  target_link_options(${PROJECT_NAME} PRIVATE
    -pie                    # Link as PIE for ASLR
    -Wl,--gc-sections       # Strip unused code at link time
    -Wl,--strip-all         # Strip debug symbols from binary
  )
  target_compile_definitions(${PROJECT_NAME} PRIVATE
    NDEBUG=1
  )

else()
  message(FATAL_ERROR
    "Unsupported CMAKE_BUILD_TYPE: '${CMAKE_BUILD_TYPE}'. "
    "Only 'Debug' and 'Release' are supported by this project.")
endif()

# ─────────────────────────────────────────────
#  if clang-tidy is installed run a Static analysis check
# ─────────────────────────────────────────────

find_program(CLANG_TIDY_EXE NAMES "clang-tidy")

if(CLANG_TIDY_EXE)
    set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE};-checks=-*,bugprone-*,modernize-*,readability-*;--warnings-as-errors=*")
    message(STATUS "clang-tidy found: ${CLANG_TIDY_EXE}")
else()
    message(WARNING "clang-tidy not found! Static analysis will be skipped.")
endif()
