FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    flex \
    bison \
    libssl-dev \
    libelf-dev \
    bc \
    cpio \
    qemu-system-x86 \
    gdb \
    vim \
    git \
    kmod \
    python3 \
    python3-pip \
    wget \
    curl \
    busybox-static \
    && rm -rf /var/lib/apt/lists/*

# Create a workspace directory
WORKDIR /home/hacker/workspace

# Set a helpful alias for kernel building
RUN echo "alias kbuild='make -j\$(nproc)'" >> /root/.bashrc

# Default command
CMD ["/bin/bash"]
