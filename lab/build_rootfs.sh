#!/bin/bash

# Lab Helper: Build a minimal Root Filesystem (initramfs)
# This allows us to boot the kernel and get a shell!

set -e

# Prevent running on Mac (Darwin) because we download Linux binaries
if [ "$(uname -s)" = "Darwin" ]; then
    echo "Error: This script downloads Linux binaries and cannot run on macOS."
    echo "Please run it inside the Docker container:"
    echo "  docker exec -it kernel-lab ../lab/build_rootfs.sh"
    exit 1
fi

WORK_DIR="rootfs"
INITRAMFS_FILE="../initramfs.cpio.gz"

echo "=== Building Minimal Root Filesystem ==="

# 1. Cleanup previous build
# This is crucial to remove old symlinks that might be absolute paths!
rm -rf $WORK_DIR

# 2. Create directory structure
mkdir -p $WORK_DIR/{bin,dev,etc,home,mnt,proc,sys,usr,tmp}
mkdir -p $WORK_DIR/usr/bin
mkdir -p $WORK_DIR/usr/sbin
cd $WORK_DIR

# 2. Install BusyBox
# We use the static binary installed in the container (busybox-static package)
if [ ! -f bin/busybox ]; then
    echo "Copying BusyBox from container..."
    cp /usr/bin/busybox bin/busybox
    chmod +x bin/busybox
fi

# 3. Create symlinks
echo "Installing BusyBox symlinks..."
cd bin
./busybox --install -s .
cd ..

# 3.5 Copy Kernel Modules (if they exist)
if [ -f ../../src/hello-hacker/hello.ko ]; then
    echo "Copying hello.ko to /home/..."
    cp ../../src/hello-hacker/hello.ko home/
fi

# 4. Create the 'init' script
cat > init <<EOF
#!/bin/busybox sh

# Set PATH
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

# Mount essential filesystems
/bin/busybox mount -t proc none /proc
/bin/busybox mount -t sysfs none /sys
/bin/busybox mount -t devtmpfs none /dev

# Welcome message
echo
echo "========================================"
echo "   Welcome to your Custom Kernel Lab!   "
echo "========================================"
echo
echo "HINT: Type 'ls' to see files."
echo "      Type 'exit' to halt the VM."
echo

# Drop to a shell
exec /bin/busybox sh
EOF

chmod +x init



chmod +x init
echo "Compressing into $INITRAMFS_FILE..."
find . -print0 | cpio --null -ov --format=newc 2>/dev/null | gzip -9 > $INITRAMFS_FILE

cd ..
echo "Done! Root filesystem created at $(pwd)/initramfs.cpio.gz"
