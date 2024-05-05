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
  # TODO
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
   jr $ra

