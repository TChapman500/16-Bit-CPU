; Instruction Format for the P16A01
; Instructions are 2 bytes (16 bits) in size.  The high byte is the
; opcode while the low byte is divided into the X and Y operands.
; For the low byte, the low nibble is the X operand while the high
; nibble is the Y operand.

; OPCODE y, x
; CPU Control
00	0, 0		NOP
01	0, 0		BRK
02	0, 0		HLT

; Interrupt Handling
03	0, 0		ISR	edge, imm16
03	1, 0		ISR	level, imm16
04	0, 0		SINT	0
04	1, 0		SINT	1
05	0, 0		INT
06	0, 0		RTI

; Functions
07	0, 0		CALL	imm16
07	1, X		CALL	rX
08	0, 0		RET

; Branching
09	Y, 0		Jyy	imm16
0A	Y, X		Jyy	rX

; Loops
0B	Y, X		LOOP	rX, rY, imm16
0C	Y, X		LOOPD	rX, rY, imm16
0D	0, X		LOOPZ	rX, imm16

; Stack Management
0E	0, X		PUSH	rX
0E	1, 0		PUSH	flags
0F	0, X		POP	rX
0F	1, 0		POP	flags

; Register Copy
10	0, X		MOV	rX, flags
10	1, X		MOV	flags, rX
11	Y, X		MOV	rX, rY

; Load Data
14	0, X		LD	rX, imm16
15	0, X		LD	rX, [imm16]
16	Y, X		LD	rX, [rY]
17	Y, X		LD	rX, [rY + imm16]
19	0, X		LDP	rX, [imm16]
1A	Y, X		LDP	rX, [rY]
1B	Y, X		LDP	rX, [rY + imm16]

; Store Data
1D	0, X		ST	[imm16], rX
1E	Y, X		ST	[rY], rX
1F	Y, X		ST	[rY + imm16], rX
21	0, X		STP	[imm16], rX
22	Y, X		STP	[rY], rX
23	Y, X		STP	[rY + imm16], rX

; Extended Bit-Specific Memory Mapping
2E	0, X		EBIA	rX, imm16
2F	Y, X		EBIA	rX, rY

; Bit-Specific Instructions
30	Y, X		CBI	rX, rY
31	Y, X		SBI	rX, rY
32	Y, X		TBI	rX, rY
33	Y, X		IBI	rX, rY
34	Y, X		CBI	rX, Y
35	Y, X		SBI	rX, Y
36	Y, X		TBI	rX, Y
37	Y, X		IBI	rX, Y

; Extended Bit-Specific Instructions
38	Y, X		CBIX	rX, rY
39	Y, X		SBIX	rX, rY
3A	Y, X		TBIX	rX, rY
3B	Y, X		IBIX	rX, rY
3C	Y, X		CBIX	rX, Y
3D	Y, X		SBIX	rX, Y
3E	Y, X		TBIX	rX, Y
3F	Y, X		IBIX	rX, Y

; Arithmetic Instructions
40	Y, X		ADD	rX, rY
41	Y, X		ADC	rX, rY
42	0, X		INC	rX
43	0, X		ABS	rX
44	Y, X		SUB	rX, rY
45	Y, X		SBB	rX, rY
46	0, X		DEC	rX
47	0, X		NEG	rX

; Logic Instructions
48	Y, X		AND	rX, rY
49	Y, X		OR	rX, rY
4A	Y, X		XOR	rX, rY
4B	Y, X		NOT	rX

; Shift Instructions
4C	Y, X		SHR	rX, rY
4D	Y, X		SHR	rX, Y
4E	Y, X		SAR	rX, rY
4F	Y, X		SAR	rX, Y
50	Y, X		SHL	rX, rY
51	Y, X		SHL	rX, Y
52	Y, X		SAL	rX, rY
53	Y, X		SAL	rX, Y

; Rotate Instructions
54	Y, X		ROR	rX, rY
55	Y, X		ROR	rX, Y
56	Y, X		ROL	rX, rY
57	Y, X		ROL	rX, Y

; Compare Instructions
58	Y, X		CMP	rX, rY
59	Y, X		CMPS	rX, rY
5A	Y, X		TEST	rX, rY
5B	0, X		TEST	rX