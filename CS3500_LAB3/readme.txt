Changes for P1:

1. kernel/vm.c
  
   I added new implementation of the function in vmprint which further calls another recursive implemented printable function
  #ifdef LAB_PGTBL
void printtable(pagetable_t pt,int level,int preslevel){
    if(preslevel>=level){
      return;
    }
    for(int i=0;i<(1<<9);i++){
      pte_t pte=pt[i];
      if(pte& PTE_V){
        for(int j=0;j<preslevel;j++){
          printf(".. ");
        }
        printf("..%d: pte %p pa %p \n",i,(void*)pte,(void*)PTE2PA(pte));
        if((pte & (PTE_R|PTE_W|PTE_X))==0){
          printtable((pagetable_t)PTE2PA(pte),level,preslevel+1);
        }
      }
    }
}
#endif
#ifdef LAB_PGTBL
void
vmprint(pagetable_t pt) {
      printf("pagetable %p\n",pt);
      printtable(pt,3,0);
}
#endif
 

2. kernel/exec.c
   added a vmprint call in exec func at the point where exec just loaded the file it should execute in the user virtual memory space 
   #ifdef LAB_PGTBL
  if(p->pid==1){
  vmprint(p->pagetable);
  }
  #endif

*  The first user process to execute is the exec of init in sysfile.c so it will print the pagetables after loading the executable of init.c into ram and  executes the init function
the implementation of the vmprint is that it calls a recursive function printable and the implementation of printtable is that it checks upto (1<<9) and for each i it stores the pte stored at that address and checks the valid bit,if it is then prints the pte and the pa of that pte and then checks it is not a leaf then recursively call the printtable function.

changes for P2:

1.proc.c

*added the following code in allocproc just after allocating the trapframe

#ifdef LAB_PGTBL

  p->usyscall1 = (struct usyscall*)kalloc();
  if(p->usyscall1 == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }
  p->usyscall1->pid = p->pid;
#endif

*added the following code in freeproc after freeing the trapeframe

#ifdef LAB_PGTBL

  p->usyscall1 = (struct usyscall*)kalloc();
  if(p->usyscall1 == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }
  p->usyscall1->pid = p->pid;
#endif

*added the following code in proc_pagetable after mapping of trapframe  to physical address

#ifdef LAB_PGTBL
  if(mappages(pagetable,USYSCALL,PGSIZE,
         (uint64)(p->usyscall1), PTE_R | PTE_U) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }
#endif

* added the following code at the start of the function proc_freepagetable

#ifdef LAB_PGTBL
  if(mappages(pagetable,USYSCALL,PGSIZE,
         (uint64)(p->usyscall1), PTE_R | PTE_U) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }
#endif

2.proc.h

added a new struct usyscall with identifier usyscall1 in struct proc

*The core idea here is that normally we will have a function that calls as a systemcall to kernel to read the process id .So every time when you want a process id you have traps now we implement the kernel files such that whenever my process is allocated and pagetable is created i will allocate a page size memory at an address USYSCALL and this has a proc syscall in it which contains pid  i will map the  pa to the va USYSCALL in read and user mode so that it becomes a shared memory bw user and kernel.There will be a func defined in ulib.c which returns directly the pid .Since  it is in user space there is no need for a syscall which enhances the performance.

changes for P3:

1.user.h
  added int pgaccess(void *base, int len, void *mask); inside #ifdef LAB_PGTBL 
  
2.Usys.pl
 added entry("pgaccess"); # LAB_PGTBL in entry section

3.syscall.h
 added 
#ifdef LAB_PGTBL
#define SYS_pgaccess  35
#endif 
at the end of the file

4.syscall.c

*added extern uint64 sys_pgaccess(void);
  in the #ifdef LA_PGTBL in extern part

* added [SYS_pgaccess] sys_pgaccess,
  in the syscalls array in LAB_PGTBL section

5.defs.h

* added int pgaccess(void *base, int len, void *mask);
 in the vm.c section's LAB_PGTBL part

6.riscv.h

* added #ifdef LAB_PGTBL

#define PTE_A (1L << 6) // accessed

#endif

after the declarations of the other bits like V,W,R etc.

7.sysproc.c
 added the following function:
#ifdef LAB_PGTBL
uint64 
sys_pgaccess(void)
{
  uint64 base;
  int len;
  uint64 mask_va;
  argaddr(0,&base);
  argint(1,&len);
  argaddr(2,&mask_va);
  return pgaccess((void*)base,len,(uint64*)mask_va);
}

#endif

8.vm.c
 implemented pgaccess here
#ifdef LAB_PGTBL
int pgaccess(void* base,int len,void* mask_user_address){
  struct proc *p = myproc();
  if(p!=0&&len<=0&&len>PG_ACCESS_MAX){
    return -1;
  }
  uint64 base_va=(uint64)base;
  base_va=PGROUNDDOWN(base_va);
  uint64 bits=0;
  for(int i=0;i<len;i++){
    uint64 va=base_va+ (uint64)(i*PGSIZE);
    pte_t *pte=walk(p->pagetable,va,0);
    if(pte==0){
      continue;
    }
    if((*pte&PTE_V)==0 ||(*pte&PTE_U)==0){
      continue;
    }

    if(*pte&PTE_A){
      bits|=(1<<i);
      *pte&=~PTE_A;
    }
  }

  if(copyout(p->pagetable, (uint64)mask_user_address, (char *)&bits, sizeof(bits)) < 0){
    return -1;
  }

    return 0;
}
#endif

9.Makefile

* added $U/_pgtbltest\  and removed 	$U/_sleep\

*   When we call pgaccess_test  we can pgaccess two times first time the abits gets updated nothing as we are not accssing any pages from the user virtual adderss space of the memory.But     for the second time when we are writing buff[] we are accessing three pages 2,4,2^30 and hence when i invoke the func call pgaccess it stored the abits's 2nd,4th and 2^30 bit as 1 and hence when i check the or condition it gives ok provided my implementation is crt.

*  When i call pgaccess then it goes to sys_pgaccess defined in sysproc.c and there i stores the arguments into local variables and calls the pgaccess function defined in vm.h .

* The pgaccess function takes the starting va of the user address space and the no of pgtables to access test and stores it in the other argument .It aligns the va to 64byte address .for each iteration you go to that particular page's va and walk through the process pgtable for that va and updates the access bit accordingly and then calls a copyput for copying from kernel memory to user memory






