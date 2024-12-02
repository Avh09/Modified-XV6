#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"

int settickets(int number) {
    return syscall(SYS_settickets, number);
}

int main() {
    int tickets = 2; // Set the desired number of tickets
    int newTicketNum = settickets(tickets);
    
    if (newTicketNum == -1) {
        fprintf(2, "could not change tickets to %d for process with pid %d\n", tickets, getpid());
        exit(1);
    }

    printf("Successfully changed tickets to %d for process with pid %d\n", newTicketNum, getpid());
    exit(0);
}