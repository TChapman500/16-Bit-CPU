# 16-Bit CPU
This CPU circuit was made using [Logisim Evolution (Holy Cross Edition)](https://github.com/kevinawalsh/logisim-evolution) (v4.0.4).  The circuit might work in the original [Logisim Evolution](https://github.com/kevinawalsh/logisim-evolution), but I have not tested that.  This CPU was implemented with an FPGA in mind, so there is no microcode in the circuit, and there is only one tri-state buffer, which is on the main data bus just before the data leaves the CPU.  The CPU file in the includes folder is designed to work with [customasm](https://github.com/hlorenzi/customasm), to make it easier to write programs for this processor.

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
