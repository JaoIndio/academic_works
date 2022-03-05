

.text


startApp:
	addiu $t0, $zero, 0
loop:	
	addiu $t0, $t0, 1
	j loop
