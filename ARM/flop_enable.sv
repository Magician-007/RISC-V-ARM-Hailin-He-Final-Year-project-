module flop_enable #(
    // Parameter to set the register width (default 8 bits)
    parameter WIDTH = 8
) (
    input  logic            clk,    // Clock
    input  logic            reset,  // Asynchronous reset
    input  logic            en,     // Enable signal
    input  logic [WIDTH-1:0] d,     // Data input
    output logic [WIDTH-1:0] q      // Register output
);

    //-------------------------------------------------------------------------
    // On the rising edge of the clock or reset:
    //   1) If reset is high, q is cleared to 0 (asynchronous reset).
    //   2) Otherwise, if 'en' is high, the new data 'd' is latched into q.
    //   3) If neither condition is met, q remains unchanged.
    //-------------------------------------------------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            q <= '0;    // Clear register to 0
        else if (en)
            q <= d;     // Latch new data
        // else: do nothing, q remains the same
    end

endmodule
