module extend (
    // 24-bit immediate field from the instruction
    input  logic [23:0] Instr,

    // Control bits determining how to extend/interpret the immediate
    input  logic [1:0]  ImmSrc,

    // The fully extended 32-bit immediate
    output logic [31:0] ExtImm
);

    //-------------------------------------------------------------------------
    // always_comb: Extend the 24-bit input based on ImmSrc.
    //    2'b00 ->  8-bit unsigned immediate
    //    2'b01 -> 12-bit unsigned immediate
    //    2'b10 -> 24-bit two's complement, then shift left by 2 (branch offset)
    //    default -> undefined
    //-------------------------------------------------------------------------
    always_comb begin
        case (ImmSrc)
            // 8-bit unsigned immediate
            2'b00: ExtImm = {24'b0, Instr[7:0]};
            
            // 12-bit unsigned immediate
            2'b01: ExtImm = {20'b0, Instr[11:0]};
            
            // 24-bit two's complement shifted branch offset
            // Shift by 2 bits (the low 2 bits become "00")
            2'b10: ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00};

            // If no valid ImmSrc, set to unknown
            default: ExtImm = 32'bx;
        endcase
    end

endmodule
