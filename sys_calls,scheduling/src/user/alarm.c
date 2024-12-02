#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void alarm_handler() {
  printf("Alarm triggered!\n");
  sigreturn();
}

int main(int argc, char *argv[]) {
  int ticks = 100; // Number of ticks before the alarm triggers

  // Set up the alarm
  if (sigalarm(ticks, alarm_handler) < 0) {
    printf("sigalarm failed\n");
    exit(1);
  }

  // Busy loop to keep the process running
  while (1) {
    printf("Process running...\n");
    sleep(50); // Sleep for a while to simulate work
  }

  exit(0);
}