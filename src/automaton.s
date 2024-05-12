# vim:sw=2 syntax=asm
.data
     x : .asciiz "X"
     underscore : .asciiz "_"
.text
  .globl simulate_automaton, print_tape

# Simulate one step of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, but updates the tape in memory location 4($a0)
simulate_automaton:
    addi $sp , $sp , -8
    sw $ra , 0($sp)
    sw $s0 , 4($sp)
    # Load the arguments into registers
    lw $t1, 4($a0)       # Load tape (1 word)
    lb $t2, 8($a0)       # Load tape_len (1 byte)
    lb $t3, 9($a0)       # Load rule (1 byte)

    move $t6 , $zero # this is our new tape.
    move $t4 , $zero   #our counter
    subi $t2 , $t2 , 1 # for convenience. 
    
    initial_loop:
    
    	beqz $t4 , handle_first_digit # we are handeling the first digit.
    	beq $t4 , $t2 , handle_last_digit # we are handeling the first digit.
    	# normal digits (middle digits handeling)
    	# first we will hendle intermediate results with $t5 , 
    	# the idea is quite simple, shift to the right with the amout of t4
    	# mask out the first three digits, if the digit indexed with their value in the rule is 1,
    	# then we mark one, 
    	# else we mark with zero.
    	# how much should we shift? 
    	sub $t7 , $t4 , 1
    	srlv $t5 , $t1 , $t7  # shifting to the right by the certain amount, store the intermediate result here.
    	andi $t5 , 7 # getting the three first digits
    	#again we shift the rul by t5 bits to get the bit to compare with I will use t0 for this
    	
    	srlv $t0, $t3, $t5 # now we have it
    	
    	andi $t0 , 1 # we extract it (it's the lease significant bit)
    	# now whatever it's we just add it to that position of the tape! just a left shift, an or,and it's done.
    	sllv $t0 , $t0 , $t4 # adjust it
    	or $t6 , $t6 , $t0 # now just add it to that position in the new cell.
    	# increment our counter and go back again
    	addi $t4 , $t4 , 1
    	
    	j initial_loop
    	    	
    	
    handle_first_digit:
        # here , it's a bit complicated, but we will get it done.
        # extract the first two digits
         andi $t5, $t1 , 3
         sll $t5 , $t5 , 1 #shift to the left to make space
         # to get the most significant bit, we shift right by the amount of t2
         srlv $t7 , $t1 , $t2 # its in t7
         andi $t7 , $t7 , 1
         # or them
         or $t5 , $t5 , $t7 
         # do the check, increment the counter and go back. 
         #again we shift the rule by t5 bits to get the bit to compare with I will use t0 for this
    	
    	srlv $t0, $t3, $t5 # now we have it
    	
    	andi $t0 ,$t0, 1 # we extract it (it's the least significant bit) , note that we do the or directly, it's the first  bit !   
        
        or $t6 , $t6 , $t0 # now just add it to that position in the new cell.
    	# increment our counter and go back again
    	addi $t4 , $t4 , 1
    	
    	j initial_loop
    
    handle_last_digit:
         #it's also a bit complicated, but maybe simpler than the first bit?
         # first grab the lsb
         andi $t5 , $t1 , 1
         # move by two to the left to make space!
         sll $t5 , $t5 , 2
         # we use our t4 to get the amount of shifts we need , t2 - 1
         subi $t4 , $t4, 1
         # shift to the right by that amount.
         srlv $t7 , $t1 , $t4
         # extract the two last digits
         andi $t7 , 3
         # or with t5
         or $t5 , $t5 , $t7
         
         # reqular routine, except that we will terminte!
         #again we shift the rul by t5 bits to get the bit to compare with I will use t0 for this
    	
    	srlv $t0, $t3, $t5 # now we have it
    	
    	andi $t0 ,$t0 ,  1 # we extract it (it's the lease significant bit)
    	# now whatever it's we just add it to that position of the tape! just a left shift, an or,and it's done.
    	# here it's the msb, 
    	sllv $t0 , $t0 , $t2 # adjust it
    	or $t6 , $t6 , $t0 # now just add it to that position in the new cell.
    	
    	#store the result in the desired memory location.
    	
    	sw $t6 , 4($a0)
    	li $t6 , 0
    	#move $a0 , $t6
    	#li $v0 , 1
    	#syscall
         
         lw $ra , 0($sp)
         lw $s0 , 4($sp)
         addi $sp, $sp , 8
    
    	 jr $ra
    

# Print the tape of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return nothing, print the tape as follows:
#   Example:
#       tape: 42 (0b00101010)
#       tape_len: 8
#   Print:  
#       __X_X_X_
print_tape:
    addi $sp , $sp , -8
    sw $ra , 0($sp)
    sw $s0 , 4($sp)
  # hold the value of the tape
  lw $t1 , 4($a0)
  # hold the length of the tape
  lb $s0, 8($a0)
  #looping and printing 
  loop:
    beqz $s0 , terminate #break the loop
    sub $s0 , $s0 , 1 #to ensure termination
    srlv $t2 , $t1 , $s0 #making our desired bit in the lsb position starting form left to right!
    andi $t2 , $t2 , 1 #extract the lsb , which denotes if the cell is dead or alive!
    beqz $t2 , printUnderscore
    
    
  
  printX:
    la $a0 , x 
    li $v0 , 4
    syscall
    j loop
  printUnderscore:
    la $a0 , underscore 
    li $v0 , 4
    syscall
    j loop
  terminate:
  # Print newline character
    li $v0, 11       # syscall 11 prints a character
    li $a0, '\n'     # ASCII value for newline character
    syscall
    
    lw $ra , 0($sp)
    lw $s0 , 4($sp)
    addi $sp, $sp , 8
   jr $ra

