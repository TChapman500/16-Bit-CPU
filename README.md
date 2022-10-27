# 16-Bit CPU


## Instruction Set
Each instruction has an 8-bit opcode on the upper half of the instruction byte, and two, 4-bit embeded operands on the lower half of the instruction byte.  The X operand takes up the lower half of the operand space while the Y operand takes up the upper half of the operand space.  Some instructions have a 16-bit immediate byte following the instruction byte.  Any instruction that is not implemented will be interpreted as a `NOP` instruction.

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

| Assembly      | Opcode   | Y Op   | Description                                        |
| ------------- | -------- | ------ | -------------------------------------------------- |
| `POP rX`      | `0x11`   | `0x0`  | Pops the top of the stack to `rX`.                 |
| `POP flags`   | `0x11`   | `0x1`  | Pops the top of the stack to the flags register.   |

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
