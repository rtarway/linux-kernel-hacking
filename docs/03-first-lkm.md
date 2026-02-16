# Lesson 3: Your First Kernel Module (LKM)

Now for the fun part: running your own code inside the kernel. A **Loadable Kernel Module (LKM)** is a piece of code that can be loaded into the kernel at runtime without rebooting.

## The Concept
Unlike user programs that start at `main()`, kernel modules have:
- An **Initialization function**: Runs when the module is loaded (`insmod`).
- An **Exit function**: Runs when the module is removed (`rmmod`).

---

## Exercise: Hello, Hacker!

### Step 1: Create a workspace
Now that our lab setup is fixed, your host's `mygithubprojects/linux-kernel-hacking` folder is mounted to `/home/hacker/workspace`.

Inside the container:
```bash
mkdir -p /home/hacker/workspace/src/hello-hacker
cd /home/hacker/workspace/src/hello-hacker
```
*Note: You can also create these files on your Mac in `src/hello-hacker`!*

### Step 2: The Code (`hello.c`)
Create a file named `hello.c` with this content:

```c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

static int __init hello_init(void) {
    printk(KERN_INFO "Hello Hacker: You are now at Ring 0!\n");
    return 0; // 0 means success
}

static void __exit hello_exit(void) {
    printk(KERN_INFO "Goodbye Hacker: Leaving Ring 0.\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("rtarway");
MODULE_DESCRIPTION("A simple beginner hacker module");
```

### Step 3: The Makefile
Create a `Makefile` in the same directory:

```makefile
obj-m += hello.o

all:
	make -C /home/hacker/workspace/linux M=$(PWD) modules

clean:
	make -C /home/hacker/workspace/linux M=$(PWD) clean
```

### Step 4: Build and Load
1.  **Compile the module**:
    Run `make` inside the `src/hello-hacker` folder. This produces `hello.ko`.

2.  **Pack it into the filesystem**:
    Run the rootfs builder again to include your new module:
    ```bash
    ../lab/build_rootfs.sh
    ```

3.  **Boot QEMU**:
    Running `insmod` inside the Docker container won't work (wrong kernel!). You must boot your custom kernel using QEMU:
    ```bash
    qemu-system-x86_64 \
        -kernel /home/hacker/workspace/linux/arch/x86/boot/bzImage \
        -initrd /home/hacker/workspace/linux/initramfs.cpio.gz \
        -nographic \
        -append "console=ttyS0"
    ```

4.  **Load it**:
    Once inside QEMU (the prompt looks like `/ #`):
    ```bash
    insmod /home/hello.ko
    dmesg | tail
    ```
    You should see your "Hello Hacker" message!


---

## The Challenge
Change the message in `printk` to something else, rebuild, and reload. Observe how `dmesg` updates.

---

## What's Next?
Hacking isn't just about printing strings. Next, we'll learn about **Character Devices**—how to send data from a normal program to your kernel module!
