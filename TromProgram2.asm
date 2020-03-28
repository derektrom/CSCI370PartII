#Derek Trom
#Program Excercise 2

.data
    p00:    	.asciiz    "\nStart Playing A Tic-Tac-Toe Game\n"
    p0:     	.asciiz    "\nContinue? (Y/N): "
    p1:     	.asciiz    "\nChoose X or O to start: "
    p3:     	.asciiz    "\nPlay again? (Y/N): "
    p4:    	.asciiz    "Hit the spacebar to start the System's next move.\n"
    p5:		.asciiz    "My Move is: "
    xWins: 	.asciiz    "You (X) win the match"
    oWins:      .asciiz    "You (O) win the match"
    compXWins:  .asciiz    "I (the System X) win!"
    compOWins:  .asciiz    "I (the System O) win!"
    Prompt:	.asciiz    "\nChoose a number 1-9 to play: " 
    wrong: 	.asciiz    "\nIncorrect input try again...\n"
    wrongPiece: .asciiz	   "\nInvalid piece...\n"
    spotTaken:	.asciiz    "\nSpot taken...\n"
    computerX:  .asciiz    "I (the System) am first and I pick X\n"
    computerO:  .asciiz    "I (the System) am first and I pick O\n"
    drawGame:   .asciiz    "It's a Draw!"
    board:  	.ascii     "\n\n        | |        1|2|3\n       -----       -----"
            	.ascii     "\n        | |        4|5|6\n       -----       -----"
            	.asciiz    "\n        | |        7|8|9\n"         
         
    boardArray: .byte      0,0,0,0,0,0,0,0,0 # used for moves made and checking win
    playerTurn:	.byte      0  # keeps track of if x or o turn
    comTurn: 	.byte      0  #if computer turn or not
    counter:   	.word      0  #game counter to keep track of how many moves made
    str1:       .space     2  #space for int input 
    winCounter: .word      0 #count num wins 
     
.text      
############## MAIN START #################### 
	main:
		la   $a0, p00 #welcome message
		li   $v0, 4   #print load       
		syscall       #call print          
     
     
		# choose user or system move first using randint function
		li $a1,2   #load 2 
		xor  $a0,$a0,$a0     # get seed number
		li   $v0,42    #random number generator
		syscall
		beq  $a0,$zero,computerChooseXO #if zero computer starts
#         
############# PLAYER STARTS ##################
#
	startingLoop:
		la   $a0, p1      # load player message
      		li   $v0, 4           
      		syscall           # print player msg
     
		# enter x or o
      		li $v0,12 #syscall for byte 
      		syscall

      		#check for valid x or o 
      		beq $v0,'X',xStarts
      		beq $v0,'x',xStarts
      		beq $v0,'O',oStarts
      		beq $v0,'o',oStarts

		
      		la   $a0, wrongPiece  #catch if not x or o
      		li   $v0, 4           
      		syscall               # print error message
      		j startingLoop #return to top of the loop
 

	# set tutn to X
	xStarts:
       		li   $t0,'X'
       		sb   $t0,playerTurn($zero)
       		li   $t0,'O'
       		sb   $t0,comTurn($zero)
       		j play #jump to play game
 
	# set turn to O
	oStarts:
       		li   $t0,'O'
       		sb   $t0,playerTurn($zero)
       		li   $t0,'X'
       		sb   $t0,comTurn($zero)
       		j  play #jump to play game
#
############### PLAY TIC-TAC-TOE #################
#
	play:
       		
       		lb   $t0,playerTurn($zero)   # whose turn
		
		# print board  
       		la   $a0, board       
       		li   $v0, 4           
       		syscall               
        	lb   $t0,playerTurn($zero)   # whose turn
        	lb   $t1,comTurn($zero)
        	beq  $t0,$t1,systemturn
        	jal loadConstants
        	b   storemove
        
#
############# COMPUTER STARTS ###################
#
	computerChooseXO:
       		li $a1,2  #number of choices
       		xor  $a0,$a0,$a0     # generate seed 
       		li   $v0,42  #random number generator
       		syscall
       		beq  $a0,$zero,computerIsX #if 0 computer will be x 
       		li   $t0,'O'    #system will be o else
       		sb   $t0,comTurn($zero) #load 0 for computer turn 
       		li   $t0,'O'
       		sb   $t0,playerTurn($zero)
       		la   $a0, computerO   #print message that computer is 0
       		li   $v0, 4           # print
       		syscall               
       		j play
 	computerIsX:
       		la   $a0, computerX       # print message computer is x
       		li   $v0, 4           # print syscal
       		syscall               
       		li   $t0,'X'
       		sb   $t0,comTurn($zero)
       		li   $t0,'X'
       		sb   $t0,playerTurn($zero)
       		j play #start playing game

	# get computer turn
	systemturn:
		#ask user to press space for next move
        	la   $a0, p4       # p4 load
        	li   $v0, 4           # syscall 4
        	syscall               # print 
     		#receive input
        	li   $v0, 12          # specify read string
        	syscall
        	li $t9, 32            #load 32 to t9  
     		bne $t9, $v0, notSpace #if not space entered then error 
        	jal computer         # system turn
        	move $t0,$v0
       
        	la   $a0, p5       # p5 message print My move is:
        	li   $v0, 4           # syscall 4
        	syscall               # print  
     
        	move   $a0, $t0       #move computer move to $a0
        	addi   $a0,$a0,1      #add one to account for array indexing 
        	li   $v0, 1           # print int
        	syscall               
       
        	move $v0,$t0	  #keep track of turn
        	
       
#
################## STORE PLAYER MOVE ######################
#
	storemove:
        	lb  $a0,playerTurn($zero)
        	sb  $a0,boardArray($v0)      # store move
		addi $v0, $v0, 1 #add one to match board place in $v0
		# place player    
        	jal offsetAndPlace #place piece on board
               
		# check for winner
        	jal   checkWin
        	beq   $v0,1,winner #if 1 in $v0 its a win
       
		# check for draw
        	lw    $t0,counter($zero) #load count
        	addi  $t0,$t0,1 #add 1
        	sw    $t0,counter($zero) #load to counter
        	beq  $t0,9,draw #if 9 moves made its a draw
		# switch turn
        	lb    $t0,playerTurn($zero)
        	beq   $t0,'X',oTurn
        	li    $t0,'X'
        	sb    $t0,playerTurn($zero)
       		jal continue #ask to continue
        	j     play # continue game
	# o's turn        
	oTurn:        
        	li    $t0,'O'
        	sb    $t0,playerTurn($zero)
        	j play     # continue game
#
############### CONTINUE? Y/N #################
#
#ask to continue
	continue:
		# print board  
       		la   $a0, board       
       		li   $v0, 4           
       		syscall 
		la   $a0, p0      # load player message
      		li   $v0, 4           
      		syscall           # print player msg
     
		# enter x or o
      		li $v0,12 #syscall for byte 
      		syscall

      		#check for valid y or n 
      		beq $v0,'Y',playYes
      		beq $v0,'y',playYes
      		beq $v0,'N',playAgain
      		beq $v0,'n',playAgain

		
      		la   $a0, wrong  #catch if not x or o
      		li   $v0, 4           
      		syscall               # print error message
      		j continue #return to top of the loop
      	playYes:
      		jr $ra

#
####################### DRAW GAME ########################
#
#ITS A DRAW       
	draw:
	# print board  
        	la   $a0, board       # first argument for print (array)
        	li   $v0, 4           # specify Print String service
        	syscall               # print message
     
        	la   $a0, drawGame        # point to drawgame message
        	li   $v0, 4           # specify Print String service
        	syscall               # print msg
        	j playAgain
#
################ WINNING GAME #################
#
#SOMEBODY WON
	winner:

		# print board  
      		la   $a0, board       # first argument for print (array)
      		li   $v0, 4           # specify Print String service
      		syscall               # print message
     		lb   $s6, playerTurn($zero) #load playerTurn
      		lb   $s5,comTurn($zero) #load com turn
        	beq  $s5,$s6,compWins #if they are the same it is computer turn
        	j    playerWins #else player won
        playerWins:
		# go to either player won x or o
      		beq $s6,'X',xwins     
      		beq $s6,'O',owins
      	compWins:
		#go to either computer won x or o
      		beq $s5,'X',computerXwins     # go to winner
      		beq $s5,'O',computerOwins
      		
#
################# X WINS ###################
#
#	
	computerXwins:
		#print computer won as x
      		la   $a0, compXWins        # load xWins message
      		li   $v0, 4           # syscall 4 to print
      		syscall               # print 
        	j playAgain	     #jump to play again questions
	xwins:
		#print player won as x
      		la   $a0, xWins        # load xWins message
      		li   $v0, 4           # syscall 4 to print
      		syscall               # print 
        	j playAgain	     #jump to play again questions
       
#
################# O WINS ###################
#
	computerOwins:
		#print computer won as O
      		la   $a0, compOWins        # load xWins message
      		li   $v0, 4           # syscall 4 to print
      		syscall               # print 
        	j playAgain	     #jump to play again questions
	owins:
		#print player won as o
      		la   $a0, oWins        # load oWins message
      		li   $v0, 4           # syscall 4 to print
      		syscall               # print 
        	j playAgain	      #jump to play again questions
       
#
################# CHECK FOR WIN ###################
#
#maybe some redundant code in here but I tried to make it smarter 	  
	checkWin:
		#check for wins
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $ra.
      		sw    $ra, ($sp)      # Push the return address, $ra to stack
     
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $t1.
      		sw    $t1, ($sp)      # Push the return address, $t1 to stack
     
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $t2.
      		sw    $t2, ($sp)      # Push the return address, $t2 to stack
     
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $t3.
     		sw    $t3, ($sp)      # Push the return address, $t3 to stack
     
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $t4.
      		sw    $t4, ($sp)      # Push the return address, $t4 to stack
     
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $t5.
      		sw    $t5, ($sp)      # Push the return address, $t5 to stack
     
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $t6.
      		sw    $t6, ($sp)      # Push the return address, $t6 to stack
           
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $t7.
      		sw    $t7, ($sp)      # Push the return address, $t7 to stack      
     
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $t8.
      		sw    $t8, ($sp)      # Push the return address, $t8 to stack
           
      		subu  $sp, $sp, 4     # Decrement the $sp to make space for $t9.
      		sw    $t9, ($sp)      # Push the return address, $t9 to stack
     
     
      		li   $v0,1              # assume turn wins
     
      		# get moves in registers to check for winning combinations
      		lb  $t1,boardArray($zero) #load move array[0]into $t1
      		lb  $t2,boardArray+1($zero)#load move array[1]into $t2
      		lb  $t3,boardArray+2($zero)#load move array[2]into $t3
      		lb  $t4,boardArray+3($zero)#load move array[3]into $t4
      		lb  $t5,boardArray+4($zero)#load move array[4]into $t5
      		lb  $t6,boardArray+5($zero)#load move array[5]into $t6
      		lb  $t7,boardArray+6($zero)#load move array[6]into $t7
      		lb  $t8,boardArray+7($zero)#load move array[7]into $t8
      		lb  $t9,boardArray+8($zero)#load move array[8]into $t9

        #rows check
        
	topRow: #win 1,2,3
      		bne $a0,$t1,topRow2  #if x(88)/o(79) not same
      		bne $a0,$t3,topRow2  #if x(88)/o(79) not same
      		bne $a0,$t2,topRow2  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	topRow2: #win 1,2,3
      		bne $a0,$t1,topRow3  #if x(88)/o(79) not same
      		bne $a0,$t2,topRow3  #if x(88)/o(79) not same
      		bne $a0,$t3,topRow3   #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	topRow3: #win 1,2,3
      		bne $a0,$t3,middleRow  #if x(88)/o(79) not same
      		bne $a0,$t2,middleRow  #if x(88)/o(79) not same
      		bne $a0,$t1,middleRow   #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
	middleRow: #win 4,5,6
      		bne $a0,$t4,middleRow2  #if x(88)/o(79) not same
      		bne $a0,$t6,middleRow2  #if x(88)/o(79) not same
      		bne $a0,$t5,middleRow2  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	middleRow2: #win 4,5,6
      		bne $a0,$t4,middleRow3  #if x(88)/o(79) not same
      		bne $a0,$t5,middleRow3  #if x(88)/o(79) not same
      		bne $a0,$t6,middleRow3  #if x(88)/o(79) not same
      		b popBackToCaller #else it is a win
      	middleRow3: #win 4,5,6
      		bne $a0,$t6,bottomRow  #if x(88)/o(79) not same
      		bne $a0,$t5,bottomRow  #if x(88)/o(79) not same
      		bne $a0,$t4,bottomRow  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
	bottomRow: #win 7,8,9
      		bne $a0,$t7,bottomRow2  #if x(88)/o(79) not same
      		bne $a0,$t8,bottomRow2  #if x(88)/o(79) not same
      		bne $a0,$t9,bottomRow2  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	bottomRow2: #win 7,8,9
      		bne $a0,$t7,bottomRow3  #if x(88)/o(79) not same
      		bne $a0,$t9,bottomRow3  #if x(88)/o(79) not same
      		bne $a0,$t8,bottomRow3  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	bottomRow3: #win 7,8,9
      		bne $a0,$t9,leftColumn  #if x(88)/o(79) not same
      		bne $a0,$t8,leftColumn  #if x(88)/o(79) not same
      		bne $a0,$t7,leftColumn  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
	# columns check
	leftColumn: #win 1,4,7
      		bne $a0,$t1,leftColumn2  #if x(88)/o(79) not same
      		bne $a0,$t4,leftColumn2  #if x(88)/o(79) not same
      		bne $a0,$t7,leftColumn2  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	leftColumn2: #win 1,4,7
      		bne $a0,$t1,leftColumn3  #if x(88)/o(79) not same
      		bne $a0,$t7,leftColumn3  #if x(88)/o(79) not same
      		bne $a0,$t4,leftColumn3  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	leftColumn3: #win 1,4,7
      		bne $a0,$t7,middleColumn  #if x(88)/o(79) not same
      		bne $a0,$t4,middleColumn  #if x(88)/o(79) not same
      		bne $a0,$t1,middleColumn  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
	middleColumn:#win 2,5,8
      		bne $a0,$t2,middleColumn2  #if x(88)/o(79) not same
      		bne $a0,$t5,middleColumn2  #if x(88)/o(79) not same
      		bne $a0,$t8,middleColumn2  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	middleColumn2:#win 2,5,8
      		bne $a0,$t2,middleColumn3  #if x(88)/o(79) not same
      		bne $a0,$t8,middleColumn3  #if x(88)/o(79) not same
      		bne $a0,$t5,middleColumn3  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	middleColumn3:#win 2,5,8
      		bne $a0,$t8,rightColumn  #if x(88)/o(79) not same
      		bne $a0,$t5,rightColumn  #if x(88)/o(79) not same
      		bne $a0,$t2,rightColumn  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
	rightColumn: #win 3,6,9
      		bne $a0,$t3,rightColumn2  #if x(88)/o(79) not same
      		bne $a0,$t6,rightColumn2  #if x(88)/o(79) not same
      		bne $a0,$t9,rightColumn2  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	rightColumn2: #win 3,6,9
      		bne $a0,$t3,rightColumn3  #if x(88)/o(79) not same
      		bne $a0,$t9,rightColumn3  #if x(88)/o(79) not same
      		bne $a0,$t6,rightColumn3  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	rightColumn3: #win 3,6,9
      		bne $a0,$t9,diagonal1  #if x(88)/o(79) not same
      		bne $a0,$t6,diagonal1  #if x(88)/o(79) not same
      		bne $a0,$t3,diagonal1  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
     
	# diagonals
	diagonal1: #win 1,5,9
      		bne $a0,$t1,diagonal12 #if x(88)/o(79) not same
      		bne $a0,$t5,diagonal12  #if x(88)/o(79) not same
      		bne $a0,$t9,diagonal12  #if x(88)/o(79) not same
      		j popBackToCaller
      	diagonal12: #win 1,5,9
      		bne $a0,$t1,diagonal123  #if x(88)/o(79) not same
      		bne $a0,$t9,diagonal123  #if x(88)/o(79) not same
      		bne $a0,$t5,diagonal123  #if x(88)/o(79) not same
      		j popBackToCaller #else a win
      	diagonal123: #win 1,5,9
      		bne $a0,$t9,diagonal2  #if x(88)/o(79) not same
      		bne $a0,$t5,diagonal2  #if x(88)/o(79) not same
      		bne $a0,$t1,diagonal2  #if x(88)/o(79) not same
      		j popBackToCaller #else a win
	
	diagonal2: #win 3,5,7
      		bne $a0,$t3,diagonal22  #if x(88)/o(79) not same
      		bne $a0,$t5,diagonal22  #if x(88)/o(79) not same
      		bne $a0,$t7,diagonal22  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	diagonal22: #win 3,5,7
      		bne $a0,$t3,diagonal223  #if x(88)/o(79) not same
      		bne $a0,$t7,diagonal223  #if x(88)/o(79) not same
      		bne $a0,$t5,diagonal223  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
      	diagonal223: #win 3,5,7
      		bne $a0,$t7,notWin  #if x(88)/o(79) not same
      		bne $a0,$t5,notWin  #if x(88)/o(79) not same
      		bne $a0,$t3,notWin  #if x(88)/o(79) not same
      		j popBackToCaller #else it is a win
     
	# no winner yet
	notWin:
      		li  $v0, 0 #set $v0 to 0 
     
	popBackToCaller:

     		lw    $t9, ($sp)       # Pop the return address, $t9.
     		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
     		lw    $t8, ($sp)       # Pop the return address, $t8.
     		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
     		lw    $t7, ($sp)       # Pop the return address, $t7.
     		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
     		lw    $t6, ($sp)       # Pop the return address, $t6.
     		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
     		lw    $t5, ($sp)       # Pop the return address, $t5.
     		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
     		lw    $t4, ($sp)       # Pop the return address, $t4.
     		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
     		lw    $t3, ($sp)       # Pop the return address, $t3.
     		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
     		lw    $t2, ($sp)       # Pop the return address, $t2.
     		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
     		lw    $t1, ($sp)       # Pop the return address, $t1.
     		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
      		lw    $ra, ($sp)       # Pop the return address, $ra.
      		addu  $sp, $sp, 4      # add unsigned 4 to $sp
     
      		jr    $ra #return to caller
#
################# PLAY AGAIN? Y/N ###################
#	
	playAgain:
      		la    $a0, p3        # point to p3
      		li    $v0, 4         #load syscall 4
      		syscall             
       
      		# enter y or n
      		li    $v0,12
      		syscall

		# validate entry
      		beq    $v0,'Y',newgame
      		beq    $v0,'y',newgame
      		beq    $v0,'N',exit
      		beq    $v0,'n',exit
      		la     $a0, wrong    # catch wrong entry message 
      		li     $v0, 4           
      		syscall 
      		j playAgain	#jump to top of play again

#
################# NEW GAME RESETS ###################
#
	newgame:  
     		#reset the board and moves array
     		#replace all move spaces with blank in the board
       		li     $s0, ' '
    		li     $s2, 9
    		sb     $s0, board($s2) 
    		li     $s2, 11
    		sb     $s0, board($s2)
    		li     $s2, 13
    		sb     $s0, board($s2)  	
    		li     $s2, 59
    		sb     $s0, board($s2)   	
    		li     $s2, 61
    		sb     $s0, board($s2)	
    		li     $s2, 63
    		sb     $s0, board($s2)    	
    		li     $s2, 109
    		sb     $s0, board($s2)   	
    		li     $s2, 111
    		sb     $s0, board($s2)   	
    		li     $s2, 113
    		sb     $s0, board($s2)
      		# clear moves in board array
      		sb     $zero,boardArray($zero)
      		sb     $zero,boardArray+1($zero)
      		sb     $zero,boardArray+2($zero)
      		sb     $zero,boardArray+3($zero)
      		sb     $zero,boardArray+4($zero)
      		sb     $zero,boardArray+5($zero)
      		sb     $zero,boardArray+6($zero)
      		sb     $zero,boardArray+7($zero)
      		sb     $zero,boardArray+8($zero)

      		# clear counter to 0
      		sw     $zero,counter($zero)
                 
      		j      main #back to main to restart

#
################# GET PLAYER MOVE ###################
# 
#Players move functions and blocks    	
	loadConstants:
		li    $t1,'X'
      		li    $t2,'O'
        	li    $t8, 49 #used to test if the number is less than 9
        	li    $s1, 57
	getMove:      
		lb   $t0,playerTurn($zero)    # get turn
	
        	la   $a0, Prompt        # first argument for print (array)
        	li   $v0, 4           # specify Print String service
        	syscall               # print message
        	
        	#get integer input
		li    $v0, 8  #receive input
        	la    $a0, str1 #store in str1
        	li    $a1, 2 #allocate space for input
        	move  $s7, $a0  #move response to $t7
        	syscall
		lb    $s7, 0($s7) 
        	bgt   $s7, $s1, errorInt  #catch if > 9
        	blt   $s7, $t8, errorInt  #catch if < 1
        	subi  $v0, $s7, 48
        	subi  $v0,$v0,1 # decrement to match moves array
        	lb    $t5,boardArray($v0)
        	bne   $t5,$zero,takenSpot #else move cant be used
        	jr    $ra #return to caller
       
#	
###################ERROR BLOCKS##################
#
# NUMBER, SPACE, AND OTHER ERROR
	errorInt:
        	la   $a0, wrong     # first argument for print (array)
        	li   $v0, 4           # specify Print String service
        	syscall               # print message
        	j loadConstants
        notSpace:
        	la   $a0, wrong     # first argument for print (array)
        	li   $v0, 4           # specify Print String service
        	syscall               # print message
        	j systemturn
         
	takenSpot:
        	la   $a0, spotTaken      # first argument for print (array)
        	li   $v0, 4           # specify Print String service
        	syscall               # print message
        	j loadConstants
        
#
##################### COMPUTER MOVE ##########################################
#	
#Computer functions and blocks
#Win first, block second, one-step ahead, and random
	foundPossibleWin:
 		j computeReturnAddress
	computer:

        	subu  $sp, $sp, 4     # Decrement the $sp to make space for $ra.
        	sw    $ra, ($sp)      # Push the return address, $ra.
      		li    $t1,0              # start from move 0
	findWin: 
       		lb    $t2,boardArray($t1)     # check if move open
       		bne   $t2,$zero,notWinner     # move is open if move == 0
       		lb    $a0,playerTurn($zero) #simulate player turn
       		sb    $a0,boardArray($t1) #store the players turn in board
       		jal   checkWin
                # check if win for player
       		sb    $zero,boardArray($t1)   # store a zero back in simulated move
       		beq   $v0,0,notWinner #if $v0 contains 0 that move is not a win
       		move  $v0,$t1            # winner found
       		j     computeReturnAddress
	notWinner:
        	# find a blocking move
        	addu  $t1,$t1,1
        	blt   $t1,10,findWin #if moves not exhausted go back to top
        	lb    $a0,playerTurn($zero) #load what piece turn it is 
        	beq   $a0,'X',pieceX #if x switch
        	li    $a0,'X' #else load x to a0
        	j     notPieceX #o piece
	pieceX:   
        	li    $a0,'O' #load O piece to a0
	
	notPieceX:  
        
        	li    $t1,0  #restart at 0 to find a blocking move 
        	
	findBlock: 
		
		lb    $t2,boardArray($t1)  # load move to $t2   
       		bne   $t2,$zero,notBlock #branch if != 0 spot taken
       		sb    $a0,boardArray($t1) #store x or o in $a0
       		jal   checkWin #check if it is a win
       		sb    $zero,boardArray($t1) #if returns as not a win store 0 in move
       		beq   $v0,0,notBlock  #if is is 0 no blocking move
       		move  $v0,$t1 #move to $v0
       		j     computeReturnAddress
	notBlock:
       		addu  $t1,$t1,1 #increment counter
       		blt   $t1,10,findBlock
       		li    $t1, 0 #reset to do one step look ahead
        findOneAhead: 
       		lb    $t2,boardArray($t1)     # check if move open
       		bne   $t2,$zero,notOneAhead     # move is open if move == 0
       		lb    $a0,playerTurn($zero) #simulate player turn
       		sb    $a0,boardArray($t1) #store the players turn in board
       		li    $s3, 0 #initialize second counter for lookahead
       		b     secondMark ##start second mark
                		
	secondMark:
		#check for a second mark as win
		lb    $t2,boardArray($s3)     # check if move open
       		bne   $t2,$zero,notSecondMark #taken
       		jal   checkWin #check for win
       		sb    $zero,boardArray($t1)   # store a zero back in simulated move
       		beq   $v0,0,notSecondMark #if $v0 contains 0 that move is not a win
       		           
       		b     foundPossibleWin # winner found leave in board and return to caller
       		
       		
       	notSecondMark:
       		addu  $s3,$s3,1
        	blt   $s3,10,secondMark #if moves not exhausted go back to top
        	j notOneAhead
	
	notOneAhead:
        	# find a blocking move
        	addu  $t1,$t1,1
        	blt   $t1,10,findOneAhead #if moves not exhausted go back to top
 		
 		# pick a random move
       		li    $t1,9 #load upper bound
       		lb    $t0,counter($zero)  # calculate n
       		sub  $a1,$t1,$t0 #subract t0 and t1
       		xor  $a0,$a0,$a0     # get random number 0 to n
       		li   $v0,42 #syscal for random number
       		syscall
       
       		li    $t1,0             # count down random number
       		move  $t0,$a0           # get random number
	# count down random number
	randomMove: 
        	lb    $t2,boardArray($t1)    #load array[$t1] to $t2
        	bne   $t2,$zero,randomTaken    #spot already taken
        	move  $v0,$t1    #move t1 to v0
        	beq   $t0,$zero,computeReturnAddress #spot not taken 
        	subi  $t0,$t0,1 #subtract one from $t0
	randomTaken:  
        	addi  $t1,$t1,1 #add 1 to t1
        	b randomMove  #back to top of randomMove
	computeReturnAddress: 
        	lw    $ra, ($sp)       # Pop the return address, $ra.
        	addu  $sp, $sp, 4      # Increment the $sp.
        	jr    $ra  #return to original caller
#
################# PLACING PIECE ###################
#
	offsetAndPlace:
        	#to load into board
        	lb    $a0,playerTurn($zero) # load turn
        	move  $t0, $v0   #move number choice to $t0
    		move  $t1, $v0   #move number choice to $t1
    		sub   $t0, $t0, 1  #minus 1
    		div   $t0, $t0, 3  #divide by three
    		mul   $t0, $t0, 44  #multiply by 44
    		mul   $t1, $t1, 2   #$t1 X 2
    		add   $t1, $t1, 7   #add 7 to $t1
    		add   $t0, $t1, $t0 #add $t1 and $t0
        	sb    $a0, board($t0)  # Store the marker in the board
        	jr    $ra # return to caller
	
#
################# EXIT BLOCK ###################
#                               
	exit:
      		li   $v0, 10          # system call for exit
      		syscall               
