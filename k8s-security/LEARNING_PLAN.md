# K8s & Kernel Security: Learning by Doing

This plan is designed to bridge the gap between "Using K8s" and "Hacking K8s via the Kernel". We will build, break, and secure clusters by understanding the Linux primitives they rely on.

**Learning Methodology**: For every topic, follow this cycle:
1.  **READ**: Study the concepts and man pages.
2.  **DO**: execute the lab instructions.
3.  **ASK**: Question *why* it works (e.g., "Why did the PID change?").
4.  **RE-DO**: Try to replicate it from scratch without looking at the guide.

---

## Phase 0: Linux API Basics (The Foundation)
You cannot hack the Kernel if you don't speak its language. The "API" of the Kernel is the **System Call**.

### 0.1 The System Call (The Only Way In)
*   **READ**:
    *   `man 2 intro` (Introduction to System Calls)
    *   `man 2 syscalls` (List of all syscalls)
    *   Article: [The Definitive Guide to Linux System Calls](https://blog.packagecloud.io/the-definitive-guide-to-linux-system-calls/)
*   **DO**:
    *   Compile a "Hello World" in C.
    *   Run it with `strace ./hello`.
    *   Find the `write()` system call in the output.
    *   Modify the C program to use `syscall(SYS_write, ...)` directly, bypassing `printf`.
*   **ASK**: "Why does `printf` call `write`? Who handles the `write`?" (The Kernel).

### 0.2 File Descriptors (Everything is a File)
*   **READ**:
    *   `man 2 open`, `man 2 read`, `man 2 socket`
*   **DO**:
    *   Write a C program that opens a file, reads 10 bytes, and writes them to `stdout` (FD 1).
    *   Use `lsof -p <PID>` to see the open file descriptors of your running program.
    *   Redirect output: `./myprogram > output.txt`. Check who opened `output.txt` (Shell did it, then `dup2`'d it).
*   **ASK**: "What actually is a File Descriptor?" (An index in the kernel's process table).

### 0.3 Processes & Signals (Life & Death)
*   **READ**:
    *   `man 2 fork`, `man 2 execve`, `man 2 kill`
*   **DO**:
    *   Write a program that `fork()`s itself.
    *   Have the child print "Child" and the parent print "Parent".
    *   Kill the child from the terminal (`kill -9 <PID>`).
*   **ASK**: "When I run `ls`, does the shell `exec` ls? Or does it `fork` then `exec`?"

---

## Phase 1: The "Magic" of Containers (Kernel Primitives)
Before hacking K8s, we must hack the Linux features that *make* K8s possible.
**Concept**: A container is just a Linux process with restricted views (Namespaces) and restricted resources (Cgroups).

### 1.1 The Jailbreak (Manual Containers)
*   **READ**:
    *   `man 7 namespaces` (The Bible of Containerization)
    *   `man 8 unshare`
    *   Article: [Lizzie Dixon - Linux Containers in 500 lines of code](https://lizziedixon.com/2020/12/containers-in-500-lines-of-code)
*   **DO**:
    *   Create a clean Rootfs (using `alpine` tarball).
    *   Use `unshare --mount --uts --ipc --net --pid --fork` to create a shell.
    *   Manually mount `/proc` and separate parts of the filesystem.
*   **ASK**: "If I am root inside the container, am I root on the host?"
*   **RE-DO**: Write a script to spin upon your own "Alpine Container" in 1 second.

### 1.2 The Escape (Breaking Isolation)
*   **READ**:
    *   Article: [Understanding Docker Escapes](https://blog.trailofbits.com/2019/07/19/understanding-docker-container-escapes/)
    *   `man 2 chroot` (See the "Security" section warnings)
*   **DO**:
    *   Run a container with `--privileged`.
    *   Inside the container, mount the host disk (`mount /dev/sda1 /mnt`).
    *   Access the host's `/etc/shadow` or SSH keys.
    *   Break out of `chroot` using the `..` traversal trick in C.

---

## Phase 2: Linux Networking Deep Dive (The Pipes)
How does a packet get from Pod A to Pod B?
**Concept**: Pods are just processes in a Network Namespace, connected by virtual cables (`veth` pairs) to a virtual switch (`bridge`).

### 2.1 Building the Network Manually
*   **READ**:
    *   [Container Networking From Scratch](https://labs.iximiuz.com/tutorials/container-networking-from-scratch)
    *   `man 8 ip-link` (veth)
    *   `man 8 bridge`
*   **DO**:
    *   Create 2 network namespaces (`red` and `blue`).
    *   Link them with a Virtual Ethernet Pair (`veth`).
    *   Assign IPs and `ping` between them without Docker/K8s.
*   **ASK**: "How does the Kernel know where to send the packet?" (Routing Tables).

### 2.2 Tracing K8s Services (Netfilter/CNI)
*   **READ**:
    *   [A Guide to the Kubernetes Networking Model](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
    *   Rancher Desktop Docs: [How networking works in k3s/RD](https://docs.rancherdesktop.io/)
*   **DO**:
    *   Deploy a simple Nginx service in Rancher Desktop.
    *   Run `iptables-save | grep nginx` on the Node.
    *   Trace the `DNAT` rules that redirect Service IP -> Pod IP.
    *   Use `tcpdump -i any host <POD_IP>` to see the NAT happening.

---

## Phase 3: Attacking the Cluster (Kernel Exploitation)
How do hackers target the Node?
**Concept**: If you share the Kernel, you share the vulnerabilities.

### 3.1 Privileged Introspection
*   **READ**:
    *   [Bad Pods: Kubernetes Pod Privilege Escalation](https://research.nccgroup.com/2020/11/10/bad-pods-kubernetes-pod-privilege-escalation/)
*   **DO**:
    *   Deploy a malicious Pod with `hostPID: true` and `privileged: true`.
    *   Enter the Pod.
    *   Use `nsenter` to jump into the System Namespace (PID 1 of the host).
    *   Now you own the Node.

### 3.2 Kernel Module Injection
*   **READ**:
    *   `man 8 insmod`
    *   [Linux Kernel Module Programming Guide](https://sysprog21.github.io/lkmpg/)
*   **DO**:
    *   Use our `linux-kernel-hacking` lab to compile `malware.ko`.
    *   Try to load it from a Privileged Pod (`insmod malware.ko`).
    *   Observe it printing to the **Host's** `dmesg`.
    *   *Hardening Check*: Does it work on Rancher Desktop? (Usually RD runs in a VM, so you hack the VM, not your Mac).

---

## Phase 4: Hardening (Making it "Ultra Secure")
How do we stop Phase 3?

### 4.1 Seccomp & AppArmor
*   **READ**:
    *   [Restrict a Container's Syscalls with Seccomp](https://kubernetes.io/docs/tutorials/security/seccomp/)
    *   `man 2 seccomp`
*   **DO**:
    *   Write a Seccomp profile that DENIES `init_module` (loading drivers).
    *   Apply it to a Pod.
    *   Try to run the attack from Phase 3.2. It should fail with "Operation Not Permitted".

### 4.2 Pod Security Standards (PSS)
*   **READ**:
    *   [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
*   **DO**:
    *   Config Rancher Desktop to enforce "Restricted" mode on a specific Namespace.
    *   Try to deploy a `privileged` pod.
    *   Watch the API Server reject it.

---

## Prerequisites & Setup (Rancher Desktop Edition)
Since you are using **Rancher Desktop**:
1.  **Kubernetes Engine**: It uses `k3s` (lightweight K8s) inside a Linux VM (Lima on Mac).
2.  **Accessing the Node**:
    *   To "hack the node", you need to attach to the Rancher VM.
    *   Command: `rdctl shell` (opens a shell inside the Linux VM).
3.  **Kernel Version**:
    *   Check it: `rdctl shell uname -r`.
    *   It will be a standard Linux kernel, likely similar to what we build in class.

**Next Step**: Should we start **Phase 1.1** (Manual Container Jailbreak) inside the Rancher VM or our Docker Lab?
