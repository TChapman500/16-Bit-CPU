# 16-Bit CPU
This CPU circuit was made using [Logisim Evolution (Holy Cross Edition)](https://github.com/kevinawalsh/logisim-evolution) (v4.0.4).  The circuit might work in the original [Logisim Evolution](https://github.com/kevinawalsh/logisim-evolution), but I have not tested that.  This CPU was implemented with an FPGA in mind, so there is no microcode in the circuit, and there is only one tri-state buffer, which is on the main data bus just before the data leaves the CPU.

## Architecture
This CPU has a 16-bit data bus and a 16-bit address bus.  Non-pipelined versions of the processor have a 4-step stepper to control the sequence of the internal and external control signals.  Also, on non-pipelined versions of the CPU, the line for the first step of the stepper is exposed to the outside environement through a buffer.

### Interrupts
Interrupts are triggered when the interrupt line is held high and the stepper is reset to step 1, or when the `INT` instruction is called.  When this happens, the flags register is pushed to the top of the stack followed by the program counter, and interrupts are disabled.  Interrupts should not be re-enabled until the interrupt service routine (ISR) returns with an `RTI` instruction.  When the ISR returns, the stack is first popped to the program counter, then to the flags register.  The interrupt signal itself is sampled on the rising edge of every system clock pulse.  But if the interrupt signal goes low before the stepper resets or rolls over to step 1, then the interrupt is not triggered.

The Interrupt Service System (ISS) register is an 18-bit register that holds the 16-bit address of the Interrupt Service Routine (ISR), the state of the instruction signal (sampled on the rising edge of every clock pulse), and the enable state of interrupts (enabled or disabled).  The only register that the ISS can output to is the program counter.  And it is only able to be written to through the `ISR` instruction (to set the address of the ISR), and the `INT 1` and `INT 0` instructions (to enable and disable interrupts respectively).

### Registers
Other than the ISS, this processor has 5 types of registers for different purposes that can be accessed directly or indirectly through software (including the ISS mentioned above).  Most of these registers are 16-bit registers.

#### Register File
The register file is a group of 16, 16-bit registers which can be directly accessed through software and supports all types of data transfers.  The register file directly supports load and store operations, stack operations, and copy operations between registers within the register file, and the flags register.  The register file can also send data to the address bus and the program counter.  And the Arithmatic Logic Unit (ALU) will perform various types of operations on the register file, and store the result in the register file.

Registers in the register file are accessed through the X and Y operands of many instructions as `rX` or `rY` where `X` and `Y` is the index of the register to be accessed and is substituted for a number from `0` to `15`.  For example, `r5` would be the register with an index number of 5.

##### Stack Pointer
`r15` is the stack pointer.  If your program uses interrupts, functions, or does other operations that utilizes the stack, then this register holds the address of the top of the stack.  It should be initialized so that the address starts 1 byte below where the bottom of the stack is.  The value of the stack pointer decreases as the stack grows and increases as the stack shrinks.  The value of the stack pointer is always the address of the last value copied to the stack.

Use of the stack pointer is technically optional if your program does not use interrupts or fuctions, or the `PUSH` or `POP` instructions.  When this is the case, you may use `r15` just like any other register.  Even when used as a stack pointer, standard arithmatic operations can still be performed on `r15` for purposes of stack allocation and clean-up.  The stack pointer has no hardware protection against stack overflow, underflow, or non-stack operations being performed on it.

#### Program Counter
The program counter is a 16-bit register that stores the address of the next instruction to load.  Software cannot access this register directly, but can modify the contents through the `Jyy` (jump), `CALL`, `INT`, `RET` and `RTI` instructions.  The program counter is automatically incremented at the rising edge of the clock when the stepper is at step 1, and when loading the immediate byte on step 2.  The program counter cannot be copied to any other register in the processor, and can only output to the data bus and the address bus.

#### Flags Register
The flags register is a 2-bit register that used by the Arithmatic Logic Unit (ALU) for reading and writing, and by the `Jyy` (jump) instructions to determine if a jump should take place.  All operations performed by the ALU will write to the flags register, even if the ALU does not write to the register file.  The flags register is zero-extended to 16-bits when copied to the register file or to the stack.  Software cannot access this register directly except to copy data between the flags register and the register file, or between the flags register and the stack through the `PUSH` and `POP` instructions.  When copying data to the flags register, only the two least significant bits are written.  The first bit of the flags register is the carry flag.  The second bit is the zero flag.

#### Immediate Register
The immediate register is a 16-bit register that can only be written to by instructions that need to load the immediate byte, but cannot load it into another register.  The contents of this register are only valid for the duration that the instruction that loaded it is being executed.  Software cannot read the value of this register, and this register can only output to the address bus or program counter.

## Instruction Set
Each instruction has an 8-bit opcode on the upper half of the instruction byte, and two, 4-bit embeded operands on the lower half of the instruction byte.  The X operand takes up the lower half of the operand space while the Y operand takes up the upper half of the operand space.  Some instructions have a 16-bit immediate byte following the instruction byte.  Any instruction that is not implemented will be interpreted as a `NOP` instruction.

The format of the instruction byte is as follows (binary format):
`ooooooooYYYYXXXX`
`o` = Opcode
`Y` = Y Embeded Operand
`X` = X Embeded Operand

### `NOP` (No Operation)
Does nothing.

| Assembly | Opcode   |
| -------- | -------- |
| `NOP`    | `0x00`   |

### `ISR` (Interrupt Service Routine)
Sets the address of the interrupt service routine (interrupt handler) with the immediate byte being the address of the function to serve as the ISR.  The ISR must use the `RTI` instruction to return rather than the `RET` instruction.

| Assembly    | Opcode   |
| ----------- | -------- |
| `ISR imm16` | `0x01`   |

### `INT` (Interrupt)
Enables or disables the interrupt service system (ISS) or calls the ISR.  These instructions should never be used inside the interrupt handler.  When the ISR is called, interrupts are disabled until the ISR returns through the `RTI` instruction.

| Assembly | Opcode   | Y Op   | Description         |
| -------- | -------- | ------ | ------------------- |
| `INT 0`  | `0x02`   | `0x0`  | Disables Interrupts |
| `INT 1`  | `0x02`   | `0x1`  | Enables Interrupts  |
| `INT`    | `0x03`   |        | Calls ISR           |

### `CALL` (Call Function)
Calls a function (not the ISR) either using the immediate byte as the address of the target function, or the value of a register in the register file as the address of the target instruction.  All functions called through this instruction must use `RET` to return.

| Assembly      | Opcode   | Y Op   | Description                           |
| ------------- | -------- | ------ | ------------------------------------- |
| `CALL imm16`  | `0x04`   | `0x0`  | Direct call using immediate byte      |
| `CALL rX`     | `0x04`   | `0x1`  | Indirect call using the value in `rX` |

### `RET` (Return from Function)
Returns from a function entered through the `CALL` instruction.

| Assembly      | Opcode   | Y Op   |
| ------------- | -------- | ------ |
| `RET`         | `0x05`   | `0x0`  |

### `RTI` (Return from ISR)
Returns from the interrupt service routine/interrupt handler function (ISR).  This instruction may not be used in any function entered through `CALL`.

| Assembly      | Opcode   | Y Op   |
| ------------- | -------- | ------ |
| `RET`         | `0x05`   | `0x1`  |

### `LD` (Load)
Loads a byte into a register in the register file from memory.

| Assembly              | Opcode   | Description                                                                                  |
| --------------------- | -------- | -------------------------------------------------------------------------------------------- |
| `LD rX, imm16`        | `0x08`   | Loads the immediate byte into `rX`.                                                          |
| `LD rX, [imm16]`      | `0x09`   | Uses the immediate byte as a pointer to the data to be loaded into `rX`.                     |
| `LD rX, [rY]`         | `0x0A`   | Uses the value of `rY` as a pointer to the data to be loaded into `rX`.                      |
| `LD rX, [rY + imm16]` | `0x0B`   | Uses the sum of `rY` and the immediate byte as a pointer to the data to be loaded into `rX`. |

### `ST` (Store)
Stores the value of a register in the register file to memory.

| Assembly              | Opcode   | Description                                                                  |
| --------------------- | -------- | ---------------------------------------------------------------------------- |
| `ST [imm16], rX`      | `0x0D`   | Uses the immediate byte as the address to store `rX` to.                     |
| `ST [rY], rX`         | `0x0E`   | Uses the value of `rY` as the address to store `rX` to.                      |
| `ST [rY + imm16], rX` | `0x0F`   | Uses the sum of `rY` and the immediate byte as the address to store `rX` to. |

### `PUSH` (Push to Stack)
Pushes a register to the top of the stack.

| Assembly      | Opcode   | Y Op   | Description                                        |
| ------------- | -------- | ------ | -------------------------------------------------- |
| `PUSH rX`     | `0x10`   | `0x0`  | Pushes `rX` to the top of the stack.               |
| `PUSH flags`  | `0x10`   | `0x1`  | Pushes the flags register to the top of the stack. |

### `POP` (Pop from Stack)
Pops the top of the stack to a register

| Assembly      | Opcode   | Y Op   | Description                                      |
| ------------- | -------- | ------ | ------------------------------------------------ |
| `POP rX`      | `0x11`   | `0x0`  | Pops the top of the stack to `rX`.               |
| `POP flags`   | `0x11`   | `0x1`  | Pops the top of the stack to the flags register. |

### `Jyy` (Jump)
Conditional or unconditional jump to the target address specified either by the immediate byte or the value of the register selected by the X operand.  The `Y` operand is the jump condition.

| Assembly    | Y Op  | Condition                                       |
| ----------- | ----- | ----------------------------------------------- |
| `JMP`       | `0x0` | Unconditional jump.                             |
| `JZ`/`JE`   | `0x1` | Jump if zero flag is set/jump if equal.         |
| `JNZ`/`JNE' | `0x2` | Jump if zero flag is cleared/jump if not equal. |
| `JC`/`JL`   | `0x3` | Jump if carry flag is set/jump if less.         |
| `JNC`/`JNL` | `0x4` | Jump if carry flag is cleared/jump if not less. |
| `JG`        | `0x5` | Jump if greater.                                |
| `JNG`       | `0x6` | Jump if not greater.                            |

| Assembly    | Opcode | Description                    |
| ----------- | ------ | ------------------------------ |
| `Jyy imm16` | `0x12` | Jump to the immediate address. |
| `Jyy rX`    | `0x13` | Jump to the address in `rX`.   |

### `MOV` (Move/Copy)
Copies the value of one register to a different register.  This can be between registers in the register file or between the register file and the flags register.

| Assembly        | Opcode | Description                                                                              |
| --------------- | ------ | ---------------------------------------------------------------------------------------- |
| `MOV rX, flags` | `0x14` | Copies the flags register to the register `rX` in the register file.                     |
| `MOV flags, rX` | `0x15` | Copies the register `rX` in the register file to the flags register.                     |
| `MOV rX, rY`    | `0x16` | Copies the register `rY` in the register file to the register `rX` in the register file. |

### `ADD`/`ADC` (Add without/with carry)
Adds the value of two registers in the register file together and stores the results in the register specified by the X operand.  This instruction may optionally add `1` to the result if the carry flag in the flags register is set.

| Assembly        | Opcode | Description                                                         |
| --------------- | ------ | ------------------------------------------------------------------- |
| `ADD rX, rY`    | `0x20` | Adds `rY` tp `rX` and stores the result in `rX`.                    |
| `ADC rX, rY`    | `0x21` | Adds `rY` and the carry flag to `rX` and stores the result in `rX`. |

### `INC`/ (Increment)
Adds `1` to the X operand and stores the result in the register specified by the X operand.

| Assembly        | Opcode | Description                                     |
| --------------- | ------ | ----------------------------------------------- |
| `INC rX`        | `0x22` | Adds `1` to `rX` and stores the result in `rX`. |

### `ABS`/ (Absolute)
If the X operand is negaive, it is negated and the results stored in the register specified by the X operand.

| Assembly        | Opcode | Description                                                    |
| --------------- | ------ | -------------------------------------------------------------- |
| `ABS rX`        | `0x23` | Negates `rX` if `rX` is negaive and stores the result in `rX`. |

### `SUB`/`SBB` (Subtract without/with carry)
Subtracts the value of two registers in the register file and stores the results in the register specified by the X operand.  This instruction may optionally subtract `1` from the result if the carry flag in the flags register is set.  If the Y operand (unsigned) is greater than the X operand, then the carry flag is set.

| Assembly        | Opcode | Description                                                                |
| --------------- | ------ | -------------------------------------------------------------------------- |
| `SBB rX, rY`    | `0x24` | Subtracts `rY` from `rX` and stores the result in `rX`.                    |
| `SBB rX, rY`    | `0x25` | Subtracts `rY` and the carry flag from `rX` and stores the result in `rX`. |

### `DEC`/ (Decrement)
Subtracts `1` from the X operand and stores the result in the register specified by the X operand.

| Assembly        | Opcode | Description                                            |
| --------------- | ------ | ------------------------------------------------------ |
| `DEC rX`        | `0x26` | Subtracts `1` from `rX` and stores the result in `rX`. |

### `NEG`/ (Absolute)
Negates the X operand and stores the result in the register specified by the X operand.

| Assembly        | Opcode | Description                             |
| --------------- | ------ | --------------------------------------- |
| `NEG rX`        | `0x27` | Negates `rX` stores the result in `rX`. |

### `SHL`/`SAL` (Shift Left)
Shifts the X operand by up to 15 bits to the left and stores the result in the X operand.

| Assembly        | Opcode | Description                                                                                                   |
| --------------- | ------ | ------------------------------------------------------------------------------------------------------------- |
| `SHL rX, rY`    | `0x28` | Shifts `rX` left by the value in `rY` and stores the result in `rX`.                                          |
| `SHL rX, Y`     | `0x29` | Shifts `rX` left by the amount specified by the Y operand and stores the result in `rX`.                      |
| `SAL rX, rY`    | `0x2A` | Shifts `rX` left by the value in `rY` and stores the result in `rX`, preserving the sign.                     |
| `SAL rX, Y`     | `0x2B` | Shifts `rX` left by the amount specified by the Y operand and stores the result in `rX`, preserving the sign. |

### `SHR`/`SAR` (Shift Right)
Shifts the X operand by up to 15 bits to the right and stores the result in the X operand.

| Assembly        | Opcode | Description                                                                                                    |
| --------------- | ------ | -------------------------------------------------------------------------------------------------------------- |
| `SHR rX, rY`    | `0x2C` | Shifts `rX` right by the value in `rY` and stores the result in `rX`.                                          |
| `SHR rX, Y`     | `0x2D` | Shifts `rX` right by the amount specified by the Y operand and stores the result in `rX`.                      |
| `SAR rX, rY`    | `0x2E` | Shifts `rX` right by the value in `rY` and stores the result in `rX`, preserving the sign.                     |
| `SAR rX, Y`     | `0x2F` | Shifts `rX` right by the amount specified by the Y operand and stores the result in `rX`, preserving the sign. |

### 'ROL`/`ROR` (Rotate)
Shifts the X operand left or right by up to 15 bits.  And bits shifted out on one side will be shifted in on the other side in the same order.  The results are stored in the X operand.

| Assembly        | Opcode | Description                                                                                |
| --------------- | ------ | ------------------------------------------------------------------------------------------ |
| `ROL rX, rY`    | `0x30` | Rotates `rX` left by the value in `rY` and stores the result in `rX`.                      |
| `ROL rX, Y`     | `0x31` | Rotates `rX` left by the amount specified by the Y operand and stores the result in `rX`.  |
| `ROR rX, rY`    | `0x32` | Rotates `rX` right by the value in `rY` and stores the result in `rX`.                     |
| `ROR rX, Y`     | `0x33` | Rotates `rX` right by the amount specified by the Y operand and stores the result in `rX`. |

### `AND`/`OR`/`XOR`/`NOT` (Boolean Logic)
Performs boolean operations with the X and Y operands (except for the `NOT` instruction, which ignores the Y operand) and stores the result in the X operand.

| Assembly        | Opcode | Description                                                   |
| --------------- | ------ | ------------------------------------------------------------- |
| `AND rX, rY`    | `0x34` | ANDs `rX` with `rY` and stores the result in `rX`.            |
| `OR  rX, rY`    | `0x35` | ORs `rX` with `rY` and stores the result in `rX`.             |
| `XOR rX, rY`    | `0x36` | XORs `rX` with `rY` and stores the result in `rX`.            |
| `NOT rX`        | `0x37` | Flips all of the bits of `rX` and stores the results in `rX`. |

### `CMP`/`CMPS`/`TEST` (Compare)
Compares two numbers to each other and sets the appropriate flags, but does not write to the register file.  The `TEST` instruction also has two variants:  One which ANDs two numbers together, and the other which passes the X operand directly to the output.

| Assembly        | Opcode | Description                                                                          |
| --------------- | ------ | ------------------------------------------------------------------------------------ |
| `CMP  rX, rY`   | `0x38` | Subtracts `rY` from `rX`, writing to the flags register only.                        |
| `CMPS rX, rY`   | `0x39` | Subtracts `rY` from `rX`, noting their signs and writing to the flags register only. |
| `TEST rX, rY`   | `0x3A` | ANDs `rX` with `rY`, writing to the flags register only.                             |
| `TEST rX`       | `0x3B` | Passes `rX` directly to the ALU's output, writing to the flags register only.        |

### `BRK` (Debug Break)
Temporarilly halts the processor to aid in debugging a program.  The processor will remain halted until the CPU receives a resume signal.

| Assembly        | Opcode | Description                              |
| --------------- | ------ | ---------------------------------------- |
| `BRK`           | `0xFE` | Temporarilly suspends program execution. |

### `HLT` (Halt)
Stops execution of the processor until the processor is reset.  Unlike with the `BRK` instruciton, once a `HLT` instruction is received, there is no way to resume a program.  The processor must be reset.

| Assembly        | Opcode | Description                              |
| --------------- | ------ | ---------------------------------------- |
| `HLT`           | `0xFF` | Perpanently suspends program execution.  |
