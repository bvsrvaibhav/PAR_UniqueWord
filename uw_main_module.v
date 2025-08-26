`timescale 1ns / 1ps

module uw_phase_resolver (
    input clk,
    input rst,

    input [31:0] uw_pattern,                // 16 QPSK symbols × 2 bits
    output reg [1:0] best_rot,              // Detected phase rotation
    output reg [13:0] match_index,          // Location of UW
    output reg valid                        // Asserted after best_rot is valid
);

    parameter TOTAL_SAMPLES = 16384;
    parameter UW_LEN = 16;

    // FSM state encoding
    reg [1:0] state;
    localparam SCAN_UW = 2'd0,
               HOLD    = 2'd1,
               ROTATE  = 2'd2,
               DONE    = 2'd3;

    // --- Address & Control ---
    reg [13:0] bram_addr = 0;
    wire signed [15:0] i_data, q_data;
    reg window_en;
    reg rot_en;

    // --- Max Score Tracking ---
    reg [3:0] max_score = 0;
    reg [13:0] best_index = 0;

    // --- Output after phase correction ---
    wire signed [15:0] i_rot, q_rot;

    // --- Instantiate Input BRAMs (read-only) ---
    blk_mem_gen_0 I_BRAM (
        .clka(clk),
        .ena(1'b1),
        .wea(1'b0),
        .addra(bram_addr),
        .dina(16'd0),
        .douta(i_data)
    );

    blk_mem_gen_1 Q_BRAM (
        .clka(clk),
        .ena(1'b1),
        .wea(1'b0),
        .addra(bram_addr),
        .dina(16'd0),
        .douta(q_data)
    );

    // --- Output BRAMs for rotated I/Q ---
    blk_mem_gen_2 ROT_I_BRAM (
        .clka(clk),
        .ena(rot_en),
        .wea(rot_en),
        .addra(bram_addr),
        .dina(i_rot),
        .douta()  // not needed
    );

    blk_mem_gen_3 ROT_Q_BRAM (
        .clka(clk),
        .ena(rot_en),
        .wea(rot_en),
        .addra(bram_addr),
        .dina(q_rot),
        .douta()
    );

    // --- Window Buffer for 16-sample frame ---
    wire signed [15:0] i_sym0, i_sym1, i_sym2, i_sym3;
    wire signed [15:0] i_sym4, i_sym5, i_sym6, i_sym7;
    wire signed [15:0] i_sym8, i_sym9, i_sym10, i_sym11;
    wire signed [15:0] i_sym12, i_sym13, i_sym14, i_sym15;

    wire signed [15:0] q_sym0, q_sym1, q_sym2, q_sym3;
    wire signed [15:0] q_sym4, q_sym5, q_sym6, q_sym7;
    wire signed [15:0] q_sym8, q_sym9, q_sym10, q_sym11;
    wire signed [15:0] q_sym12, q_sym13, q_sym14, q_sym15;

    window_buffer buffer_inst (
        .clk(clk),
        .rst(rst),
        .in_en(window_en),
        .in_i(i_data),
        .in_q(q_data),
        .out_i0(i_sym0), .out_q0(q_sym0),
        .out_i1(i_sym1), .out_q1(q_sym1),
        .out_i2(i_sym2), .out_q2(q_sym2),
        .out_i3(i_sym3), .out_q3(q_sym3),
        .out_i4(i_sym4), .out_q4(q_sym4),
        .out_i5(i_sym5), .out_q5(q_sym5),
        .out_i6(i_sym6), .out_q6(q_sym6),
        .out_i7(i_sym7), .out_q7(q_sym7),
        .out_i8(i_sym8), .out_q8(q_sym8),
        .out_i9(i_sym9), .out_q9(q_sym9),
        .out_i10(i_sym10), .out_q10(q_sym10),
        .out_i11(i_sym11), .out_q11(q_sym11),
        .out_i12(i_sym12), .out_q12(q_sym12),
        .out_i13(i_sym13), .out_q13(q_sym13),
        .out_i14(i_sym14), .out_q14(q_sym14),
        .out_i15(i_sym15), .out_q15(q_sym15)
    );

    // --- Match Score Module ---
    wire [1:0] match_rot;
    wire [3:0] match_score;

    uw_match_score scorer (
        .clk(clk),
        .rst(rst),
        .in_en(window_en),
        .uw_pattern(uw_pattern),
        .i0(i_sym0),   .q0(q_sym0),
        .i1(i_sym1),   .q1(q_sym1),
        .i2(i_sym2),   .q2(q_sym2),
        .i3(i_sym3),   .q3(q_sym3),
        .i4(i_sym4),   .q4(q_sym4),
        .i5(i_sym5),   .q5(q_sym5),
        .i6(i_sym6),   .q6(q_sym6),
        .i7(i_sym7),   .q7(q_sym7),
        .i8(i_sym8),   .q8(q_sym8),
        .i9(i_sym9),   .q9(q_sym9),
        .i10(i_sym10), .q10(q_sym10),
        .i11(i_sym11), .q11(q_sym11),
        .i12(i_sym12), .q12(q_sym12),
        .i13(i_sym13), .q13(q_sym13),
        .i14(i_sym14), .q14(q_sym14),
        .i15(i_sym15), .q15(q_sym15),
        .best_rot(match_rot),
        .score(match_score)
    );

    // --- Phase Corrector ---
    phase_corrector pc_inst (
        .best_rot(best_rot),
        .i_in(i_data),
        .q_in(q_data),
        .i_out(i_rot),
        .q_out(q_rot)
    );

    // --- FSM Control Logic ---
    always @(posedge clk) begin
        if (rst) begin
            state       <= SCAN_UW;
            bram_addr   <= 0;
            window_en   <= 0;
            rot_en      <= 0;
            valid       <= 0;
            best_rot    <= 0;
            max_score   <= 0;
            match_index <= 0;
        end else begin
            case (state)
                SCAN_UW: begin
                    window_en <= 1;
                    if (bram_addr < TOTAL_SAMPLES) begin
                        bram_addr <= bram_addr + 1;
                        if (match_score > max_score) begin
                            max_score   <= match_score;
                            best_index  <= bram_addr - UW_LEN + 1;
                            best_rot    <= match_rot;
                        end
                    end else begin
                        window_en   <= 0;
                        match_index <= best_index;
                        valid       <= 1;
                        bram_addr   <= 0;
                        state       <= ROTATE;
                    end
                end

                ROTATE: begin
                    rot_en <= 1;
                    if (bram_addr < TOTAL_SAMPLES) begin
                        bram_addr <= bram_addr + 1;
                    end else begin
                        rot_en <= 0;
                        state  <= DONE;
                    end
                end

                DONE: begin
                    rot_en <= 0;
                end
            endcase
        end
    end

endmodule
