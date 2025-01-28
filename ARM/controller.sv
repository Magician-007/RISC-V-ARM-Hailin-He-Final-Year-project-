module controller (
    // Clock and reset
    input  logic       clk,
    input  logic       reset,

    // Top bits of instruction used for control
    input  logic [31:12] Instr,

    // ALU flags (e.g., zero, carry, etc.)
    input  logic [3:0] ALUFlags,

    // Control outputs
    output logic [1:0] RegSrc,     // Determines which register(s) to read/write
    output logic       RegWrite,   // Enable register file write
    output logic [1:0] ImmSrc,     // Determines the immediate format
    output logic       ALUSrc,     // Selects ALU input source (register or immediate)
    output logic [1:0] ALUControl, // ALU operation control signals
    output logic       MemWrite,   // Enable memory writes
    output logic       MemtoReg,   // Selects data source to write back to register
    output logic       PCSrc       // Determines how the next PC is computed (branch, etc.)
);

    // Internal signals
    logic [1:0] FlagW; // Controls which condition flags to update
    logic        PCS;  // Internal PC-select signal
    logic        RegW; // Internal register-write enable
    logic        MemW; // Internal memory-write enable



//下面的结构和原文不一样，可能会出错
//下面的结构和原文不一样，可能会出错
//下面的结构和原文不一样，可能会出错


    // Decoder module:
    // Decodes certain instruction fields to produce broad control signals
    decoder dec (
        .InstrOp1   (Instr[27:26]), // Example bits from the instruction
        .InstrOp2   (Instr[25:20]),
        .InstrOp3   (Instr[15:12]),
        .FlagW      (FlagW),
        .PCS        (PCS),
        .RegW       (RegW),
        .MemW       (MemW),
        .MemtoReg   (MemtoReg),
        .ALUSrc     (ALUSrc),
        .ImmSrc     (ImmSrc),
        .RegSrc     (RegSrc),
        .ALUControl (ALUControl)
    );

    // Condition logic module:
    // Uses the decoded signals plus the ALU flags to generate final control signals
    condlogic cl (
        .clk       (clk),
        .reset     (reset),
        .CondBits  (Instr[31:28]), // Condition field from instruction
        .ALUFlags  (ALUFlags),
        .FlagW     (FlagW),
        .PCS       (PCS),
        .RegW      (RegW),
        .MemW      (MemW),
        .PCSrc     (PCSrc),
        .RegWrite  (RegWrite),
        .MemWrite  (MemWrite)
    );

endmodule
