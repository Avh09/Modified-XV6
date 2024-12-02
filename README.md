# xv6

  # Scheduling

  ## The process powerball [LBS]
  System call `settickets` - The system call sets the number of tickets for the calling process. By default, each process should get one ticket. If `settickets()` is called, the calling process can increase its chances of winning the CPU lottery by increasing the number of tickets it holds.

  This project implements a **preemptive lottery-based scheduling policy** for processes in an operating system. Each process is assigned a number of tickets, and the probability of being selected to run is proportional to the number of tickets it holds. Additionally, a fairness rule is enforced: if two processes have the same number of tickets, the process with the earlier arrival time gets priority.


- **Randomized Time Slice Allocation**: Each time slice is randomly assigned to a process based on the number of tickets it holds. The higher the number of tickets, the more CPU time the process receives.
- **Arrival Time Fairness**: If two processes have the same number of tickets, the process that arrived earlier gets priority.
- **Customizable Ticket Allocation**: Processes can change their ticket count using the `settickets(int number)` system call, which affects their chances of being selected by the scheduler.
- **Inherited Tickets**: A child process inherits the same number of tickets as its parent when it is created.


## MLF who? MLFQ!

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


