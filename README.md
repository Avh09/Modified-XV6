# xv6

  # Scheduling

  ## The process powerball [Lottery Based Scheduling]
  System call `settickets` - The system call sets the number of tickets for the calling process. By default, each process should get one ticket. If `settickets()` is called, the calling process can increase its chances of winning the CPU lottery by increasing the number of tickets it holds.

  This project implements a **preemptive lottery-based scheduling policy** for processes in an operating system. Each process is assigned a number of tickets, and the probability of being selected to run is proportional to the number of tickets it holds. Additionally, a fairness rule is enforced: if two processes have the same number of tickets, the process with the earlier arrival time gets priority.


- **Randomized Time Slice Allocation**: Each time slice is randomly assigned to a process based on the number of tickets it holds. The higher the number of tickets, the more CPU time the process receives.
- **Arrival Time Fairness**: If two processes have the same number of tickets, the process that arrived earlier gets priority.
- **Customizable Ticket Allocation**: Processes can change their ticket count using the `settickets(int number)` system call, which affects their chances of being selected by the scheduler.
- **Inherited Tickets**: A child process inherits the same number of tickets as its parent when it is created.


## MLFQ!

- **Queues**:
    - **Queue 0**: 1 timer tick (Highest priority)
    - **Queue 1**: 4 timer ticks
    - **Queue 2**: 8 timer ticks
    - **Queue 3**: 16 timer ticks (Lowest priority)
  
- **Priority Demotion**: If a process uses up its entire time slice in a given queue, it is moved to a lower priority queue.
- **Priority Boosting**: Every 48 timer ticks, all processes are moved to the highest priority queue (queue 0) to prevent starvation.
- **Round-Robin Scheduling**: Round-robin scheduling is used within the lowest priority queue (queue 3).

# System Calls

This document outlines the implementation of two new system calls in XV6: `getSysCount` and `sigalarm`.

## 1. Gotta Count 'Em All - `getSysCount`

The `getSysCount` system call allows users to count the number of times a specific system call is invoked by a process, including its children. The user program `syscount` facilitates this feature.

The command is executed in the following format:


- `<mask>`: An integer mask that specifies the system call to be counted. This is a single bit set to indicate which syscall to count (e.g., `1 << i`).
- `<command>`: Any valid command in XV6 that will run until it exits.
- `[args]`: Any additional arguments for the command.

## Wake Me Up When My Timer Ends - `sigalarm`

The `sigalarm` system call allows a process to set a timer that triggers a specified handler function after a defined number of CPU ticks. This is useful for compute-bound processes that want to limit CPU usage or perform periodic actions.

# Copy-On-Write (COW) 

## Overview

**Copy-On-Write (COW)** is an optimization technique used in memory management to efficiently manage process memory during a `fork()` system call. Instead of duplicating the entire address space of a process when it is forked, COW allows both the parent and child processes to share the same memory pages initially. The pages are marked as read-only, and only when one of the processes tries to modify a shared page will a copy be made.

## How It Works

1. **Forking a Process:**
   - When a process calls `fork()`, the operating system creates a new child process.
   - Instead of creating a full copy of the parent's memory, both the parent and child processes initially share the same memory pages.

2. **Read-Only Pages:**
   - The shared memory pages are marked as read-only.
   - This allows both processes to access and read the data in the pages without any immediate duplication.

3. **Copy-On-Write Trigger:**
   - When either the parent or the child attempts to modify a shared memory page, a **page-fault exception** is triggered.
   - The RISC-V CPU detects the write attempt on a read-only page and notifies the kernel.

4. **Page Duplication:**
   - The kernel intervenes when a page fault occurs.
   - It creates a duplicate of the page that is being written to, assigning it a new physical memory location.
   - The page is then marked as **read/write** for the process that caused the page fault, allowing it to modify the memory without affecting the other process.
   
5. **Continued Shared Memory:**
   - As long as neither process writes to the shared page, both processes continue using the same physical memory for reading, resulting in memory savings.
   - Only when one process modifies a page does a copy get made.

## Benefits of Copy-On-Write

- **Memory Efficiency:** COW reduces memory usage by sharing the same memory pages between parent and child processes until one of them modifies the data.
- **Performance Optimization:** Copying memory only when needed reduces the overhead of unnecessary memory copying during process creation.
- **Improved Scalability:** This technique is particularly useful in systems with many processes that fork frequently.

## Example Scenario

1. **Process Forking:**
   - Parent process `P` calls `fork()`, creating child process `C`.
   - Both processes share the same pages in memory, which are marked as read-only.
   
2. **Read Operation:**
   - Both `P` and `C` can read the shared pages without any issues, as the pages are read-only.
   
3. **Write Operation (Page-Fault Triggered):**
   - Process `P` tries to modify a shared page, causing a page-fault.
   - The kernel creates a copy of that page for `P` and marks it as read/write.
   
4. **Independent Memory:**
   - Now `P` has its own copy of the page, and modifications made by `P` will not affect `C`.
   - If `C` tries to modify the same page later, another page-fault will occur, and `C` will get its own copy of the page.

## Conclusion

Copy-On-Write is an essential technique for modern operating systems to optimize memory usage and performance, particularly in scenarios where many processes are forked and only a small portion of their memory is modified. By deferring the memory duplication until a write occurs, COW ensures that system resources are used efficiently.



