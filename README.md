# RV32I Two-Stage Pipeline

This project implements a modular two-stage RV32I processor. Stage 1 fetches an instruction and records its PC in the IF/ID pipeline register. Stage 2 decodes and executes that instruction, performs the memory operation, and writes the result back to the integer register file.

## Supported instruction groups

- Integer register-register arithmetic and logic: `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND`
- Integer immediate arithmetic and logic: `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI`
- Loads: `LB`, `LH`, `LW`, `LBU`, `LHU`
- Stores: `SB`, `SH`, `SW`
- Conditional branches: `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- Control flow: `JAL`, `JALR`
- Upper immediate: `LUI`, `AUIPC`

The design does not implement the M, C, A, floating-point, CSR, or privileged extensions.

## Pipeline behavior

- The reset PC is `0x80000000`.
- The instruction interface is a combinational read at `address`.
- The IF/ID register holds the fetched instruction and its PC for stage 2.
- A taken branch or jump redirects the fetch PC and flushes the sequential instruction in the IF/ID register, causing a one-cycle control-flow bubble.
- `stall` holds the fetch PC and IF/ID register and suppresses stage-2 register and memory writes.
- Stage 2 combines decode, execute, memory access, and writeback. It assumes combinational data-memory reads; `mem_out` must already be aligned and sign- or zero-extended according to `fn3`.

## Top-level interface

The top module is `two_stage_riscv_i` in `Two_Stage_RISCV_I/rtl.sv`. Its ports follow the external-memory interface used by the course single-cycle core:

| Port | Direction | Meaning |
|---|---|---|
| `clk`, `reset`, `stall` | input | Clock, active-high asynchronous reset, and pipeline hold |
| `instruction` | input | Instruction word fetched from the address output |
| `mem_out` | input | Load result from data memory |
| `address` | output | Stage-1 instruction fetch address |
| `alu_out` | output | Stage-2 ALU result or data-memory address |
| `mem_read`, `mem_write` | output | Stage-2 memory controls |
| `fn3`, `opcode` | output | Current stage-2 memory operation fields |
| `rs2_data` | output | Store data from the stage-2 second source register |

The external memory must use `alu_out`, `fn3`, and `rs2_data` for load/store behavior. For a load, provide the correctly formatted value on `mem_out` during the stage-2 cycle.

## Source layout

| Directory | Function |
|---|---|
| `IF_Stage/` | Fetch PC and redirect selection |
| `IF_ID_Register/` | Stage boundary and control-flow flush |
| `Decoder/` | RV32I instruction field extraction |
| `Immediate_Generator/` | I, S, B, U, and J immediates |
| `Register_File/` | 32 × 32-bit integer register file |
| `Main_Control/` | Instruction-class control signals |
| `ALU_Control/` | RV32I ALU operation selection |
| `ALU/` | Arithmetic, logic, shift, and compare operations |
| `EX_Stage/` | Operand selection, branch decision, and target address |
| `WB_Stage/` | Register writeback selection |
| `Two_Stage_RISCV_I/` | Integrated processor top module |

`rnr-stage.yaml` identifies the top module and lists all source files for the course integration flow.
