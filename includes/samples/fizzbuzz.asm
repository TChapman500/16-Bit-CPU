; This code has not been tested.
print_fizzbuzz:
	LD	r11, 15
	LD	r12, 1
	LD	r13, 100
.main_loop:
	PUSH	r11
	PUSH	r12
	CALL	modulus
..switch_start:
	LD	r10, [r0 + ...switch_table]
	JMP	r10
...switch_table:
	#d16 ...fizzbuzz, ...default, ...default, ...fizz
	#d16 ...default,  ...buzz,    ...fizz,    ...default
	#d16 ...default,  ...fizz,    ...buzz,    ...default
	#d16 ...fizz,     ...default, ...default
...fizzbuzz:
	LD	r0, .FIZZBUZZ
	PUSH	r0
	CALL	printf
	JMP	..switch_end
...fizz:
	LD	r0, .FIZZ
	PUSH	r0
	CALL	printf
	JMP	..switch_end
...buzz:
	LD	r0, .BUZZ
	PUSH	r0
	CALL	printf
	JMP	..switch_end
...default:
	PUSH	r0
	LD	r0, .FORMAT
	PUSH	r0
	CALL	printf
..switch_end:
	INC	r12
	CMP	r12, r13
	JNG	.main_loop
	RET
.FIZZ:
	#d "Fizz\n\0"
.BUZZ:
	#d "Buzz\n\0"
.FIZZBUZZ:
	#d "FizzBuzz\n\0"
.FORMAT:
	#d "%d\n\0"
