module ALU(input logic [31:0] SrcA, 
    input logic [31:0] SrcB, 
    output logic [31:0] ALUResult, // 注意变量
    input logic [2:0] ALUControl,  // 同样是注意变量
    output logic zero); 

    always_comb begin
        case(ALUControl) 
            3'b010 : ALUResult = SrcA & SrcB; // bitwise a AND b 
            3'b011 : ALUResult = SrcA | SrcB; // bitwise a OR b 
            3'b000 : ALUResult = SrcA + SrcB; // addition a + b 
            3'b001 : ALUResult = SrcA - SrcB; // subtraction a - b 
            3'b101: begin
                if (SrcA < SrcB) 
                    ALUResult = 32'b1;
                else
                    ALUResult = 32'b0;
            end // SLT
            default : ALUResult = 32'bx; 
        endcase
    end

    assign zero = (ALUResult) ? 1'b0 : 1'b1;  // Zero = 1 if ALUResult == 0, else Zero = 0 
endmodule