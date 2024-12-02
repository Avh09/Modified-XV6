#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "syscall.h"
#include "defs.h"

#define NUM_SYSCALLS 26
// int sysCount[NUM_SYSCALLS];

// Fetch the uint64 at addr from the current process.
int
fetchaddr(uint64 addr, uint64 *ip)
{
  struct proc *p = myproc();
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    return -1;
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    return -1;
  return 0;
}

// Fetch the nul-terminated string at addr from the current process.
// Returns length of string, not including nul, or -1 for error.
int
fetchstr(uint64 addr, char *buf, int max)
{
  struct proc *p = myproc();
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    return -1;
  return strlen(buf);
}

static uint64
argraw(int n)
{
  struct proc *p = myproc();
  switch (n) {
  case 0:
    return p->trapframe->a0;
  case 1:
    return p->trapframe->a1;
  case 2:
    return p->trapframe->a2;
  case 3:
    return p->trapframe->a3;
  case 4:
    return p->trapframe->a4;
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
  *ip = argraw(n);
}

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
  *ip = argraw(n);
}

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
}

// Prototypes for the functions that handle system calls.
extern uint64 sys_fork(void);
extern uint64 sys_exit(void);
extern uint64 sys_wait(void);
extern uint64 sys_pipe(void);
extern uint64 sys_read(void);
extern uint64 sys_kill(void);
extern uint64 sys_exec(void);
extern uint64 sys_fstat(void);
extern uint64 sys_chdir(void);
extern uint64 sys_dup(void);
extern uint64 sys_getpid(void);
extern uint64 sys_sbrk(void);
extern uint64 sys_sleep(void);
extern uint64 sys_uptime(void);
extern uint64 sys_open(void);
extern uint64 sys_write(void);
extern uint64 sys_mknod(void);
extern uint64 sys_unlink(void);
extern uint64 sys_link(void);
extern uint64 sys_mkdir(void);
extern uint64 sys_close(void);
extern uint64 sys_waitx(void);
extern uint64 sys_getSysCount(void);
extern uint64 sys_sigalarm(void);
extern uint64 sys_sigreturn(void);
extern uint64 sys_settickets(void);

// extern int op;
// extern int sysnum;

// An array mapping syscall numbers from syscall.h
// to the function that handles the system call.
static uint64 (*syscalls[])(void) = {
[SYS_fork]    sys_fork,
[SYS_exit]    sys_exit,
[SYS_wait]    sys_wait,
[SYS_pipe]    sys_pipe,
[SYS_read]    sys_read,
[SYS_kill]    sys_kill,
[SYS_exec]    sys_exec,
[SYS_fstat]   sys_fstat,
[SYS_chdir]   sys_chdir,
[SYS_dup]     sys_dup,
[SYS_getpid]  sys_getpid,
[SYS_sbrk]    sys_sbrk,
[SYS_sleep]   sys_sleep,
[SYS_uptime]  sys_uptime,
[SYS_open]    sys_open,
[SYS_write]   sys_write,
[SYS_mknod]   sys_mknod,
[SYS_unlink]  sys_unlink,
[SYS_link]    sys_link,
[SYS_mkdir]   sys_mkdir,
[SYS_close]   sys_close,
[SYS_waitx]   sys_waitx,
[SYS_getSysCount] sys_getSysCount,
[SYS_sigalarm] sys_sigalarm,
[SYS_sigreturn] sys_sigreturn,
[SYS_settickets] sys_settickets,
};

void
syscall(void)
{
  int num;
  struct proc *p = myproc();

  num = p->trapframe->a7;
  // if(num > 0 && num <= 25){
  //   p->syscall_count[num]++;;
  // }
  // printf("System call %d\n", num);

  // acquire(&wait_lock);
    // p->syscall_count[num]++;
  if (num == SYS_read) {
    if(p->parent) p->parent->readcount++;
}
if (num == SYS_write) {
    if(p->parent) p->parent->writecount++;
}
if (num == SYS_fork) {
    if(p->parent) p->parent->forkcount++;
}
if (num == SYS_exit) {
    if(p->parent) p->parent->exitcount++;
}
if (num == SYS_wait) {
    if(p->parent) p->parent->waitcount++;
}
if (num == SYS_sleep) {
    if(p->parent) p->parent->sleepcount++;
}
if (num == SYS_uptime) {
    if(p->parent) p->parent->uptimecount++;
}
if (num == SYS_kill) {
    if(p->parent) p->parent->killcount++;
}
if (num == SYS_sigalarm) {
    if(p->parent) p->parent->sigalarmcount++;
}
if (num == SYS_sigreturn) {
    if(p->parent) p->parent->sigreturncount++;
}
if (num == SYS_chdir) {
    if(p->parent) p->parent->chdircount++;
}
if (num == SYS_dup) {
    if(p->parent) p->parent->dupcount++;
}
if (num == SYS_getpid) {
    if(p->parent) p->parent->getpidcount++;
}
if (num == SYS_sbrk) {
    if(p->parent) p->parent->sbrkcount++;
}
if (num == SYS_open) {
    if(p->parent) {
        // printf("Open count\n");
        // printf("pid of parent is %d\n", p->parent->pid);
        p->parent->opencount++;
        // printf("%d\n", p->parent->opencount);
    }
}
if (num == SYS_mknod) {
    if(p->parent) p->parent->mknodcount++;
}
if (num == SYS_unlink) {
    if(p->parent) p->parent->unlinkcount++;
}
if (num == SYS_link) {
    if(p->parent) p->parent->linkcount++;
}
if (num == SYS_mkdir) {
    if(p->parent) p->parent->mkdircount++;
}
if (num == SYS_close) {
    if(p->parent) p->parent->closecount++;
}
if (num == SYS_waitx) {
    if(p->parent) p->parent->waitxcount++;
}
if (num == SYS_getSysCount) {
    if(p->parent) p->parent->getSysCountcount++;
}
if (num == SYS_pipe) {
    if(p->parent) p->parent->pipecount++;
}
if (num == SYS_exec) {
    if(p->parent) p->parent->execcount++;
}
if (num == SYS_fstat) {
    if(p->parent) p->parent->fstatcount++;
}
if(num == SYS_settickets){
  if(p->parent) p->parent->setticketscount++;  
}


    // release(&initlock);
  
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    
    p->trapframe->a0 = syscalls[num]();
    
    // printf("System call %d count: %d\n", num, p->syscall_count[num]); // Debugging statement
    // if (num < NUM_SYSCALLS) {
    //   sysCount[num]++; // Increment the count for the system call
    // }
  } else {
    printf("%d %s: unknown sys call %d\n",
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
  }
}
