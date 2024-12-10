module program_counter(input logic[31:0] PCTarget,
          input logic PCSrc,clk,reset,
          output logic[31:0] program_counter);

always_ff @ (posedge clk) begin
if (reset) program_counter <= 32'b0; // when reset=1, PC is 0
else if (PCSrc) // In the condition of reset is 0, when PCSrc=1, PC=PCTarget
    program_counter <= PCTarget;
else program_counter <= program_counter + 4; //if PCSrc is 0, PC is the output after counter which is PC+4
end

endmodule
