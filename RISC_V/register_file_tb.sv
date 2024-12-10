`timescale 1ns/1ps
`include "register_file.sv"

module register_file_tb; 
    logic [4:0] A1;
    logic [4:0] A2;
    logic [4:0] A3;
    logic [31:0] WD3;
    logic clk, RegWrite;
    logic [31:0] RD1, RD2;
    register_file dut (A1, A2, A3, WD3, clk, RegWrite, RD1, RD2); 
    logic [31:0] RegisterFile [0:31]; 

    initial begin // Generate clock signal with 20 ns period
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("register_file_tb.vcd"); 
        $dumpvars(0, register_file_tb); 
        #5;
        A1 = 5'b00000; A2 = 5'b00000; A3 = 5'b00000; WD3 = 32'h0; 
        clk = 1'b0; RegWrite = 1'b1; 
        //Insert data at different address 
        #10; WD3 = 32'h00000001; A3 = 5'b00000; 
        #10; WD3 = 32'h00000010; A3 = 5'b00001; 
        #30; WD3 = 32'h00000011; A3 = 5'b00010; 
        #30;
        //Stop writing data 
        #10; RegWrite = 1'b0; 
        #10; A1 = 5'b00001; A2 = 5'b00010; //Read data 
        #40;
        $finish;
    end

    always @ (negedge clk)
        $display("t = %3d, clk = %b, A1 = %d, A2 = %d, A3 = %d, RegWrite = %b, WD3 = %d, RD1 = %d, RD2 = %d \n", $time , clk, A1, A2, A3, RegWrite, WD3, RD1 ,RD2); 
endmodule
