#!/bin/bash
# This script is meant to be run INSIDE the lab container.

set -e

WORKSPACE_DIR="/home/hacker/workspace"
LINUX_DIR="$WORKSPACE_DIR/linux"

echo "--- Starting Kernel Build Automation ---"

if [ ! -d "$LINUX_DIR" ]; then
    echo "Error: Linux source directory not found at $LINUX_DIR"
    exit 1
fi

cd "$LINUX_DIR"

echo "1. Generating default x86_64 configuration..."
make x86_64_defconfig

echo "2. Starting compilation (this will take a while)..."
# We use -j$(nproc) to use all available CPU cores
make -j$(nproc)

echo "--- Build Complete! ---"
echo "Kernel image: $LINUX_DIR/arch/x86/boot/bzImage"
echo "Uncompressed image: $LINUX_DIR/vmlinux"
