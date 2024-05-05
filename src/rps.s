# vim:sw=2 syntax=asm
.data
	W : .asciiz "W"
	T : .asciiz "T"
	L : .asciiz "L"
.text
  .globl play_game_once

# Play the game once, that is
# (1) compute two moves (RPS) for the two computer players
# (2) Print (W)in (L)oss or (T)ie, whether the first player wins, looses or ties.
#
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, only print either character 'W', 'L', or 'T' to stdout
play_game_once:
  
  # free up the stackpointer to keep the $ra pointing to the right spot at first
  # and get the move of player 1
  addi $sp , $sp , -4
  sw $ra , 0($sp)
  
  jal gen_byte
  move $t1 , $v0
  
  lw $ra , 0($sp)
  addi $sp, $sp , 4
  
  # do the same again to get the move of player two
  
  addi $sp , $sp , -4
  sw $ra , 0($sp)
  
  jal gen_byte
  move $t2 , $v0
  
  lw $ra , 0($sp)
  addi $sp, $sp , 4

  
  #case distinguishing
  beqz $t1 , cases_of_rock
  beq $t1 , 1, cases_of_paper
  beq $t1 , 2 , cases_of_scissors
  
  
  
  #basic algorithm
cases_of_rock:
	# just a register to implement the logic, maybe I'm writing too much code here, who knows?
	sub $t3 , $t2 , $t1
	beq $t1 , $t2 , tie
	beq $t3 , 2 , win
	bne $t3 , 2, lose
	
	
cases_of_paper:
	beq $t1 , $t2 , tie
	beqz $t2 , win
	bgt $t2 , $t1 , lose

cases_of_scissors:
	beq $t1, $t2 , tie
	#introduce a dummy variable again
	sub $t4 , $t1 , $t2
	beq $t4 , $t1 , lose
	bne $t4 , $t1 , win

#winner winner chicken dinner?
win:
    la $a0 , W 
    j terminate
lose:
    la $a0, L
    j terminate
tie:
    la $a0 , T
    j terminate
    
    
#print the statement and terminate

terminate:
  li $v0 , 4
  syscall
  
  jr $ra
