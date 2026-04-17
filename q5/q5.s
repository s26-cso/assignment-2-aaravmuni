.section .data
filename: .string "input.txt"
yes_msg: .string "Yes\n"
no_msg: .string "No\n"

.section .bss
.align 4
buf: .space 1048576 #1MB buffer, holds file contents

.section .text
main:
    #open(input.txt,O_RDONLY)

    li a7, 56 #syscall:openat
    li a0, -100 #AT_FDCWD
    la a1,filename
    li a2,0 #O_RDONLY
    li a3, 0
    ecall
    bltz a0,exit_err #negative fd leads to error
    mv t0,a0 #t0 = fd

    #read(fd,buf,1MB)

    li a7,63 #syscall: read
    mv a0,t0
    la a1,buf
    li a2,1048576
    ecall
    #a0=number of bytes read
    blez a0,print_yes #empty string is a palindrome

    mv t1,a0 #t1 has length

    #close(fd)

    li a7, 57 #syscall: close
    mv a0, t0
    ecall

    #strip trailing newline
    la t2,buf #t2 = base pointer

strip_loop:
    beqz t1,print_yes #if empty after strip, print yes

    add t3, t2, t1
    addi t3, t3, -1 #t3=pointer to last char

    lb t4,0(t3)
    li t5,10 #'\n'

    beq t4,t5,do_strip
    li t5,13 #'\r'

    beq t4,t5,do_strip
    j two_pointer

do_strip:
    addi t1,t1,-1
    j strip_loop

#two pointer palindrome check

#t2 = address of buf
#t1 = length
#left pointer = t2
#right pointer = t3

two_pointer:
    la t2,buf

    la t3, buf
    add t3, t3, t1
    addi t3, t3, -1

check_loop:
    bgeu t2,t3,print_yes #left >=right, then palindrome confirmed

    lb t4, 0(t2)
    lb t5, 0(t3)

    bne t4,t5,print_no #if not equal, then not a palindrrome

    addi t2, t2, 1
    addi t3, t3, -1

    j check_loop

#print yes:

print_yes:
    li a7,64 #syscall:write
    li a0,1 #stdout
    la a1,yes_msg
    li a2,4 #"Yes\n" = 4 bytes

    ecall
    j exit_ok

print_no:
    li a7,64 #syscall:write
    li a0,1 #stdout
    la a1,no_msg
    li a2,3 #"No\n" = 3 bytes

    ecall

exit_ok:
    li a7,93 #syscall:exit
    li a0,0
    ecall

exit_err:
    li a7,93
    li a0,1
    ecall

