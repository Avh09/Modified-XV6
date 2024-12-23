// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
  // struct spinlock lock_count;
  // int count[(PGROUNDUP(PHYSTOP) - KERNBASE)/PGSIZE];
} kmem;


struct {
  struct spinlock lock;
  int c_ref[(PGROUNDUP(PHYSTOP) - KERNBASE)/PGSIZE];
} reference_count;


void
inc(void *pa)
{
  acquire(&reference_count.lock);
  reference_count.c_ref[((uint64)(pa) - KERNBASE) / PGSIZE]++;
  release(&reference_count.lock);
}

void
dec(void *pa)
{
  acquire(&reference_count.lock);
  reference_count.c_ref[((uint64)(pa) - KERNBASE) / PGSIZE]--;
  release(&reference_count.lock);
}

int
retrieving(void *pa)
{
  int cnt;
  acquire(&reference_count.lock);
  cnt = reference_count.c_ref[((uint64)(pa) - KERNBASE) / PGSIZE];
  release(&reference_count.lock);
  return cnt;
}

void
kinit()
{
  initlock(&kmem.lock, "kmem");

  // initlock(&kmem.lock_count, "kmem_count");
  initlock(&reference_count.lock, "reference_count");


  for (int i = 0; i < (PGROUNDUP(PHYSTOP)-KERNBASE) / PGSIZE; i++)
    reference_count.c_ref[i] = 1;

  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  if (retrieving(pa) <= 0){
    panic("kfree_decr");
  }
    

  dec(pa);

  int retrieved_val = retrieving(pa);
  if (retrieved_val > 0){
    return;
  }
  else{
    memset(pa, 1, PGSIZE);
    r = (struct run*)pa;
    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    release(&kmem.lock);

  }
  
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r){
    kmem.freelist = r->next;
  }
    
  release(&kmem.lock);

  if(r){
    memset((char*)r, 5, PGSIZE);
    acquire(&reference_count.lock);
    reference_count.c_ref[((uint64)(r) - KERNBASE) / PGSIZE] = 1;
    release(&reference_count.lock);
  }
  return (void*)r;
}



