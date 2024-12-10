`timescale 1ns/1ps
`include "control_unit.sv"

module control_unit_tb;
    logic [6:0] opcode, funct7;
    logic [2:0] funct3;
    logic zero; 
    logic PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite;
    logic [2:0] ALUControl;
    logic [1:0] ImmSrc;
    control_unit dut (opcode, funct7, funct3, zero, PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite, ALUControl, ImmSrc);

    initial begin // Apply stimulus
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0, control_unit_tb);
        zero = 0; opcode = 7'b0; funct3 = 3'b0; funct7 = 7'b0;
        #10 opcode = 7'b0000011; funct3 = 3'b000; funct7 = 7'b0000000; 
        #10 opcode = 7'b0100011; funct3 = 3'b000; funct7 = 7'b0000000;
        #10 opcode = 7'b0010011; funct3 = 3'b111; funct7 = 7'b0000000;
        #10 opcode = 7'b1100011; funct3 = 3'b010; funct7 = 7'b0000000;//beq
        #10 opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000;
        #10 opcode = 7'b1101111; funct3 = 3'b111; funct7 = 7'b0000000;
        #10 opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000; zero = 1;
        #30;
        $finish; 
    end

    initial begin
        $monitor ("t = %3d, zero = %b, opcode = %b, funct3 = %b funct7 = %b,RegWrite = %b, ImmSrc = %b, ALUSrc = %b, MemWrite = %b, ResultSrc = %b, ALUControl = %b, PCSrc = %b, ALUOpcode = %b, opcode_5 = %b, funct7_5 = %b", $time, zero, opcode, funct3, funct7, RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUControl, PCSrc, dut.ALUopcode, dut.opcode_5, dut.funct7_5);
    end
endmodule
