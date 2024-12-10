module RISC_V(
        input logic resetbar, clkbar, // for reset whole program or clock
        output logic [7:0] cpu_out
    );
    logic PCSrc, zero, ResultSrc, MemWrite, ALUSrc, RegWrite, opcode_5, funct7_5, Branch, reset, clk;
    logic [1:0] ImmSrc, ALUOp;
    logic [2:0] funct3, ALUControl;
    logic [4:0] A1, A2, A3;
    logic [6:0] opcode, funct7;
    logic [7:0] instruction_memory [0:255]; // [0:255];
    logic signed [31:0] PCTarget, PC, SrcA, SrcB, ALUResult, A, WD, RD, ImmExt, instruction, Result, WD3, RD1, RD2;
    logic signed [31:0] rf [0:31];
    logic signed [7:0] memory [0:1023]; 


    // Instruction Memory
    initial $readmemh("program_RISC_V.txt", instruction_memory);
    assign instruction = {instruction_memory[PC],instruction_memory[PC+1],instruction_memory[PC+2],instruction_memory[PC+3]};
    assign cpu_out = Result[7:0];

    // Instruction
    assign opcode = instruction[6:0];
    assign A3 = instruction[11:7]; 
    assign funct3 = instruction[14:12];
    assign A1 = instruction[19:15];
    assign A2 = instruction[24:20];
    assign funct7 = instruction[31:25];
    assign WD3 = Result;
    assign WD = RD2;
    assign A = ALUResult;

    // Assign cpu_out = ALUResult[7:0];
    assign clk = ~clkbar;
    assign reset = ~resetbar;


    // Control Unit
    assign opcode_5 = opcode[5]; // sixth bit 
    assign funct7_5 = funct7[5]; // sixth bit

    // Assign PCSrc = Branch & Zero;
    assign PCSrc = (funct3[0]) ? Branch &~ zero : Branch & zero;

    always_comb begin
        case (opcode)

            // lw
            7'b0000011 : begin
                RegWrite = 1;
                ImmSrc = 2'b00;
                ALUSrc = 1;
                MemWrite = 0;
                ResultSrc = 1; 
                Branch = 0;
                ALUOp = 2'b00;
            end

            // sw
            7'b01000 : begin
                RegWrite = 0;
                ImmSrc = 2'b01; 
                ALUSrc = 1;
                MemWrite = 1;
                ResultSrc = 0; 
                Branch = 0;
                ALUOp = 2'b00;
            end

            // R-type
            7'b0110011 : begin
                RegWrite = 1;
                ImmSrc = 2'b00; 
                ALUSrc = 0;
                MemWrite = 0;
                ResultSrc = 0;
                Branch = 0;
                ALUOp = 2'b10;
            end

            // beq
            7'b1100011 : begin
                RegWrite = 0;
                ImmSrc = 2'b10;
                ALUSrc = 0;
                MemWrite = 0;
                ResultSrc = 0;
                Branch = 1;
                ALUOp = 2'b01;
            end

            // I-type
            7'b0010011 : begin
                RegWrite = 1;
                ImmSrc = 2'b00;
                ALUSrc = 1;
                MemWrite = 0;
                ResultSrc = 0;
                Branch = 0;
                ALUOp = 2'b10;
            end

            default : begin
                RegWrite = 1'bx;
                ImmSrc = 2'bxx;
                ALUSrc = 1'bx;
                MemWrite = 1'bx;
                ResultSrc = 2'bxx;
                Branch = 1'bx;
                ALUOp = 2'bxx;
            end
        endcase
    end


    // ALU Decoder
    always_comb begin
        casex ({ALUOp, funct3, opcode_5, funct7_5})
            7'b00xxxxx: ALUControl = 3'b000; // lw, sw
            7'b01xxxxx: ALUControl = 3'b001; // beq
            //2'b01001xx: ALUControl = 3'b010; // bne
            7'b1000000: ALUControl = 3'b000; // add
            7'b1000001: ALUControl = 3'b000; // add
            7'b1000010: ALUControl = 3'b000; // add
            7'b1000011: ALUControl = 3'b001; // sub
            7'b10010xx: ALUControl = 3'b101; // slt
            7'b10110xx: ALUControl = 3'b011; // or
            7'b10111xx: ALUControl = 3'b010; // and
            default: ALUControl = 3'bxxx;    // invalid operation
        endcase
    end


    // Register file
    assign RD1 = (A1 == 0)?32'b0 : rf[A1];
    assign RD2 = (A2 == 0)?32'b0 : rf[A2];
    always_ff @ (posedge clk) begin
        if (RegWrite) rf[A3] <= WD3;
    end
    assign SrcB = (ALUSrc)? ImmExt : RD2;
    assign SrcA = RD1;


    // ALU
    always_comb begin
        case(ALUControl) 
            3'b010 : ALUResult = SrcA & SrcB; // bitwise a AND b 
            3'b011 : ALUResult = SrcA | SrcB; // bitwise a OR b 
            3'b000 : ALUResult = SrcA + SrcB; // addition a + b 
            3'b001 : ALUResult = SrcA - SrcB; // subtraction a - b 
            3'b101: begin
                if (SrcA < SrcB) ALUResult = 32'b1;
                else ALUResult = 32'b0;
            end // SLT
            default : ALUResult = 32'bx; 
        endcase
    end

    // Assign zero = (ALUResult == 32'b0) ? 1'b0 : 1'b1; // Zero = 1 if ALUResult == 0, else Zero = 0 
    assign zero = (ALUResult == 32'b0) ? 1'b1 : 1'b0;


    // DataMemory
    always_ff @(posedge clk) begin
        if (MemWrite) begin
            memory[A] <= WD[7:0]; // msb
            memory[A + 1] <= WD[15:8];
            memory[A + 2] <= WD[23:16];
            memory[A + 3] <= WD[31:24]; // lsb
        end
    end
    assign RD = {memory[A+3], memory[A+2], memory[A+1], memory[A]};
    assign Result = (ResultSrc)? RD : ALUResult;


    // Program counter
    assign PCTarget = PC + ImmExt;
    always_ff @ (posedge clk or posedge reset) begin
        if (reset) PC <= 32'b0;         // when reset=1, PC is 0
        else if (PCSrc) PC <= PCTarget; // In the condition of reset is 0, when PCSrc=1, PC=PCTarget
        else PC <= PC + 4;              //if PCSrc is 0, PC is the output after counter which is PC+4
    end

endmodule
