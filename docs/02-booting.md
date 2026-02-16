# Lesson 2: Booting Your Kernel

You have a `bzImage`, but how do you run it? We use **QEMU**, a powerful emulator that lets us run our kernel like a virtual machine.

## The Concept
To boot a kernel, you usually need two things:
1.  The **Kernel Image** (`bzImage`).
2.  A **Root Filesystem** (where `/bin`, `/etc`, and your files live).

Since we haven't built a full filesystem yet, we can boot the kernel and watch it start up until it panics because it can't find a "root" to mount.

---

## Exercise: The First Boot (and the First Panic)

### Step 1: Locate your bzImage
Ensure you are in the kernel source directory inside the lab:
```bash
ls arch/x86/boot/bzImage
```

### Step 2: Build a Filesystem
To "boot" properly, Linux needs a filesystem (like a hard drive). I've entered a helper script to build a small one using BusyBox.

**You must run this from inside the container:**
```bash
../lab/build_rootfs.sh
```
*(Or from your Mac using: `docker exec -it kernel-lab ../lab/build_rootfs.sh`)*

This creates `initramfs.cpio.gz` in your linux folder.

### Step 3: Run QEMU
Now boot with both the kernel AND the filesystem:
```bash
qemu-system-x86_64 \
    -kernel arch/x86/boot/bzImage \
    -initrd initramfs.cpio.gz \
    -nographic \
    -append "console=ttyS0"
```

### Step 4: Analyze the Output
You should see a wall of text as the kernel initializes its drivers (this is what `dmesg` shows). Eventually, it will stop with an error:
`Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)`

**Congratulations!** You just booted your first custom kernel. The "Panic" is expected because we didn't give it a home (a filesystem) to live in.

---

## The Challenge
Can you find the command line argument used to exit QEMU once it has paniced?
*Hint: Usually `Ctrl+A` followed by `X`.*

---

## What's Next?
Next, we will build a **Minimal Root Filesystem** using BusyBox so we can actually get a shell and run commands inside our custom kernel.
