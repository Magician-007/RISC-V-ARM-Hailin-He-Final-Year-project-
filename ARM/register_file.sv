module register_file (                                                              //注意所有的函数名字有变动!!!!
    input  logic        clk,        // Clock
    input  logic        we3,        // Write enable for the third port
    input  logic [3:0]  ra1,        // Read address 1
    input  logic [3:0]  ra2,        // Read address 2
    input  logic [3:0]  wa3,        // Write address
    input  logic [31:0] wd3,        // Write data
    input  logic [31:0] r15,        // PC+8 (used when reading register 15)
    output logic [31:0] rd1,        // Read data 1
    output logic [31:0] rd2         // Read data 2
);

    //-------------------------------------------------------------------------
    // Three-ported register file (2 read ports, 1 write port)
    // 'rf' has 15 physical registers, while register 15 (PC+8) is external.
    //-------------------------------------------------------------------------
    logic [31:0] rf[14:0];

    //-------------------------------------------------------------------------
    // Write port: On the rising edge of the clock, if write enable is set (we3),
    // store 'wd3' into register file location 'wa3'.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (we3) begin
            rf[wa3] <= wd3;
        end
    end

    //-------------------------------------------------------------------------
    // Read ports: If the requested register is 15 (4'b1111), we return 'r15'
    // (PC+8). Otherwise, we read from the corresponding element in 'rf'.
    //-------------------------------------------------------------------------
    assign rd1 = (ra1 == 4'b1111) ? r15 : rf[ra1];
    assign rd2 = (ra2 == 4'b1111) ? r15 : rf[ra2];

endmodule
