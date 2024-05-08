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
  # Load necessary values from configuration
  lw $t1, 4($a0)      # Load tape
  lb $t2, 8($a0)      # Load tape_len
  lb $t3, 9($a0)      # Load rule
  
  # Create a mask to extract neighborhoods
  li $t4, 7           # Mask for 3 bits (111)
  
  # Create variables for current and next generation tapes
  move $t5, $t1       # Current generation tape
  move $t6, $zero     # Next generation tape
  
  # Loop through each cell in the tape
  li $t0, 0           # Initialize counter
  loop_simulate:
    bge $t0, $t2, terminate_loop   # If reached tape_len, terminate
    
    # Extract the neighborhood
    and $t7, $t1, $t4      # Extract 3 bits neighborhood
    andi $t7, $t7, 7       # Ensure we only consider 3 bits
    
    # Apply rule to determine next state
    andi $t8, $t3, 1       # Extract LSB of rule
    srl $t3, $t3, 1        # Shift right to process next neighborhood
    add $t0, $t0, 1        # Increment counter
    
    # Update next generation tape
    sll $t6, $t6, 1        # Shift left to make space for next cell
    or $t6, $t6, $t8       # Set the bit according to the rule
    
    # Move to next cell
    srl $t1, $t1, 1        # Shift tape to the right
    
    # Repeat loop
    j loop_simulate
    
  # Terminate loop
  terminate_loop:
    # Store next generation tape back to memory
    sw $t6, 4($a0)
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
   jr $ra

