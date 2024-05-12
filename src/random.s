# vim:sw=2 syntax=asm
.data
    
.text
  .globl gen_byte, gen_bit

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Compute the next valid byte (00, 01, 10) and put into $v0
#  If 11 would be returned, produce two new bits until valid
#


gen_byte:
    # initialize the stack pointer and check the first generated bit
   
    addi $sp , $sp , -4
    sw $ra , 0($sp)
    jal gen_bit
    move $t1 , $v0
 	
 	# get the second bit
    jal gen_bit
    move $t2 , $v0
    # do the magic
    and $t3 , $t1 ,$t2
    bnez $t3, gen_byte
    sll $v0 , $t1 ,1
    or $v0 , $v0, $t2
    lw $ra , 0($sp)
    addi $sp, $sp , 4
     
       
    jr $ra            # Return the generated byte



# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Look at the field {eca} and use the associated random number generator to generate one bit.
#  Put the computed bit into $v0

gen_bit:

    # some counter (the skip number) and the columnth column, we also need the length!
    lb $t7 , 8($a0) # length
    lw $t0 , 0($a0) #eca!
    lb $s4 , 10($a0) #skip!
    lb $s5 , 11($a0) #column!
    
#initialize the stack to keep us safe
    addi $sp , $sp , -8
    sw $a0 , 0($sp)
    sw $ra , 4($sp)
    
    is_eca_not_zero:  bnez $t0 , eca_gen_bit
#setting the seed
    
    lw $a1 , 4($a0)
    li $v0 , 40
    syscall
    
#generation of the random number
  
    li $a0, 0           
    li $v0, 41          
    syscall
    andi $v0 , $a0 , 1
    j terminate
    
    eca_gen_bit: beqz $s4, basically_done
    subi $s4 , $s4 , 1
    jal simulate_automaton
    j eca_gen_bit
    
    basically_done:
    # we have a new tape, we shift to the right by length - column, get the lsb, that is it.
    
    # get the new tape, in t6
    lw $t6 , 4($a0)
    sub $t7 , $t7 , $s5
    srlv $v0 , $t6 , $t7
    andi $v0 , $v0 , 1 
    
    
    
    
terminate:
    lw $a0, 0($sp)
    lw $ra , 4($sp)
    addi $sp, $sp , 8
    
    jr $ra    
  
 	
 	
