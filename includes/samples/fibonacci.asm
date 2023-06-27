#include "CH016M01.cpu"

; Reference addresses
OUT_REG = 0x7FFE

main:
.main_loop:
	; Initialize registers
	XOR	r0, r0
	LD	r1, 1
	ST	[OUT_REG], r0
	
..fib_loop:
	; Add registers
	ADD	r0, r1
	
	; Jump to main loop if overflowed.
	JC	.main_loop
	
	; XOR Swap
	XOR	r0, r1
	XOR	r1, r0
	XOR	r0, r1
	
	; Output Result
	ST	[BIN_TO_BCD], r1
	
	; Delay before jump
	NOP
	NOP
	NOP
	NOP
	NOP
	
	; Jump to fibonacci loop.
	JMP	..fib_loop
	
	; This should never happen
	XOR	r0, r0
	HLT
