
# CS3500: Operating Systems - xv6 Kernel Modifications

This repository contains my solutions and implementations for the CS3500 Operating Systems course at the Indian Institute of Technology Madras[cite: 1]. The projects involve extending and optimizing **xv6-riscv**, a teaching operating system developed by MIT, by adding fundamental OS concepts and features.

## 🛠️ Environment and Setup
*   **Operating System:** xv6 (RISC-V architecture)[cite: 1, 2].
*   **Emulation:** QEMU.
*   **Environment:** Docker (`svkv/riscv-tools:v1.0`).

## 📂 Lab Overview

The repository is structured around various labs, each focusing on specific core operating system mechanisms:

| Lab | Focus Area | Key Implementations |
| :--- | :--- | :--- |
| **Lab 1** | Utilities | • Set up the Docker environment and cloned the `xv6-riscv` repository.<br>• Implemented and executed an assembly program (`HelloWorld.S`) inside the xv6 qemu environment. |
| **Lab 2** | System Calls & Backtrace | • **System Call Tracing:** Created a `trace` system call with a bitmask to monitor process kernel calls[cite: 1].<br>• **Kernel Backtrace:** Implemented a `backtrace` feature using the RISC-V frame pointer (`s0` register) to print function call chains for debugging[cite: 1]. |
| **Lab 3** | Memory Management | • **Page Table Exploration:** Developed `vmprint` to visualize hierarchical page table entries[cite: 2].<br>• **Optimization:** Sped up the `getpid()` syscall by sharing read-only memory regions between userspace and the kernel[cite: 2].<br>• **Page Access Detection:** Added the `pgaccess()` syscall to inspect RISC-V access bits and report accessed user pages[cite: 2]. |
| **Lab 4** | User Space Traps | • Implemented periodic user-level interrupt handlers[cite: 3].<br>• Added `sigalarm()` to trigger functions after specific CPU ticks and `sigreturn()` to correctly resume interrupted application state[cite: 3]. |
| **Lab 5** | Copy-On-Write (COW) | • Optimized `fork()` by allowing parent and child processes to share physical memory pages initially[cite: 4].<br>• Implemented page fault handlers to allocate new physical pages only upon write attempts, maintaining robust reference counts for memory pages[cite: 4]. |
| **Lab 6** | Network Drivers | • Developed a DMA-based network driver for QEMU's E1000 NIC emulation[cite: 5].<br>• Modified the network stack to interface with IP, UDP, and ARP protocols[cite: 5].<br>• Implemented `send()`, `recv()`, and `bind()` system calls for UDP packet handling in userspace[cite: 5]. |
| **Lab 7** | Memory-Mapped Files | • Implemented `mmap` and `munmap` system calls to map file data directly into process address space[cite: 6].<br>• Built lazy page table population via page fault handling[cite: 6].<br>• Managed Virtual Memory Areas (VMAs) and added support for shared memory mappings (`MAP_SHARED`) across processes[cite: 6]. |

## 🚀 Getting Started

1. **Prerequisites:** Ensure you have Docker installed on your host system.
2. **Pull Toolchain:** 
   ```bash
   docker pull svkv/riscv-tools:v1.0
