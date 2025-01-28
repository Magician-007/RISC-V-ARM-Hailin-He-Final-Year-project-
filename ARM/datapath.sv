module datapath (
    // Clock & Reset
    input  logic        clk,
    input  logic        reset,

    // Control Signals
    input  logic [1:0]  RegSrc,      // Selects which registers to read
    input  logic        RegWrite,    // Register file write enable
    input  logic [1:0]  ImmSrc,      // Determines how immediate values are formed
    input  logic        ALUSrc,      // Selects ALU operand source (reg or immediate)
    input  logic [1:0]  ALUControl,  // ALU operation selector
    input  logic        MemtoReg,    // Selects ALU result vs. memory data
    input  logic        PCSrc,       // Selects next PC (PC+4 vs. branch target)

    // Outputs to the rest of the system
    output logic [3:0]  ALUFlags,    // ALU status flags (N, Z, C, V)
    output logic [31:0] PC,          // Current Program Counter

    // Instruction and Data I/O
    input  logic [31:0] Instr,       // Current instruction
    output logic [31:0] ALUResult,   // Result from the ALU
    output logic [31:0] WriteData,   // Data to write to memory
    input  logic [31:0] ReadData     // Data read from memory
);

    //------------------------------------------------------------------------
    // Internal signals
    //------------------------------------------------------------------------
    logic [31:0] PCNext;     // Next PC value
    logic [31:0] PCPlus4;    // PC + 4
    logic [31:0] PCPlus8;    // PC + 8
    logic [31:0] ExtImm;     // Extended immediate
    logic [31:0] SrcA;       // ALU operand A
    logic [31:0] SrcB;       // ALU operand B
    logic [31:0] Result;     // Mux output for data to write back
    logic [3:0]  RA1, RA2;   // Register addresses for reading

    //------------------------------------------------------------------------
    // Next PC logic
    //------------------------------------------------------------------------
    // Compute PC+4 and PC+8 using simple adders,
    // then choose between (PC+4) or a branch target (ALU result) for PCNext.
    // Finally, store PCNext into PC using a flip-flop with reset.
    //------------------------------------------------------------------------
    mux2 #(32) pcmux (
        .d0   (PCPlus4),
        .d1   (Result),   // Branch target (from ALU, if needed)
        .s    (PCSrc),
        .y    (PCNext)
    );

    flopr #(32) pcreg (
        .clk   (clk),
        .reset (reset),
        .d     (PCNext),
        .q     (PC)
    );

    adder #(32) pcadd1 (
        .a (PC),
        .b (32'h4),   // Add 4
        .y (PCPlus4)
    );

    adder #(32) pcadd2 (
        .a (PCPlus4),
        .b (32'h4),   // Add another 4
        .y (PCPlus8)
    );

    //------------------------------------------------------------------------
    // Register file logic
    //------------------------------------------------------------------------
    // We choose the addresses for reading registers (RA1, RA2) using small muxes
    // depending on the RegSrc bits, then read/write the register file.
    // The register file also supports writing back the PC+8 or the ALU result.
    //------------------------------------------------------------------------
    mux2 #(4) ra1mux (
        .d0   (Instr[19:16]),  // Rn field
        .d1   (4'b1111),       // Possibly R15 (PC)
        .s    (RegSrc[0]),
        .y    (RA1)
    );

    mux2 #(4) ra2mux (
        .d0   (Instr[3:0]),    // Rd or immediate field
        .d1   (Instr[15:12]),  // Another register field
        .s    (RegSrc[1]),
        .y    (RA2)
    );

    regfile rf (
        .clk       (clk),
        .we        (RegWrite),
        .ra1       (RA1),
        .ra2       (RA2),
        .wa        (Instr[15:12]),  // Destination register
        .wd        (Result),        // Data to write
        .pc        (PCPlus8),       // Used if writing PC into a register
        .rd1       (SrcA),          // Register data 1 (output)
        .rd2       (WriteData)      // Register data 2 (output)
    );

    //------------------------------------------------------------------------
    // Result Mux
    //------------------------------------------------------------------------
    // Decide whether the data to write back is from the ALU or from memory.
    //------------------------------------------------------------------------
    mux2 #(32) resmux (
        .d0 (ALUResult),
        .d1 (ReadData),
        .s  (MemtoReg),
        .y  (Result)
    );

    //------------------------------------------------------------------------
    // Immediate extension
    //------------------------------------------------------------------------
    // Extend the 24-bit immediate from the instruction, controlled by ImmSrc.
    //------------------------------------------------------------------------
    extend ext (
        .instr_imm (Instr[23:0]),
        .ImmSrc    (ImmSrc),
        .ext_imm   (ExtImm)
    );

    //------------------------------------------------------------------------
    // ALU logic
    //------------------------------------------------------------------------
    // Choose the second ALU operand from either WriteData (register) or ExtImm
    // (extended immediate) based on ALUSrc. Then perform the ALU operation.
    //------------------------------------------------------------------------
    mux2 #(32) srcbmux (
        .d0 (WriteData),
        .d1 (ExtImm),
        .s  (ALUSrc),
        .y  (SrcB)
    );

    alu alu (
        .a         (SrcA),
        .b         (SrcB),
        .control   (ALUControl),
        .result    (ALUResult),
        .flags     (ALUFlags)
    );

endmodule
