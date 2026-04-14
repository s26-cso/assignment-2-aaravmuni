.section .data
space: .asciz " "
newline: .asciz "\n"
fmt: .asciz "%ld"

.section .text

.global main
.extern printf
.extern atoi
.extern malloc

main:
    #a0 = argc, a1 = argv

    #storing original values in stack

    addi sp, sp, -80
    sd s4, 0(sp)
    sd s3, 8(sp)
    sd s2, 16(sp)
    sd s1, 24(sp)
    sd s0, 32(sp)
    sd ra, 40(sp)
    sd s5, 48(sp)
    sd s6, 56(sp)
    sd s7, 64(sp)

    mv s6, a0

    addi s0, s6, -1 #n = argc-1 since argv[0] is the program name
    #s0 = size of array

    mv s5, a1

    #allocate memory
    slli s7, s0, 3 #n*8 bytes required t0 store array
    mv a0, s7
    call malloc #allocating s7 bytes of memory
    mv s1, a0 #s1 = adress of input array

    mv a0, s7
    call malloc
    mv s2, a0 #s2 = address of output array

    mv a0, s7
    call malloc
    mv s3, a0 #s3 = adress of stack array

    li s4, -1 #s4 = index of top of stack

    #loading input into array

    li s7, 0 # i = 0

load_loop:
    bge s7, s0, load_done #i < s0(length of arr)

    addi t3, s7, 1
    slli t4, t3, 3 #t4 = byte location of arr[i] in argv(argv[i+1] whose adress in a1)
    add t5, s5, t4 #byte location in memory arg[i+1]
    ld a0, 0(t5)

    call atoi #convert string to integer

    slli t6, s7, 3
    add t0, s1, t6
    sd a0, 0(t0) #storing the integer in arr(s1)

    addi s7, s7, 1 #i++
    j load_loop

load_done:
    #now we will initialize output array to all -1
    li s7, 0 #i = 0

init_loop:
    bge s7, s0, init_done # i < s0
    slli t3, s7, 3
    add t4, s2, t3 #memory adrees of each element of output array
    li t5, -1
    sd t5, 0(t4)

    addi s7, s7, 1
    j init_loop

init_done:

    #main function

    addi s7, s0, -1 # i = n-1

for_loop:
    blt s7, zero, end_for # i >= 0

#while loop(while !stack.empty() and arr[stack.top()] <= arr[i])

while_loop:
    blt s4, zero, end_while

    slli t3, s4, 3
    add t4, t3, s3
    ld t5, 0(t4) #loaded stack.top() in t5

    slli t6, t5, 3
    add t0, t6, s1
    ld t3, 0(t0) #loaded arr[stack.top()] in t3

    slli t6, s7, 3
    add t0, t6, s1
    ld t4, 0(t0) #loaded arr[i] in t4

    ble t3, t4, do_pop
    j end_while
   
do_pop:
    addi s4, s4, -1
    j while_loop

end_while:

    #check if stack is empty, if not then store stack.top in result[i]

    blt s4, zero, if_empty_stack

    slli t3, s4, 3
    add t4, t3, s3
    ld t5, 0(t4) #loaded stack.top() in t5

    slli t6, s7, 3
    add t0, t6, s2
    sd t5, 0(t0) #saved t5 in output[i]

if_empty_stack:

    #push i

    addi s4, s4, 1 #increment top of stack

    #now store i in stack[topindex]

    slli t5, s4, 3
    add t3, t5, s3
    sd s7, 0(t3)

    addi s7, s7, -1
    j for_loop

end_for:

#print result

li s7, 0

print_loop:
    bge s7, s0, end_print

    slli t3, s7, 3
    add t4, s2, t3
    ld a1, 0(t4) #load each value of output array into a1, a1 = output[i]

    la a0, fmt
    call printf

    addi s7, s7, 1 #increment
    beq s7, s0, skip_space #if i = n-1, dont add space after the number

    la a0, space
    call printf

skip_space:
    j print_loop

end_print:
    la a0, newline
    call printf

    li a0, 0

    #return saved registers to original values

    ld s4, 0(sp)
    ld s3, 8(sp)
    ld s2, 16(sp)
    ld s1, 24(sp)
    ld s0, 32(sp)
    ld ra, 40(sp)
    ld s5, 48(sp)
    ld s6, 56(sp)
    ld s7, 64(sp)

    addi sp, sp, 80
    ret

