#include "kernel/types.h"
#include "kernel/memlayout.h"
#include "user/user.h"  // Or your relevant header for COW handling
#include "kernel/cow_faults.h"


void read_only_test() {
    uint64 phys_size = PHYSTOP - KERNBASE;
    int sz = (phys_size / 3) * 2;

    // Reset the page fault counter before forking
    cow_page_fault_count = 0; 

    printf("read-only test: ");
    char *p = sbrk(sz);
    if (p == (char*)0xffffffffffffffffL) {
        printf("sbrk(%d) failed\n", sz);
        exit(-1);
    }

    // Touch each page to ensure mapping
    for (char *q = p; q < p + sz; q += 4096) {
        *(int*)q = getpid();
    }

    int pid = fork();
    if (pid < 0) {
        printf("fork() failed\n");
        exit(-1);
    }

    if (pid == 0) {
        // Child process: Read from each page without modifying
        for (char *q = p; q < p + sz; q += 4096) {
            volatile int temp = *(int*)q; // Use volatile to avoid optimization
            (void)temp; // Prevent compiler optimization
        }
        exit(0);
    }

    wait(0); // Parent waits for child

    if (sbrk(-sz) == (char*)0xffffffffffffffffL) {
        printf("sbrk(-%d) failed\n", sz);
        exit(-1);
    }

    printf("ok\n");
}

int main(int argc, char *argv[]) {
    read_only_test();
    exit(0);
}
