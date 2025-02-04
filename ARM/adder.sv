module adder #(
    // Parameter to set the width of the adder, so we add a '#' at the start
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] a, // First input operand
    input  logic [WIDTH-1:0] b, // Second input operand
    output logic [WIDTH-1:0] y  // Sum output
);

    // Perform a simple addition of 'a' and 'b'
    assign y = a + b;

endmodule
