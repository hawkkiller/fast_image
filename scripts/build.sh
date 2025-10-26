#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to the native directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NATIVE_DIR="$PROJECT_ROOT/native"

cd "$NATIVE_DIR"

echo -e "${GREEN}Building native libraries for all supported architectures...${NC}"

# Counter for success/failure
SUCCESS_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT=0

# Build function
build_for_target() {
    local target=$1
    local description=$2
    
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    
    echo -e "${YELLOW}Building for $description (target: $target)${NC}"
    
    # Add the target if not already added
    rustup target add "$target" 2>/dev/null || true
    
    if cargo build --release --target "$target"; then
        echo -e "${GREEN}✓ Successfully built for $description${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}✗ Failed to build for $description${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    echo ""
}

# Android builds
echo -e "${GREEN}=== Building Android libraries ===${NC}"
build_for_target "armv7-linux-androideabi" "Android ARM"
build_for_target "aarch64-linux-android" "Android ARM64"
build_for_target "i686-linux-android" "Android IA32"
# build_for_target "riscv64-linux-android" "Android RISC-V 64" wait until supported
build_for_target "x86_64-linux-android" "Android x64"

# iOS builds
echo -e "${GREEN}=== Building iOS libraries ===${NC}"
build_for_target "aarch64-apple-ios" "iOS ARM64 (Device)"
build_for_target "aarch64-apple-ios-sim" "iOS ARM64 (Simulator)"
build_for_target "x86_64-apple-ios" "iOS x64 (Simulator)"

# Linux builds
echo -e "${GREEN}=== Building Linux libraries ===${NC}"
build_for_target "armv7-unknown-linux-gnueabihf" "Linux ARM"
build_for_target "aarch64-unknown-linux-gnu" "Linux ARM64"
# build_for_target "i686-unknown-linux-gnu" "Linux IA32"
# build_for_target "riscv64gc-unknown-linux-gnu" "Linux RISC-V 64"
build_for_target "x86_64-unknown-linux-gnu" "Linux x64"

# macOS builds
echo -e "${GREEN}=== Building macOS libraries ===${NC}"
build_for_target "aarch64-apple-darwin" "macOS ARM64"
build_for_target "x86_64-apple-darwin" "macOS x64"

# Windows builds
echo -e "${GREEN}=== Building Windows libraries ===${NC}"
build_for_target "aarch64-pc-windows-msvc" "Windows ARM64"
# build_for_target "i686-pc-windows-msvc" "Windows IA32"
build_for_target "x86_64-pc-windows-msvc" "Windows x64"

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Build Summary:${NC}"
echo -e "Total builds: $TOTAL_COUNT"
echo -e "${GREEN}Successful: $SUCCESS_COUNT${NC}"
if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${RED}Failed: $FAIL_COUNT${NC}"
    exit 1
else
    echo -e "${GREEN}All builds completed successfully!${NC}"
fi
