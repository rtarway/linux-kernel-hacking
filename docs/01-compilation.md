# Lesson 1: Compiling the Kernel

Now that you're inside the lab, it's time to transform the source code into a bootable binary.

## The Concept
Kernel compilation is about turning the C code and assembly in `linux/` into a machine-executable image called a `bzImage`. This process is controlled by a `.config` file.

---

## Exercise: Your First Build

### Step 1: Navigate to the Source
Inside the lab container:
```bash
cd /home/hacker/workspace/linux
```

### Step 2: The Default Configuration
The kernel has thousands of options. Instead of choosing them one by one, we'll use a "defconfig" (generic default).
```bash
make x86_64_defconfig
```
> [!NOTE]
> This creates a `.config` file in the root of the kernel directory. You can inspect it with `cat .config` if you're curious!

### Step 3: Start the Engines
Now, kick off the compilation. We use `-j$(nproc)` to use all your CPU cores.
```bash
make -j$(nproc)
```

### Step 4: Wait for the Magic
This will take anywhere from 5 to 30 minutes depending on your Mac's speed. Look out for the final lines:
```text
Kernel: arch/x86/boot/bzImage is ready  (#1)
```

---

## The Challenge
While it builds, try to find where the kernel stores the source code for the "System Call" table. 
*Hint: Look in `arch/x86/entry/syscalls/`.*

Once the build is done, you've successfully created your own custom Linux kernel binary!

---

## Resuming Your Work (If things crash)
If your computer crashes, you close the terminal, or you just take a break, don't worry! Your work is saved inside the Docker container.

### Option 1: The Easy Way
Just run the lab script again. It is now smart enough to find your existing container and put you back inside:
```bash
./lab/run_lab.sh
```

### Option 2: The Manual Way
If you want to do it manually, here is how to check what's happening:

1.  **Check the status**:
    ```bash
    docker ps -a | grep kernel-lab
    ```
    - If it says `Up`, it's running.
    - If it says `Exited`, it's stopped.

2.  **If it's Stopped**: Start it.
    ```bash
    docker start -ai kernel-lab
    ```

3.  **If it's Running**: Jump inside.
    ```bash
    docker exec -it kernel-lab bash
    ```


### Troubleshooting: "I can't find bzImage!"
If you look for `bzImage` and it's not there, it means the compilation didn't finish (maybe it crashed or you stopped it).

**To fix this:**
1.  Make sure you are inside the container (`./lab/run_lab.sh`).
2.  Just run the make command again:
    ```bash
    make -j$(nproc)
    ```
    *Note: `make` is smart! It will pick up exactly where it left off, so you won't have to wait for the whole thing again.*


### Troubleshooting: "No rule to make target ... xt_TCPMSS.o"
If you see an error like `No rule to make target 'net/netfilter/xt_TCPMSS.o'`, it's because you are on a Mac!
Mac file systems are usually "case-insensitive", meaning `TCPMSS` and `tcpmss` look like the same file to the OS, confusing the build system.

**To fix this:**
1.  Open the `.config` file in the kernel root:
    ```bash
    nano .config
    ```
    *(Or use any editor you like)*
2.  Find the line `CONFIG_NETFILTER_XT_MATCH_TCPMSS=m`.
3.  Change it to:
    ```text
    # CONFIG_NETFILTER_XT_MATCH_TCPMSS is not set
    ```
4.  Save and exit.
5.  Run `make -j$(nproc)` again.


## What's Next?
In the next lesson, we will set up **QEMU** to actually boot this `bzImage` and see it run.
