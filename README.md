# MyProject

A security-hardened C++17 project template utilizing modern CMake presets, LLVM sanitizers, and aggressive compiler hardening flags.

## 🚀 Features

* **C++17 Standard:** Strict adherence with extensions disabled.
* **Security Hardening:** * Stack canary protection (`-fstack-protector-all`).
    * Position Independent Executable (`-fPIE`) for ASLR support.
    * Full RELRO and non-executable stack linking.
    * Buffer overflow detection via `_FORTIFY_SOURCE`.
* **Quality Assurance:** * Aggressive warning levels (`-Wall`, `-Wextra`, `-Wpedantic`, etc.).
    * **Debug Mode:** Integrated Address (ASan), Undefined Behavior (UBSan), and Leak (LSan) sanitizers.
    * **Release Mode:** Dead code elimination and stripped symbols for a minimal attack surface.

## 🛠 Prerequisites

Ensure you have the following installed:
* **CMake** (v3.20+)
* **Ninja** (recommended) or Make
* **GCC/Clang** (with support for sanitizers)

## 🏗 Building the Project

This project uses **CMake Presets** to manage build configurations easily.

### 1. Configure
Choose a preset (`debug` or `release`):
```bash
cmake --preset debug
or
cmake --preset release

### 2. Build

cmake --build --preset debug
or
cmake --build --preset release