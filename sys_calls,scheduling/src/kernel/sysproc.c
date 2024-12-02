#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
// #include "user/syscount.h"
// #include "global.h"

extern int sysnum;

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if (growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n)
  {
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_waitx(void)
{
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
  argaddr(1, &addr1); // user virtual memory
  argaddr(2, &addr2);
  int ret = waitx(addr, &wtime, &rtime);
  struct proc *p = myproc();
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    return -1;
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    return -1;
  return ret;
}

// uint64
// sys_getSysCount(void)
// {
//   int mask;
//   struct proc *p = myproc();

//   // retrieve the mask
//   argint(0, &mask);

//   // Check which bit is set in the mask
//   for (int i = 0; i < 23; i++) {
//     if (mask & (1 << i)) {
//       return p->syscall_count[i]; // return the count of that syscall
//     }
//   }

//   return -1;
// }

uint64 sys_getSysCount(void){

  struct proc *p = myproc();
  // update p->yo by fetching the argument
  // need to mask the argument first

  // int arg1;  // Variable to store the argument (arg[1])
  int arg1;
    
    // Fetch the first argument passed to the syscall (arg[1])
    argint(0, &arg1);
    // argaddr(1, &arg1);
    // int masked_arg = arg1 & 0xFFFFFFFF;
  //   int position = 0;

  //   printf("arg1 %d\n", arg1);
  
  // while (arg1 > 1) {
  //   arg1 >>= 1;  // Shift right by 1 bit
  //   position++;
  // }

  // int mask = position;
  // printf("sysnum value in sysproc.c : %d\n",sysnum);
  p->yo = arg1;
  // printf("Masked value of arg1 assigned to p->yo: %d\n", p->yo);
  

  // printf("p->yo %d\n", p->yo);
  // p->yo = 15;
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
    } else if (p->yo == 6) {
        return p->killcount;
    } else if (p->yo == 7) {
        return p->execcount;
    } else if (p->yo == 8) {
        return p->fstatcount;
    } else if (p->yo == 9) {
        return p->chdircount;
    } else if (p->yo == 10) {
        return p->dupcount;
    } else if (p->yo == 11) {
        return p->getpidcount;
    } else if (p->yo == 12) {
        return p->sbrkcount;
    } else if (p->yo == 13) {
        return p->sleepcount;
    } else if (p->yo == 14) {
        return p->uptimecount;
    } else if (p->yo == 15) {
      // printf("pid of p %d\n", p->pid);
        return p->opencount;
    } else if (p->yo == 16) {
        return p->writecount;
    } else if (p->yo == 17) {
        return p->mknodcount;
    } else if (p->yo == 18) {
        return p->unlinkcount;
    } else if (p->yo == 19) {
        return p->linkcount;
    } else if (p->yo == 20) {
        return p->mkdircount;
    } else if (p->yo == 21) {
        return p->closecount;
    } else if (p->yo == 22) {
        return p->waitxcount;
    } else if (p->yo == 23) {
        return p->getSysCountcount;
    } else if (p->yo == 24) {
        return p->sigalarmcount;
    } else if (p->yo == 25) {
        return p->sigreturncount;
    } else if (p->yo == 26) {
        return p->setticketscount;
    } 

    // If p->yo is not recognized, return 0 or an appropriate error value
    return 0;

}

uint64 sys_sigalarm(void)
{
  uint64 addr;
  int ticks;

  argint(0, &ticks);
  argaddr(1, &addr);
  // if(argint(0, &ticks) < 0)
  //   return -1;
  // if(argaddr(1, &addr) < 0)
  //   return -1;

  // myproc()->ticks = ticks;
  // myproc()->handler = addr;
  struct proc *p = myproc();
  p->ticks = ticks;
  p->handler = addr;

  // printf("sys_sigalarm: ticks=%d, handler=%p\n", ticks, addr); // Debugging statement

  return 0;
}

uint64 sys_sigreturn(void)
{
  struct proc *p = myproc();
  if (p->alarm_tf == 0)
    return -1; // No saved trap frame
  // printf("sys_sigreturn: restoring trapframe\n"); // Debugging statement
  memmove(p->trapframe, p->alarm_tf, sizeof(struct trapframe));

  kfree(p->alarm_tf);
  p->alarm_tf = 0;
  p->alarm_on = 0;
  p->cur_ticks = 0;
  usertrapret();
  return 0;
}

int sys_settickets(int n){
  // int n;
  argint(0, &n);
  if(n < 1)
    return -1;
  struct proc *p = myproc();
  acquire(&p->lock);
  p->tickets = n;
  release(&p->lock);
  return n;
}

