module processor (
    // Clock and reset signals
    input  logic        clk,
    input  logic        reset,
    
    // Processor outputs
    output logic [31:0] PC,         // Program Counter
    output logic [31:0] ALUResult,  // Result from the ALU
    output logic [31:0] WriteData,  // Data to be written to memory
    output logic MemWrite,          // Memory write enable signal

    // Processor inputs
    input  logic [31:0] Instr,      // Current instruction
    input  logic [31:0] ReadData    // Data read from memory
);

    // ALU flags (e.g., negative, zero, carry, overflow)
    logic [3:0] ALUFlags;

    // Control signal for register file write enable
    logic RegWrite;

    // Control signals for ALU source, data path selection
    logic ALUSrc, MemtoReg, PCSrc;

    // Control signals specifying register source, immediate source, ALU operation
    logic [1:0] RegSrc, ImmSrc, ALUControl;


//下面的结构和原文不一样，可能会出错
//下面的结构和原文不一样，可能会出错
//下面的结构和原文不一样，可能会出错


    // The controller module generates control signals based on the instruction
    controller c (
        .clk       (clk),
        .reset     (reset),
        .Instr     (Instr[31:12]),   // Portion of instruction used for control decoding
        .ALUFlags  (ALUFlags),
        .RegSrc    (RegSrc),
        .RegWrite  (RegWrite),
        .ImmSrc    (ImmSrc),
        .ALUSrc    (ALUSrc),
        .ALUControl(ALUControl),
        .MemWrite  (MemWrite),
        .MemtoReg  (MemtoReg),
        .PCSrc     (PCSrc)
    );

    // The datapath module implements the registers, ALU, and interconnections
    datapath dp (
        .clk       (clk),
        .reset     (reset),
        .RegSrc    (RegSrc),
        .RegWrite  (RegWrite),
        .ImmSrc    (ImmSrc),
        .ALUSrc    (ALUSrc),
        .ALUControl(ALUControl),
        .MemtoReg  (MemtoReg),
        .PCSrc     (PCSrc),
        .ALUFlags  (ALUFlags),
        .PC        (PC),
        .Instr     (Instr),
        .ALUResult (ALUResult),
        .WriteData (WriteData),
        .ReadData  (ReadData)
    );

endmodule
