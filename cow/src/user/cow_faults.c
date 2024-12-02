#include "kernel/types.h"
#include "kernel/memlayout.h"
#include "user/user.h"


void print_page_fault_count(const char *test_name) {
  int count = cow_faults();
  printf("%s: Pagefault frequency: %d\n", test_name, count);
}