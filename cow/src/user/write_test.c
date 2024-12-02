// user.c
// #include <stdio.h>
#include <stddef.h>
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/stat.h"
#include "kernel/memlayout.h"

#define PAGE_SIZE 4096

// Declare the system call prototype
int get_page_fault_count(void);

int main(int argc, char *argv[]) {
    // Allocate memory for an array of integers
    int *arr = malloc(PAGE_SIZE);
    if (arr == NULL) {
        printf("Memory allocation failed!\n");
        exit(1);
    }

    // Initialize the array
    for (int i = 0; i < PAGE_SIZE / sizeof(int); i++) {
        arr[i] = i;
    }

    printf("Parent process: memory initialized\n");

    // Fork the process
    int pid = fork();
    if (pid < 0) {
        printf("Fork failed!\n");
        exit(1);
    }

    if (pid == 0) {
        // Child process: Try modifying the memory
        printf("Child process: modifying memory\n");
        for (int i = 0; i < PAGE_SIZE / sizeof(int); i++) {
            arr[i] = arr[i] * 2;  // Modify the array to trigger page fault (in COW case)
        }

        // Print modified values
        for (int i = 0; i < PAGE_SIZE / sizeof(int); i++) {
            // printf("Child arr[%d] = %d\n", i, arr[i]);
        }

        exit(0); // Child process exits
    } else {
        // Parent process: Wait for child to finish
        wait(0);

        // Print parent’s array to check if it was affected by COW
        printf("Parent process: After child modification\n");
        for (int i = 0; i < PAGE_SIZE / sizeof(int); i++) {
            // printf("Parent arr[%d] = %d\n", i, arr[i]);
        }

        // Get the page fault count from the syscall
        int faults = get_page_fault_count();
        printf("Page faults in parent (COW): %d\n", faults);  // You need to have this in your kernel code
        exit(0); // Parent exits
    }
}
