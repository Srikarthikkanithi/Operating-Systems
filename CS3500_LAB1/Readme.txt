     Steps to Run the program on xv6 kernel

 1. Open the folder xv6-riscv in vscode and in the vscode's windows powershell run the following command to enter into the docker container 
    docker run -it -v C:\Users\srika/xv6-riscv:/home/os-iitm/xv6-riscv svkv/riscv-tools:v1.0
    Note: that before running you are in the windows xv6-riscv folder and after running the command you are entering into the docker container and any chaanges you make here will impact the original folder

 2. Now run the command :
    cd xv6-riscv && make qemu
    now you will direct into the xv6 kernel where you type the name of the file without its extension 

   Code explanation:

   .section .data                                  #for the data section
msg:                                               #name of the string variable
    .ascii "Hello CS23B029! Welcome to CS3500\n"   #value of the string      

.section .text                                     #for the text section
.globl main                                        #declaring main as the global label

main:
    li a7, 16                                      # the a7 register tells you what type of system call to implement when it sees ecall and here it says write
    li a0, 1                                       # the reg a0 corresponds to the file descriptor stdout here
    la a1, msg                                     # the a1 coresponds to address of the msg
    li a2, 36                                      # the a2 coresponds to the length from the msg in bytes to write to the file descriptor
    ecall                                          

    ret
