
`timescale 1ns / 1ps

module tb_uw_phase_resolver;

    reg clk = 0;
    reg rst = 1;

    wire [1:0] best_rot;
    wire [13:0] match_index;
    wire valid;

    // UW pattern: 16 QPSK symbols (2 bits each) = 32-bit word
    // Example pattern (randomly chosen): 16 symbols = 32'bq15i15 ... q0i0
    reg [31:0] uw_pattern;

    // Instantiate the DUT
    uw_phase_resolver uut (
        .clk(clk),
        .rst(rst),
        .uw_pattern(uw_pattern),
        .best_rot(best_rot),
        .match_index(match_index),
        .valid(valid)
    );

    // Clock generation
    always #5 clk = ~clk;  // 100 MHz

    // Test sequence
    initial begin
        // Initialize UW pattern (example: 16 QPSK symbols packed as {q,i})
        uw_pattern = 32'b10011100011000110110010101101111;

        // Reset pulse
        rst = 1;
        #20;
        rst = 0;

        // Wait until valid output is asserted
        wait (valid == 1);

        // Display result
        $display("Best Rotation : %d", best_rot);
        $display("Match Index   : %d", match_index);
        $finish;
    end

endmodule

