`timescale 1ns/1ps
`include "RISC_V.sv"

module RISC_V_tb;
    logic resetbar, clkbar;
    logic [7:0] cpu_out;
    RISC_V dut(resetbar, clkbar, cpu_out);

    initial begin
        clkbar = 0;
        forever #10 clkbar = ~clkbar;
    end

    initial begin // Apply stimulus
        $dumpfile("RISC_V_tb.vcd");
        $dumpvars(0, RISC_V_tb);
        resetbar = 0;
        #40;
        resetbar = 1;
        #100;
        $finish;
    end
    
    always @ (posedge clkbar)
    $display ("t = %3d, clkbar =, %b resetbar = %b, PC = %d, Result = %d, cpu_out = %b,", $time, clkbar, resetbar, dut.PC, dut.Result, dut.cpu_out);
endmodule