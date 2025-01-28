module decoder (
    // Major opcode field from the instruction
    input  logic [1:0] Op,
    
    // Function field (e.g., used to differentiate DP immediate vs register, etc.)
    input  logic [5:0] Funct,
    
    // Destination register index
    input  logic [3:0] Rd,
    
    // Outputs controlling flags and overall datapath
    output logic [1:0] FlagW,      // Which condition flags to write
    output logic       PCS,        // PC selection signal (branch or write to R15)
    output logic       RegW,       // Register file write enable
    output logic       MemW,       // Memory write enable
    output logic       MemtoReg,   // Choose ALU result vs. memory data for register write-back
    output logic       ALUSrc,     // Select ALU operand source (register vs. immediate)
    output logic [1:0] ImmSrc,     // Immediate encoding/extension control
    output logic [1:0] RegSrc,     // Register source control
    output logic [1:0] ALUControl  // ALU operation select (e.g., ADD, SUB, AND, ORR)
);

    // Control signals packed into a 10-bit bus for convenience
    logic [9:0] controls;
    
    // Internal signals used to expand 'controls'
    logic Branch;  // Branch enable
    logic ALUOp;   // Indicates a Data Processing (DP) instruction

    //-------------------------------------------------------------------------
    // Main Decoder
    //-------------------------------------------------------------------------
    // Based on `Op` (and sometimes bits of `Funct`), we generate a 10-bit
    // control word. Each case corresponds to an instruction category:
    //   - Data-processing (immediate or register)
    //   - Load/store (LDR, STR)
    //   - Branch (B)
    //-------------------------------------------------------------------------
    always_comb begin
        casex (Op)
            2'b00: 
                if (Funct[5])
                    // Data-processing immediate
                    controls = 10'b0000011001;
                else
                    // Data-processing register
                    controls = 10'b0000000101;

            2'b01: 
                if (Funct[0])
                    // LDR
                    controls = 10'b0000111100;
                else
                    // STR
                    controls = 10'b0011110100;

            2'b10:
                // B (Branch)
                controls = 10'b0110100010;

            default:
                // Unimplemented or unknown opcode
                controls = 10'bxxxxxxxxxx;
        endcase
    end

    //-------------------------------------------------------------------------
    // Split the 10-bit control word into individual signals
    // Format: {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp}
    //-------------------------------------------------------------------------
    assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp} = controls;

    //-------------------------------------------------------------------------
    // ALU Decoder
    //-------------------------------------------------------------------------
    // If ALUOp is set, this is a data-processing instruction, and we select
    // the specific ALU operation based on bits [4:1] of `Funct`.
    //-------------------------------------------------------------------------
    always_comb begin
        if (ALUOp) begin
            // Which DP instruction?
            case (Funct[4:1])
                4'b0100: ALUControl = 2'b00; // ADD
                4'b0010: ALUControl = 2'b01; // SUB
                4'b0000: ALUControl = 2'b10; // AND
                4'b1100: ALUControl = 2'b11; // ORR
                default: ALUControl = 2'bxx; // Unimplemented
            endcase

            // Update flags if the S bit (Funct[0]) is set
            // Typically, we update C & V only for arithmetic instructions
            FlagW[1] = Funct[0];
            FlagW[0] = Funct[0] & (ALUControl == 2'b01); // E.g., set for SUB
        end
        else begin
            // Non-DP instruction (e.g., memory or branch)
            // Default to an ADD-like ALU operation
            ALUControl = 2'b00; 
            // Do not update flags for these instructions
            FlagW      = 2'b00; 
        end
    end

    //-------------------------------------------------------------------------
    // PC Logic
    //-------------------------------------------------------------------------
    // PCS (PC Select) is asserted if:
    //   1) We are writing to R15 (PC) (i.e., Rd = 1111) and RegW is asserted
    //   2) We have a Branch instruction
    //-------------------------------------------------------------------------
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

endmodule
