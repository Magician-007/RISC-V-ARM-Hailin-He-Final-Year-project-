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
