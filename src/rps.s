# vim:sw=2 syntax=asm
.data
	playersArray: .space 8 #12 bytes for 3 integers 
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

    addi $sp , $sp , -4
    sw $ra , 0($sp)

    li $t0 , 0 # index at our array
    li $s3, 2 # loop counter
loop:
  beqz $s3, start_excecuting
  subi $s3 $s3 1
  jal gen_byte
  sw $v0, playersArray($t0) #Store contents of the result in first position of array 
  addi $t0, $t0, 4 #increment the index by 4
  j loop
  
  
 

 
start_excecuting:
li $t5 , 4
  lw $t1, playersArray($zero) #load the word in the first location of myArray into $t1
  lw $t2 , playersArray($t5)
  
 
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
  
    lw $ra , 0($sp)
    addi $sp, $sp , 4
  
  jr $ra
