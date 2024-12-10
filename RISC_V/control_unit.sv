module control_unit (
    input logic [6:0] opcode, funct7,
    input logic [2:0] funct3, 
    input logic zero, 
    output logic PCSrc, ResultSrc, MemWrite, ALUSrc, RegWrite,
    output logic [2:0] ALUControl,
    output logic [1:0] ImmSrc
);

    logic [1:0] ALUopcode;
    logic Branch;
    logic opcode_5, funct7_5;

    assign opcode_5 = opcode[5]; // sixth bit 
    assign funct7_5 = funct7[5]; //sixth bit
    assign PCSrc = Branch & zero;

    always_comb begin
        case (opcode)
            // lw (load word)
            7'b0000011 : begin
                RegWrite = 1;
                ImmSrc = 2'b00;
                ALUSrc = 1;
                MemWrite = 0;
                ResultSrc = 1; 
                Branch = 0;
                ALUopcode = 2'b00;
            end

            // sw (store word)
            7'b0100011 : begin
                RegWrite = 0;
                ImmSrc = 2'b01; 
                ALUSrc = 1;
                MemWrite = 1;
                ResultSrc = 0; 
                Branch = 0;
                ALUopcode = 2'b00;
            end
            
            // R-type (register to register operation)
            7'b0110011 : begin
                RegWrite = 1;
                ImmSrc = 2'b00; 
                ALUSrc = 0;
                MemWrite = 0;
                ResultSrc = 0;
                Branch = 0;
                ALUopcode = 2'b10;
            end

            // beq (branch equal)
                7'b1100011 : begin
                RegWrite = 0;
                ImmSrc = 2'b10;
                ALUSrc = 0;
                MemWrite = 0;
                ResultSrc = 0;
                Branch = 1;
                ALUopcode = 2'b01;
            end

            // I-type (short immediate or load operation)
            7'b0010011 : begin
                RegWrite = 1;
                ImmSrc = 2'b00;
                ALUSrc = 1;
                MemWrite = 0;
                ResultSrc = 0;
                Branch = 0;
                ALUopcode = 2'b10;
            end

            default : begin
                RegWrite = 1'bx;
                ImmSrc = 2'bxx;
                ALUSrc = 2'bxx;
                MemWrite = 1'bx;
                ResultSrc = 2'bxx;
                Branch = 1'bx;
                ALUopcode = 2'bxx;
            end
        endcase
    end

    always_comb begin
        casex ({ALUopcode,funct3,opcode_5,funct7_5}) 
            7'b00xxxxx : ALUControl = 3'b000; // lw,sw
            7'b01xxxxx : ALUControl = 3'b001; // beq
            7'b1000000 : ALUControl = 3'b000; // add
            7'b1000001 : ALUControl = 3'b000; // add
            7'b1000010 : ALUControl = 3'b000; // add
            7'b1000011 : ALUControl = 3'b001; // sub
            7'b1001000 : ALUControl = 3'b101; // slt
            7'b1011000 : ALUControl = 3'b011; // or
            7'b1011100 : ALUControl = 3'b010; // and
            default : ALUControl = 3'b111;    // default : ALUControl = 3'bxxx;
        endcase
    end
endmodule