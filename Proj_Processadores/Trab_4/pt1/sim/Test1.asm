.text

	li $t1, 2147483648
	li $t2, 2
	
	multu $t1, $t2
	divu $t1, $t2
	
	mfhi $t3
	mflo $t4
	
	li $t2, 3
	
	multu $t1, $t2
	divu $t1, $t2
	
	mfhi $t3
	mflo $t4
