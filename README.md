# Linux Kernel Hacking Lab

A hands-on environment for learning Linux Kernel internals, module development, and boot process debugging.

## Features
- **BusyBox Rootfs**: Build a minimal Linux system from scratch.
- **QEMU Emulation**: Run your custom kernel safely.
- **Kernel Modules**: Learn to write and debug `.ko` drivers.

## Getting Started
1.  Clone this repository (recursive for submodules):
    ```bash
    git clone --recursive https://github.com/rtarway/linux-kernel-hacking.git
    ```
2.  Enter the lab environment:
    ```bash
    ./lab/run_lab.sh
    docker exec -it kernel-lab bash
    ```
3.  Follow the docs in `docs/`.
