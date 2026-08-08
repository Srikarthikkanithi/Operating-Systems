.section .data
msg:
    .ascii "Hello CS23B029! Welcome to CS3500\n"

.section .text
.globl main

main:
    li a7, 16         
    li a0, 1          kk
    la a1, msg        
    li a2, 36         
    ecall             

    ret