module data_memory(
        input logic clk,
        input logic [31:0] A,
        input logic [31:0] WD,
        input logic MemWrite,
        output logic [31:0] RD
    );

    logic [7:0] memory [0:1023]; 

    // Handle memory write operation on the positive edge of the clock
    always_ff @(posedge clk) begin
        if (MemWrite) begin
            memory[A] <= WD[7:0]; // msb
            memory[A + 1] <= WD[15:8];
            memory[A + 2] <= WD[23:16];
            memory[A + 3] <= WD[31:24]; // lsb
        end
    end

    assign RD = {memory[A+3], memory[A+2], memory[A+1], memory[A]};
    
endmodule
