#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────
#  Config
# ─────────────────────────────────────────────
BUILD_TYPE="Debug"
BUILD_DIR="build/debug"

if [[ "${1:-}" == "release" ]]; then
  BUILD_TYPE="Release"
  BUILD_DIR="build/release"
fi

echo "┌─────────────────────────────────────┐"
echo "│  Build type : $BUILD_TYPE"
echo "│  Output dir : $BUILD_DIR"
echo "└─────────────────────────────────────┘"

# ─────────────────────────────────────────────
#  Configure (only if not already configured)
# ─────────────────────────────────────────────
if [[ ! -f "$BUILD_DIR/CMakeCache.txt" ]]; then
  echo "[*] Configuring CMake..."
  cmake -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
else
  echo "[*] CMake already configured, skipping..."
fi

# ─────────────────────────────────────────────
#  Build (use all available cores)
# ─────────────────────────────────────────────
CORES=$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 1)
echo "[*] Building with $CORES core(s)..."
cmake --build "$BUILD_DIR" --parallel "$CORES"

echo ""
echo "[✓] Done! Binary is in: $BUILD_DIR/"