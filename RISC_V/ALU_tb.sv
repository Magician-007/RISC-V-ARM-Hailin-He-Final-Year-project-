`timescale 1ns / 1ps  // Define time units and resolution
`include "ALU.sv"     // Include all modules being used in this module

module ALU_tb; 

    // Declare the variables being used by the testbench
    logic [31:0] SrcA;
    logic [31:0] SrcB;
    logic [31:0] ALUResult;
    logic [2:0] ALUControl;
    logic zero; 

    // Instantiate the module under test. dut (device under test) is the name we have chosen
    ALU dut (SrcA, SrcB, ALUResult, ALUControl, zero); 

    initial begin             // Single pass behaviour which starts at time 0 ns
        $dumpfile("ALU_tb.vcd");  // Dump variable changes in the vcd file
        $dumpvars(0, ALU_tb);     // Specifies which variables to dump in the vcd file
        SrcA = 32'h00000011; SrcB = 32'h00000011; ALUControl = 3'b010; #20;  // bitwise a AND b 
        SrcA = 32'h00000011; SrcB = 32'h00000011; ALUControl = 3'b011; #20;  // bitwise a OR b 
        SrcA = 32'h00000011; SrcB = 32'h00000011; ALUControl = 3'b000; #20;  // addition a + b 
        SrcA = 32'h00000011; SrcB = 32'h00000011; ALUControl = 3'b001; #20;  // subtraction a - b 
        SrcA = 32'h00000111; SrcB = 32'h00000011; ALUControl = 3'b101; #20;
    end

    initial begin // Single pass behaviour which starts at time 0 ns
        $monitor("t = %3d, ALUControl = %b, SrcA = %d, SrcB = %d, ALUResult = %d, zero = %b \n", $time, ALUControl, SrcA, SrcB, ALUResult, zero); 
    end

endmodule