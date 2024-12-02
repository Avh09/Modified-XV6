#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
// #include "syscount.h"
// #include "global.h"
// #include "kernel/syscall.h"

// extern int sysnum;
int sysnum = 0;

// Manually define system call numbers (same as in kernel's syscall.h)
#define SYS_fork    1
#define SYS_exit    2
#define SYS_wait    3
#define SYS_pipe    4
#define SYS_read    5
#define SYS_kill    6
#define SYS_exec    7
#define SYS_fstat   8
#define SYS_chdir   9
#define SYS_dup    10
#define SYS_getpid 11
#define SYS_sbrk   12
#define SYS_sleep  13
#define SYS_uptime 14
#define SYS_open   15
#define SYS_write  16
#define SYS_mknod  17
#define SYS_unlink 18
#define SYS_link   19
#define SYS_mkdir  20
#define SYS_close  21
#define SYS_waitx  22
#define SYS_getSysCount 23
#define SYS_sigalarm 24
#define SYS_sigreturn 25


// List of system call names
static char *syscall_names[] = {
    [SYS_fork] = "fork",
    [SYS_exit] = "exit",
    [SYS_wait] = "wait",
    [SYS_pipe] = "pipe",
    [SYS_read] = "read",
    [SYS_kill] = "kill",
    [SYS_exec] = "exec",
    [SYS_fstat] = "fstat",
    [SYS_chdir] = "chdir",
    [SYS_dup] = "dup",
    [SYS_getpid] = "getpid",
    [SYS_sbrk] = "sbrk",
    [SYS_sleep] = "sleep",
    [SYS_uptime] = "uptime",
    [SYS_open] = "open",
    [SYS_write] = "write",
    [SYS_mknod] = "mknod",
    [SYS_unlink] = "unlink",
    [SYS_link] = "link",
    [SYS_mkdir] = "mkdir",
    [SYS_close] = "close",
    [SYS_waitx] = "waitx",
    [SYS_getSysCount] = "getSysCount",
    [SYS_sigalarm] = "sys_sigalarm",
    [SYS_sigreturn] = "sys_sigreturn"

};

// int main(int argc, char *argv[]) {
//   if (argc < 3) {
//     fprintf(2, "Usage: syscount <mask> <command> [args]\n");
//     exit(1);
//   }

//   int mask = atoi(argv[1]); // Convert mask to integer
//   int syscall_number = -1;

//   // Determine which system call the mask corresponds to
//   for (int i = 0; i < sizeof(syscall_names) / sizeof(char *); i++) {
//     if (mask == (1 << i)) {
//       syscall_number = i; // Found the system call number
//       break;
//     }
//   }

//   if (syscall_number == -1) {
//     fprintf(2, "Invalid mask: No system call corresponds to this mask\n");
//     exit(1);
//   }

//   int pid = fork();
//   if (pid < 0) {
//     fprintf(2, "fork failed\n");
//     exit(1);
//   }

//   if (pid == 0) {
//     // Child process: execute the command with arguments
//     exec(argv[2], &argv[2]);
//     // If exec fails
//     fprintf(2, "exec failed\n");
//     exit(1);
//   } else {
//     // Parent process: wait for the child to finish
//     wait(0);

//     // Fetch the system call count using the getSysCount system call
//     int count = getSysCount(mask);
//     if (count >= 0) {
//       printf("PID %d called %s %d times.\n", pid, syscall_names[syscall_number], count);
//     } else {
//       printf("Error retrieving syscall count.\n");
//     }
//   }

//   exit(0);
// }

// int main(int argc, char *argv[]) {
//   if (argc < 3) {
//     fprintf(2, "Usage: syscount <mask> <command> [args]\n");
//     exit(1);
//   }

//   int mask = atoi(argv[1]); // Convert mask to integer
//   int syscall_number = -1;

//   // Determine which system call the mask corresponds to
//   for (int i = 0; i < 23; i++) {
//     if (mask == (1 << i)) {
//       syscall_number = i; // Found the system call number
//       break;
//     }
//   }

//   if (syscall_number == -1) {
//     fprintf(2, "Invalid mask: No system call corresponds to this mask\n");
//     exit(1);
//   }

//   int count_before = getSysCount(mask); // Get initial count
//   printf("Initial count for syscall %s: %d\n", syscall_names[syscall_number], count_before);

//   int pid = fork();
//   if (pid == 0) {
//     // Child process: execute the command
//     exec(argv[2], &argv[2]);
//     fprintf(2, "exec %s failed\n", argv[2]);
//     exit(1);
//   } else if (pid > 0) {
//     // Parent process: wait for the child to finish
//     wait(0);
//     int count_after = getSysCount(mask); // Get final count
//     printf("Final count for syscall %s: %d\n", syscall_names[syscall_number], count_after);

//     int sys_count = count_after - count_before; // Calculate the difference

//     // Print the result
//     printf("PID %d called %s %d times.\n", pid, syscall_names[syscall_number], sys_count);
//   } else {
//     fprintf(2, "fork failed\n");
//     exit(1);
//   }

//   exit(0);
// }
int find_highest_set_bit(int num) {
  int position = 0;
  
  while (num > 1) {
    num >>= 1;  // Shift right by 1 bit
    position++;
  }
  
  return position;
}

int main(int argc, char *argv[]) {
  int count;
  if (argc < 3) {
    printf("Usage: %s <pid> <syscall_number>\n", argv[0]);
    exit(1);
  }

  int num = atoi(argv[1]);  // Convert the syscall number argument to an integer
  // printf("num: %d\n", num);
  sysnum = find_highest_set_bit(num);
  // printf("sysNum: %d\n", sysnum);

  // printf("arg[2]: %s\n", argv[2]);
  int pid = fork();
  if (pid == 0) {
    exec(argv[2], &argv[2]);
    fprintf(2, "exec %s failed\n", argv[2]);
    exit(1);
  } else if (pid > 0) {
    wait(0);
    // printf("sysnum in syscount: %d\n", sysnum);
    // myproc()->yo = sysnum;
    count = getSysCount(sysnum);
  } else {
    fprintf(2, "fork failed\n");
    exit(1);
  }

  if (count >= 0 && sysnum > 0 && sysnum < 26) {
    printf("PID %d called %s %d times.\n", getpid(), syscall_names[sysnum], count);
  } else {
    printf("Invalid system call number.\n");
  }

  exit(0);
}