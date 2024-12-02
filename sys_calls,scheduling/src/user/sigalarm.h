#ifndef SIGALARM_H
#define SIGALARM_H

#include "kernel/types.h"

// Function prototypes
int sigalarm(int ticks, void (*handler)());
int sigreturn(void);

#endif // SIGALARM_H