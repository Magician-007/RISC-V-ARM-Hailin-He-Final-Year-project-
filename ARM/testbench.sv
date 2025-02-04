module testbench();

    //-------------------------------------------------------------------------
    // Testbench Signals
    //-------------------------------------------------------------------------
    // These signals will drive/observe the design under test (DUT).
    logic        clk;        // Clock
    logic        reset;      // Reset
    logic [31:0] WriteData;  // Data being written to memory in the DUT
    logic [31:0] DataAdr;    // Address where data is being written
    logic        MemWrite;   // Indicates a memory write operation is occurring

    //-------------------------------------------------------------------------
    // Instantiate the Device Under Test (DUT)
    //-------------------------------------------------------------------------
    // 'top' is the top-level module that includes or instantiates our ARM single-cycle CPU design.
    // We wire up the signals from this testbench to 'top'.
    //-------------------------------------------------------------------------
    top dut (
        .clk       (clk),
        .reset     (reset),
        .WriteData (WriteData),
        .DataAdr   (DataAdr),
        .MemWrite  (MemWrite)
    );

    //-------------------------------------------------------------------------
    // Test Initialization
    //-------------------------------------------------------------------------
    // In an initial block, we apply a reset to the DUT, hold it for 22 time units, and then release it.
    // This is typically done to ensure the DUT starts up in a known state.
    //-------------------------------------------------------------------------
    initial begin
        reset <= 1;
        #22;
        reset <= 0;
    end

    //-------------------------------------------------------------------------
    // Clock Generation
    //-------------------------------------------------------------------------
    // Another initial or always block to produce a continuous clock signal.
    // The clock is high for 5 time units, then low for 5 time units, repeating indefinitely.
    // This ensures the CPU logic advances each cycle.
    //-------------------------------------------------------------------------
    always begin
        clk <= 1; 
        #5;         // Clock remains high for 5 time units
        clk <= 0; 
        #5;         // Clock remains low for 5 time units
    end

