module register_file(input logic [4:0] A1, 
    input logic [4:0] A2, 
    input logic [4:0] A3,
    input logic [31:0] WD3,
    input logic clk, RegWrite,
    output logic [31:0] RD1, RD2);
    logic [31:0] RegisterFile [0:31]; //32*32 register file for RV32I
    assign RD1 = (A1 == 0)?32'b0 : RegisterFile[A1];
    assign RD2 = (A2 == 0)?32'b0 : RegisterFile[A2];

    always_ff @ (posedge clk) 
        if (RegWrite) 
            RegisterFile[A3] <= WD3;

endmodule
