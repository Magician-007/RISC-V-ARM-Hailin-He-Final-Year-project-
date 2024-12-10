`timescale 1ns/1ps
`include "program_counter.sv"

module program_counter_tb;
    logic[31:0] PCTarget;
    logic PCSrc, clk, reset;
    logic[31:0] program_counter;

    // Instantiate the Unit Under Test (UUT)
    program_counter dut (PCTarget, PCSrc, clk, reset, program_counter);

    // Clock signal generation with a period of 10 ns
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Toggle clock every 10 ns
    end

    // Apply test stimulus
    initial begin
        $dumpfile("program_counter_tb.vcd"); // Create a VCD file for waveform analysis
        $dumpvars(0, program_counter_tb);    // Dump all variables in the test bench

        // Initial values
        reset = 1; // Start with the reset active
        PCSrc = 0; 
        PCTarget = 32'b0; // Initialize the PC target
        #20; reset = 0; PCSrc = 1; PCTarget = 32'h0000000A; // Deassert reset after two clock cycles
        #20; PCSrc = 0;
        #100;
        $finish;
    end

    // Response monitor
    initial begin
    $monitor("Time = %3d, PCTarget = %d, PCSrc = %b, clk = %b, reset = %b, PC = %d", $time, 
             PCTarget, PCSrc, clk, reset, program_counter);
    end

endmodule
