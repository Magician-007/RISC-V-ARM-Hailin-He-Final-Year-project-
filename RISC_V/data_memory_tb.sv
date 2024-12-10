`timescale 1ns/1ps
`include "data_memory.sv"
module data_memory_tb;

    logic clk;
    logic [31:0] A;
    logic [31:0] WD;
    logic MemWrite;
    logic [31:0] RD;

    data_memory dut (clk, A, WD, MemWrite, RD );

    // Clock generation
    initial begin
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);
        clk = 0;
        forever #10 clk = ~clk; 
    end

    initial begin
        MemWrite = 1;
        WD = 32'h abcdef12;
        A = 32'h 0; // Start address for write
        #20;        // Wait for 2 clock cycles

        // Stop writing to memory
        //MemWrite = 0;
        #20; // Wait for 2 clock cycles

        // Read from memory address A
        A = 32'h c; // Address for read
        #20;        // Wait for 2 clock cycles to observe read data

        // Verify that the read data matches the expected value
        assert (RD == WD) else $error("Read data does not match written data at address %h", A);

        // Read from memory address A+1
        A = 32'h 10; // Address for read
        #20;        // Wait for 2 clock cycles to observe read data

        // Verify that the upper 24 bits of RD match the lower 24 bits of WD
        assert (RD[31:8] == WD[31:8]) else $error("Read data does not match written data at address %h", A);
        MemWrite = 0;
        A=32'h 0;
        #20;
        $finish; // Stop the programm to avoid endless running
    end

    initial begin
        $monitor("Time = %3d, clk = %b, A = %h, WD = %h, MemWrite = %b, RD = %h", $time, clk, A, WD, MemWrite, RD);
    end

endmodule