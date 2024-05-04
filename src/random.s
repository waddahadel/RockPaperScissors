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
    lw $ra , 0($sp)
    addi $sp, $sp , 4
    
 
  # grab the second random bit, do the magic of the hirarchy with bitwise ops
    addi $sp , $sp , -4
    sw $ra , 0($sp)
    jal gen_bit
    move $t2 , $v0
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
#initialize the stack to keep us safe
    addi $sp , $sp , -8
    sw $a0 , 0($sp)
    sw $ra , 4($sp)
#setting the seed
    
    lw $a1 , 4($a0)
    li $v0 , 40
    syscall
    
#generation of the random number
  
    li $a0, 0           
    li $v0, 41          
    syscall
    
    andi $v0 , $a0 , 1
    
    lw $a0, 0($sp)
    lw $ra , 4($sp)
    addi $sp, $sp , 8
    
    jr $ra    
  
 	
 	