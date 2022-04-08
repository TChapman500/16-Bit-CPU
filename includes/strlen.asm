strlen:
	XOR	r0, r0		; Return Value
	PUSH	r1
	PUSH	r2
	LD	r2, [r15 + 3]	; Load char*
.main_loop:
	LD	r1, [r2]	; Load char
	TEST	r1
	JLZ	.loop_end
	INC	r0
	TEST	r1
	JHZ	.loop_end
	INC	r0
	INC	r2		; Increment char*
	JMP	.main_loop
.loop_end:
	POP	r2
	POP	r1
	RET
