//---------------------------------------------------------------------------
// The CONDLOGIC module determines whether various control signals (PCSrc,
// RegWrite, MemWrite) should actually be asserted, based on the condition
// field in the instruction (Cond), the current ALU flags (ALUFlags), and
// whether the instruction wants to update flags (FlagW).
//---------------------------------------------------------------------------
module condotional_logic (
    input  logic        clk,         // Clock signal
    input  logic        reset,       // Reset signal
    input  logic [3:0]  Cond,        // Condition bits from the instruction
    input  logic [3:0]  ALUFlags,    // Current ALU flags (NZCV)
    input  logic [1:0]  FlagW,       // Which flags to write (e.g., status register)
    input  logic        PCS,         // Potential PC update (branch)
    input  logic        RegW,        // Potential register write
    input  logic        MemW,        // Potential memory write
    output logic        PCSrc,       // Conditional PC source enable
    output logic        RegWrite,    // Conditional register write enable
    output logic        MemWrite     // Conditional memory write enable
);

    // Storage for flags that may be conditionally updated
    logic [1:0] FlagWrite;
    logic [3:0] Flags;
    logic       CondEx; // Condition satisfied?

    //-------------------------------------------------------------------------
    // Capture or update specific bits of the ALU flags if FlagW is asserted,
    // using two flip-flops (one for the high part of the flag set [3:2],
    // one for the low part [1:0]). This ensures flags are only updated when
    // allowed by the instruction's condition bits.
    //-------------------------------------------------------------------------
    flopenr #(2) flagreg1 (
        .clk    (clk),
        .reset  (reset),
        .en     (FlagWrite[1]),      // Enable for ALUFlags[3:2]
        .d      (ALUFlags[3:2]),
        .q      (Flags[3:2])
    );

    flopenr #(2) flagreg0 (
        .clk    (clk),
        .reset  (reset),
        .en     (FlagWrite[0]),      // Enable for ALUFlags[1:0]
        .d      (ALUFlags[1:0]),
        .q      (Flags[1:0])
    );

    //-------------------------------------------------------------------------
    // Condition checking:
    // We call the 'condcheck' module to see if the instruction's condition
    // is satisfied based on the stored flags.
    //-------------------------------------------------------------------------
    condcheck cc (
        .Cond   (Cond),
        .Flags  (Flags),
        .CondEx (CondEx)
    );

    //-------------------------------------------------------------------------
    // If the condition is met (CondEx = 1), then we actually perform the
    // flagged write operations, otherwise they remain inactive.
    //-------------------------------------------------------------------------
    assign FlagWrite = FlagW & {2{CondEx}};  // Only update flags if condition is met
    assign RegWrite  = RegW & CondEx;        // Only write registers if condition is met
    assign MemWrite  = MemW & CondEx;        // Only write memory if condition is met
    assign PCSrc     = PCS & CondEx;         // Only update PC if condition is met

endmodule


//---------------------------------------------------------------------------
// The CONDCHECK module evaluates the instruction's 'Cond' field against
// the current flags (NZCV) to decide whether the condition is satisfied.
//
//  Bits in 'Cond' correspond to standard ARM condition codes, e.g.:
//  EQ = 0000 (Z=1), NE = 0001 (Z=0), CS = 0010 (C=1), CC = 0011 (C=0), etc.
//---------------------------------------------------------------------------
module condcheck (
    input  logic [3:0] Cond,   // Condition code
    input  logic [3:0] Flags,  // Current flags {N, Z, C, V}
    output logic       CondEx   // 1 if condition is satisfied, else 0
);

    // Unpack the flags for readability
    logic neg, zero, carry, overflow, ge;
    assign {neg, zero, carry, overflow} = Flags;

    // 'ge' (greater or equal) is set if 'N' equals 'V'
    assign ge = (neg == overflow);

    // Based on the 4-bit condition code, decide if the condition is met
    always_comb begin
        case (Cond)
            4'b0000: CondEx =  zero;           // EQ (Z = 1)
            4'b0001: CondEx = ~zero;           // NE (Z = 0)
            4'b0010: CondEx =  carry;          // CS (C = 1)
            4'b0011: CondEx = ~carry;          // CC (C = 0)
            4'b0100: CondEx =  neg;            // MI (N = 1)
            4'b0101: CondEx = ~neg;            // PL (N = 0)
            4'b0110: CondEx =  overflow;       // VS (V = 1)
            4'b0111: CondEx = ~overflow;       // VC (V = 0)
            4'b1000: CondEx =  carry & ~zero;  // HI (C=1 & Z=0)
            4'b1001: CondEx = ~carry & ~zero;  // LS (C=0 & Z=0 ?)
            4'b1010: CondEx =  ge;             // GE (N=V)
            4'b1011: CondEx = ~ge;            // LT (N!=V)
            4'b1100: CondEx = ~zero & ge;      // GT (Z=0 & N=V)
            4'b1101: CondEx = ~(~zero & ge);   // LE (Z=1 or N!=V)
            4'b1110: CondEx = 1'b1;            // AL (Always)
            default: CondEx = 1'bx;            // Undefined
        endcase
    end

endmodule
