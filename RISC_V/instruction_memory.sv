module instruction_memory(input logic [31:0] program_counter, output logic [31:0] instruction);
    logic [7:0] instruc_memory [0:255];
    initial $readmemh("program.txt", instruc_memory);
    assign instruction = {instruc_memory[program_counter], instruc_memory[program_counter + 1],
                    instruc_memory[program_counter + 2], instruc_memory[program_counter + 3]};
endmodule