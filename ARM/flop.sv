module flop #(
    // Parameter to set the register width (default: 8 bits)
    parameter WIDTH = 8
) (
    input  logic            clk,    // Clock signal
    input  logic            reset,  // Asynchronous reset signal
    input  logic [WIDTH-1:0] d,     // Data input
    output logic [WIDTH-1:0] q      // Output register
);

    //--------------------------------------------------------------------------
    // On each rising edge of clk or reset:
    //   - If reset is 1, clear q to 0 (asynchronous reset)
    //   - Otherwise, load d into q
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            q <= '0;   // or q <= {WIDTH{1'b0}};
        else
            q <= d;
    end

endmodule
