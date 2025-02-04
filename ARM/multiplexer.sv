module multiplexer #(
    // Parameter to set the data width (default 8 bits)
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] d0,  // MUX input 0
    input  logic [WIDTH-1:0] d1,  // MUX input 1
    input  logic             s,   // Select signal
    output logic [WIDTH-1:0] y    // MUX output
);

    //----------------------------------------------------------------------
    // On each bit, if s=1, output d1; otherwise, output d0.
    //----------------------------------------------------------------------
    assign y = s ? d1 : d0;

endmodule
