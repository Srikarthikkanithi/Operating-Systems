**file changes made:

1.Makefile
2.trace.c
3.user.h
4.usys.pl
5.syscall.h
6.syscall.c
7.sysproc.c
8.proc.c
9.bttest.c
10.proc.h
11.printf.c
12.param.h
13.riscv.h
14.defs.h

**changes made in files:

1.Makefile:
  - added $U/_trace\ to the UPROGS section (for P1)
  - added $U/_bttest\ to the UPROGS section (for P2)

2.trace.c:(for P1)
  - called trace function (user space stub for trace syscall) followed by execution of the process

3.user.h:(for P1)
  - added int trace(int); in system calls section 

4.usys.pl:(for P1)
  - added entry("trace"); in entries section

5.syscall.h:(for P1)
  - added another macro for trace -- #define SYS_trace 22

6.syscall.c:(for P1)
  - added an extern variable sys_trace --extern uint64 sys_trace(void);
  - added sys_trace to the syscalls array --[SYS_trace]   sys_trace,
  - added a static char* syscallnames array for printing the syscall names rather than the numbers corresponding to the syscalls.
    static char *syscallnames[] = {
	[SYS_fork]    "fork",
	[SYS_exit]    "exit", 
	[SYS_wait]    "wait",
	[SYS_pipe]    "pipe",
	[SYS_read]    "read", 
	[SYS_kill]    "kill",
	[SYS_exec]    "exec",
	[SYS_fstat]   "fstat",  
	[SYS_chdir]   "chdir",
	[SYS_dup]     "dup",
	[SYS_getpid]  "getpid", 
	[SYS_sbrk]    "sbrk",
	[SYS_sleep]   "sleep",
	[SYS_uptime]  "uptime",
	[SYS_open]    "open",
	[SYS_write]   "write",
	[SYS_mknod]   "mknod",
	[SYS_unlink]  "unlink",
	[SYS_link]    "link",
	[SYS_mkdir]   "mkdir",
	[SYS_close]   "close",
	[SYS_trace]   "trace",
     };
 - added the following after calling the syscalls[num]
    if(p->trace_mask & (1 << num)) {                      //checking whether my particular bit in trace_mask corresponding to the syscall is enabled if it is then print in the asked format
      printf("%d: syscall %s -> %ld\n",
             p->pid, syscallnames[num], p->trapframe->a0);
    }

7. sysproc.c:
  - added backtrace() func in sys_sleep
  - implementation of sys_trace
    uint64
    sys_trace(void){
    int mask;
    argint(0, &mask);
    myproc()->trace_mask = mask;
    return 0;
    }

8.proc.c:(for P1)
  - in fork passing the mask to the child processes -- np->trace_mask= p->trace_mask;
 
9.bttest.c:(for P2)
  - written as specified in the question

10.proc.h(for P1)
  - added a trace_mask variable in struct proc for storing the mask for a particular process

11.printf.c(for P2)
  - called backtrace func after printing panic in panic function
  - implemented printf_short for truncating the starting 0's in an address
    static void
    printptr_short(uint64 x)
   {
    char *digits = "0123456789abcdef";
    int started = 0; // skip leading zeros

    consputc('0');
    consputc('x');

    for (int i = 0; i < (sizeof(uint64)*2); i++) {
        int shift = (sizeof(uint64)*2 - 1 - i) * 4;
        int d = (x >> shift) & 0xf;
        if (d != 0 || started || i == (sizeof(uint64)*2 - 1)) {
            consputc(digits[d]);
            started = 1;
        }
    }
   }
 - implementation of backtrace function
   void backtrace(void)
   {
    struct proc *p = myproc();
    uint64 fp = r_fp();
    uint64 *fp_ptr = (uint64*)fp;

    uint64 stack_top = (uint64)p->kstack + KSTACKSIZE;
    uint64 stack_bottom = (uint64)p->kstack;

    while((uint64)fp_ptr < stack_top && (uint64)fp_ptr >= stack_bottom) {
        uint64 ra = *(fp_ptr - 1);      // fp-8 → return address
        if(ra == 0) break;              // stop if ra invalid
        // printf("0x%p\n", ra);
        printptr_short(ra);
        printf("\n");
        fp_ptr = (uint64*)(*(fp_ptr - 2)); // fp-16 → previous frame pointer
    }
   }

12.param.h(for P2)
   - added a macro for maximum size of a stack
     #define KSTACKSIZE   4096  

13.riscv.h(for P2)
   - implementation of r_fp as stated in the question

14.defs.h(for P2)
   - added backtrace func in printf.c category
     void           backtrace(void);



** Internal working of the code:

* In general  what happens during a syscall with trace as an example:
 
  - in user space when i want to compile a file then it is included in UPROGS section of Makefile
  - in trace.c my main takes argc and char * argv as the arguments corresponding to the input given to the shell ,the 2d argument will be mask provided first argument is trace ,so store      the 2nd argument in mask variable . now call the trace stub syscall to store the value mask in the process's trace_mask.After the trace syscall is implemented returned to the kernel you execute the remaining process.
  - Now when i call trace in trace.c file,it wll check the validity of the func name in user.h and then if its valid then it checks the entry values in Usys.pl and then autogenerates the corresponding code in Usys.S
  - In Usys.S you store 22 in a7 (syscall type) then when you write ecall it goes to the address stored in stvec which is the label uservec in trampoline.S
  - In trampoline.S you jump to the usertrap func in trap.c after storing all the user registers
  - In trap.c ,as scause==8 (syscall) it calls syscall() func .
  - the func syscall is implemented in syscall.c file and in that func you call syscalls[num]() which corresponds to the actual implementation sys_trace in sysproc.c
  - and there it implements sys_trace and finally returns to usermode from trampoline.S

* for P1:
  - you first call the trace to store the mask value in the processes mask value and then execute the following process with arguments

* for P2:
  - you just execute the bttests directly as it is the only argument in the shell.
  - In bttests.c you call the sleep function and in the implementation of the sys_sleep function in sysproc.c  you call also backtrace function and also in the panic func in printf.c you call backtrace function
  

   



