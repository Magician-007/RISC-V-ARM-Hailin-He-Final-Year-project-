`timescale 1ns/1ps
`include "instruction_memory.sv"

module instruction_memory_tb;

    logic [31:0] program_counter;
    logic [31:0] instruction;
    instruction_memory dut (program_counter, instruction);

    // Test stimulus
    initial begin
        $dumpfile("instruction_memory_tb.vcd"); 
        $dumpvars(0, instruction_memory_tb); 

        program_counter = 0;
        #10; 

        $display("8 bits at PC+1: %0h", dut.instruc_memory[program_counter + 1]); // notice
        $display("8 bits at PC+2: %0h", dut.instruc_memory[program_counter + 2]); // notice

        program_counter = 4;
        #10;

        $display("8 bits at PC+1: %0h", dut.instruc_memory[program_counter + 1]); // notice
        $display("8 bits at PC+2: %0h", dut.instruc_memory[program_counter + 2]); // notice
        $finish;
    end

    // Monitor the outputs
    initial begin
        $monitor("Time = %3d, program counter = %h, Instruction = %h", $time, program_counter, instruction);
    end

endmodule