.section .text

.globl make_node
.globl insert
.globl get
.globl getAtMost

.extern malloc

#offsets
#val = 0
#left = 8
#right = 16

#total size of node = 24

#make node:
#a0 = val
#returns pointer in a0

make_node:
    addi sp, sp, -16
    sd ra, 8(sp)

    mv t0, a0 #saving val

    li a0, 24
    call malloc #malloc(24)

    mv t1, a0 #a0 = pointer to newly malloced memory

    sw t0, 0(t1) #node->val = val
    sd zero, 8(t1) #node->left = NULL
    sd zero, 16(t1) #node->right = NULL

    mv a0, t1 #pointer to root which is to be returned

    ld ra, 8(sp)
    addi sp, sp, 16
    ret

#insert node:
#a0 = root, a1 = val
#returns pointre in a0

insert:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)

    mv s0, a0

    beqz a0, insert_create #called if root is null, simply creates and returns node

insert_loop:
    lw t0, 0(a0)

    blt a1, t0, go_left
    bgt a1, t0, go_right
    j insert_done

go_left:
    ld t1, 8(a0) #left child
    beqz t1, insert_left_here #if left child is null

    mv a0, t1 #update root to left child of node
    j insert_loop

insert_left_here:
    mv t2, a0 #temporarily storing parent node
    mv a0, a1
    call make_node #inserting with val a1(moved to a0)
    sd a0, 8(t2) # a0 has pointer to newly inserted node
    j insert_return 

go_right:
    ld t1, 16(a0) #right child
    beqz t1, insert_right_here #if right child is null

    mv a0, t1 #update root to right child of node
    j insert_loop

insert_right_here:
    mv t2, a0 #temporarily storing parent node
    mv a0, a1
    call make_node #inserting with val a1(moved to a0)
    sd a0, 16(t2) # a0 has pointer to newly inserted node
    j insert_return

insert_create:
    mv a0, a1
    call make_node
    j insert_return

insert_return:
    mv a0, s0
    ld ra, 8(sp)
    ld s0, 0(sp)
    addi sp, sp, 16
    ret

#get node:
#a0 = root, a1 = val

get:
    #since get does not call any other function, no need to ssave registers on the stcak
    beqz a0, get_not_found

get_loop:
    lw t0, 0(a0)
    
    beq a1, t0, get_found #if equal to
    blt a1, t0, get_left #a1 less than node val
    bgt a1, t0, get_right #a1 more than node val

get_left:
    ld a0, 8(a0) #left child
    beqz a0, get_not_found
    j get_loop

get_right:
    ld a0, 16(a0) #right child
    beqz a0, get_not_found
    j get_loop

get_found:
    #a0 already stores the pointer to the node with val
    ret

get_not_found:
    li a0, 0 #returning null pointer if not found
    ret

#get at most:
#a0 = val, a1 = root

getAtMost:
    li t0, -1 #setting best result as -1

getAtMost_loop:
    beqz a1, getAtMost_done
    lw t1, 0(a1)

    ble t1, a0, getAtMost_update

    #go left if val is less than node
    ld a1, 8(a1)
    j getAtMost_loop

getAtMost_update:
    mv t0, t1 #update best value
    #now go right
    ld a1, 16(a1)
    j getAtMost_loop

getAtMost_done:
    mv a0, t0
    ret