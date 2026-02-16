# Lesson 0: Setting Up Your Hacking Lab

Before you can hack the kernel, you need a safe environment where you can crash things without breaking your Mac. We will use Docker to create a Linux-based "Hacker Box".

## Your Tools
Inside your [lab/](file:///Users/rtarway/mygithubprojects/linux-kernel-hacking/lab) folder, I've provided:
1.  **Dockerfile**: Defines the Linux environment with all the build tools (`make`, `gcc`, etc.) and tools for booting kernels (`qemu`).
2.  **run_lab.sh**: A script to build and launch this environment.

---

## Exercise: Launch the Lab

### Step 1: Open your Terminal
Navigate to the lab directory:
```bash
cd ~/mygithubprojects/linux-kernel-hacking/lab
```

### Step 2: Run the Lab Script
Execute the script I wrote for you. This script will build the environment if it doesn't exist, or **resume your session** if you've already started.
```bash
./run_lab.sh
```

### Step 3: Verify the Environment
Once inside the container (you should see a `root@...` prompt), check if you can see the kernel source:
```bash
ls /home/hacker/workspace/linux
```
Also, check that the compiler is ready:
```bash
gcc --version
```

---

## What's Next?
Once you are inside the container and have verified the files are there, you are ready for **Lesson 1: The Build**.
