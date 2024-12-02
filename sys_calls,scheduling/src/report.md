# XV6

# System Calls

## Gotta count ‘em all

Added user program `syscount` :
- masks the given number in the input
- Calls `getSysCount` system call

Added system call `getSysCount` :
- Returns the required system call's count for a particular process.
```c
uint64 sys_getSysCount(void){

  struct proc *p = myproc();
  int arg1;
  argint(0, &arg1);
  p->yo = arg1;
  if (p->yo == 1) {
        return p->forkcount;
    } else if (p->yo == 2) {
        return p->exitcount;
    } else if (p->yo == 3) {
        return p->waitcount;
    } else if (p->yo == 4) {
        return p->pipecount;
    } else if (p->yo == 5) {
        return p->readcount;
    } 
    .....
}
```

Changed `syscall` function:
- Added counters for every system call.


## Wake me up when my timer ends

Added `sigalarm` and `sigreturn` system calls.
```c
uint64 sys_sigalarm(void)
{
  uint64 addr;
  int ticks;

  argint(0, &ticks);
  argaddr(1, &addr);
  struct proc *p = myproc();
  p->ticks = ticks;
  p->handler = addr;
  return 0;
}

uint64 sys_sigreturn(void)
{
  struct proc *p = myproc();
  if (p->alarm_tf == 0)
    return -1; 
  memmove(p->trapframe, p->alarm_tf, sizeof(struct trapframe));

  kfree(p->alarm_tf);
  p->alarm_tf = 0;
  p->alarm_on = 0;
  p->cur_ticks = 0;
  usertrapret();
  return 0;
}
```



Made changes in the `usertrap` function
```c
else if ((which_dev = devintr()) != 0)
  {
    // ok

    if (which_dev == 2) 
    {
      p->cur_ticks++;
      if (p->cur_ticks >= p->ticks && p->ticks > 0)
      {
        if (p->alarm_on == 0)
        {
          p->alarm_on = 1;
          struct trapframe *tf = kalloc();
          if (tf == 0)
          {
            setkilled(p);
          }
          else
          {
            memmove(tf, p->trapframe, sizeof(*p->trapframe));
            p->alarm_tf = tf;
            p->trapframe->epc = p->handler;
          }
        }
        p->cur_ticks = 0;
      }
    }
  }
  ```

  # Scheduling

  ## The process powerball [LBS]
  System call `settickets` - The system call sets the number of tickets for the calling process. By default, each process should get one ticket. If `settickets()` is called, the calling process can increase its chances of winning the CPU lottery by increasing the number of tickets it holds.

  This project implements a **preemptive lottery-based scheduling policy** for processes in an operating system. Each process is assigned a number of tickets, and the probability of being selected to run is proportional to the number of tickets it holds. Additionally, a fairness rule is enforced: if two processes have the same number of tickets, the process with the earlier arrival time gets priority.


- **Randomized Time Slice Allocation**: Each time slice is randomly assigned to a process based on the number of tickets it holds. The higher the number of tickets, the more CPU time the process receives.
- **Arrival Time Fairness**: If two processes have the same number of tickets, the process that arrived earlier gets priority.
- **Customizable Ticket Allocation**: Processes can change their ticket count using the `settickets(int number)` system call, which affects their chances of being selected by the scheduler.
- **Inherited Tickets**: A child process inherits the same number of tickets as its parent when it is created.

### LBS Scheduler Implementation

- **Runnable Process Collection**: The code loops through all processes and checks if each process is in the RUNNABLE state. If a process is runnable, it is added to the runnable_procs[] array, and its tickets are added to total_tickets.

- **Total Ticket Calculation**: The sum of tickets for all runnable processes is calculated. This value represents the pool of tickets for the lottery.

- **Check for Runnable Processes**: If no processes are runnable (total_tickets == 0), the scheduler moves on to the next iteration.

- **Winning Ticket**: A random ticket is drawn from the range [0, total_tickets). The value of `winning_ticket` determines which process will run.

- **Cumulative Ticket Calculation**: The scheduler iterates over each runnable process, adding up their ticket counts (`current_ticket`). The process that pushes `current_ticket` beyond the `winning_ticket` is selected to run.

- **Tie-Breaking**: If two processes have the same number of tickets, the process with the earlier arrival time (`arrival_time`) is chosen. This ensures fairness when multiple processes have the same ticket count.

- **Default Selection**: If no process was selected in the ticket comparison step, the scheduler defaults to picking the first runnable process. It checks for the process with the earliest arrival time, ensuring fairness when no winning process is found.

- **Process State Transition**: If a process has been selected, the scheduler acquires its lock and changes its state to RUNNING.

- **Context Switch**: The context is switched from the scheduler to the selected process using `swtch()`. Once the process finishes execution or is preempted, control returns to the scheduler, and the context is switched back.



## MLF who? MLFQ!

- **Queues**:
    - **Queue 0**: 1 timer tick (Highest priority)
    - **Queue 1**: 4 timer ticks
    - **Queue 2**: 8 timer ticks
    - **Queue 3**: 16 timer ticks (Lowest priority)
  
- **Priority Demotion**: If a process uses up its entire time slice in a given queue, it is moved to a lower priority queue.
- **Priority Boosting**: Every 48 timer ticks, all processes are moved to the highest priority queue (queue 0) to prevent starvation.
- **Round-Robin Scheduling**: Round-robin scheduling is used within the lowest priority queue (queue 3).

### MLFQ Scheduler Implementation

The following is a detailed explanation of the Multi-Level Feedback Queue (MLFQ) scheduler implemented in the provided code. This MLFQ scheduler dynamically manages processes across different priority levels (queues) and applies a time-slice-based scheduling mechanism to ensure fair CPU sharing.


- **`pqno`**: The present queue number (priority level) of the process.
- **`start_time`**: The time when the process started.
- **`waiting_time`**: The total waiting time of the process before execution.
- **`cpu_ticks`**: The number of ticks (time slices) a process has received on the CPU.


1. **Queue Initialization and Selection**:
   The scheduler iterates over all available queues (from highest to lowest priority, i.e., `Queue 0` to `Queue 3`) to find a **runnable** process. It locks each process (`p`) and checks its state. If a runnable process is found, the queue number is saved, and the scheduler moves to the process selection step (`select_proc` label).

2. **Selecting a Process from the Highest Priority Queue**:
   Once a queue with runnable processes is identified, the scheduler picks a process from that queue. If the process is in **Queue 3** (the lowest priority queue), it is handled with **round-robin scheduling**



    *For processes in **Queue 0**, **Queue 1**, and **Queue 2**:*

- **CPU Time Slice and Process Demotion**:
  If a process in one of these queues uses its entire time slice (measured by the `cpu_ticks` counter), it is **demoted** to the next lower priority queue (i.e., from Queue 0 to Queue 1, or Queue 1 to Queue 2). If it doesn't use its full slice (e.g., because it blocks for I/O), it stays in the same queue.

3. **Process State Transitions**

- The process's state is set to **RUNNING** before being scheduled.
- A context switch (`swtch`) is performed to transfer control to the process.
- After running, the process's `cpu_ticks` is checked. If the process has exhausted its time slice, it is either **demoted** to a lower priority queue or its CPU time counter (`cpu_ticks`) is reset.

4. `waiting_time`, `start_time`, `cpu_ticks` are initialised as 0 in `allocproc` function of `proc.c` file.
5. In the `proc.c` file, inside the `update_time()` function, `waiting_time` of all processes is increased by 1.
6. Boosting of all processes is done in the `usertrap()` function of `trap.c` file.


## Results of `schedulertest` on the 3 scheduling algorithms:

- **Round Robin (Default)** - `Average rtime` : 10, `wtime`: 140
- **LBS** - `Average rtime` : 10, `wtime` : 120
- **MLFQ** - `Average rtime` 10: , `wtime` : 132


Images uploaded as well.


## Answers to questions:

1. **What is the implication of adding the arrival time in the lottery based scheduling policy?**
- By adding arrival time, the policy favors processes that have been waiting longer. If two processes have the same number of tickets, the process with the earlier arrival time will be selected. This ensures fairness by giving priority to processes that have been in the system longer, rather than only relying on the random lottery outcome.

2. **Are there any pitfalls to watch out for?**
- If arrival time is not managed correctly, long-running processes might take control over CPU time, leading to starvation for newer processes.

3. **What happens if all processes have the same number of tickets?**
- Decision will solely depend on the arrival time. Acts like FCFS.