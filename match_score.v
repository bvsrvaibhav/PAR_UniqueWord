`timescale 1ns / 1ps

module uw_match_score (
    input clk,
    input rst,
    input in_en,

    input [31:0] uw_pattern,  // 16 QPSK symbols × 2 bits (i0q0...i15q15)

    input signed [15:0] i0, input signed [15:0] q0,
    input signed [15:0] i1, input signed [15:0] q1,
    input signed [15:0] i2, input signed [15:0] q2,
    input signed [15:0] i3, input signed [15:0] q3,
    input signed [15:0] i4, input signed [15:0] q4,
    input signed [15:0] i5, input signed [15:0] q5,
    input signed [15:0] i6, input signed [15:0] q6,
    input signed [15:0] i7, input signed [15:0] q7,
    input signed [15:0] i8, input signed [15:0] q8,
    input signed [15:0] i9, input signed [15:0] q9,
    input signed [15:0] i10, input signed [15:0] q10,
    input signed [15:0] i11, input signed [15:0] q11,
    input signed [15:0] i12, input signed [15:0] q12,
    input signed [15:0] i13, input signed [15:0] q13,
    input signed [15:0] i14, input signed [15:0] q14,
    input signed [15:0] i15, input signed [15:0] q15,

    output reg [1:0] best_rot,
    output reg [4:0] score  // max score = 32
);

    reg [31:0] rot_sym[0:3];     // 0°, 90°, 180°, 270°
    reg [4:0]  rot_score[0:3];   // Matching scores

    reg signed [15:0] i_tmp, q_tmp;
    reg [1:0] sym;
    reg i_sign, q_sign;

    integer i, j;

    always @(posedge clk) begin
        if (rst) begin
            best_rot <= 2'd0;
            score    <= 5'd0;
        end else if (in_en) begin
            // Clear buffers
            for (j = 0; j < 4; j = j + 1)
                rot_sym[j] = 32'd0;

            // Symbol loop
            for (i = 0; i < 16; i = i + 1) begin
                case (i)
                    0:  begin i_tmp = i0;  q_tmp = q0;  end
                    1:  begin i_tmp = i1;  q_tmp = q1;  end
                    2:  begin i_tmp = i2;  q_tmp = q2;  end
                    3:  begin i_tmp = i3;  q_tmp = q3;  end
                    4:  begin i_tmp = i4;  q_tmp = q4;  end
                    5:  begin i_tmp = i5;  q_tmp = q5;  end
                    6:  begin i_tmp = i6;  q_tmp = q6;  end
                    7:  begin i_tmp = i7;  q_tmp = q7;  end
                    8:  begin i_tmp = i8;  q_tmp = q8;  end
                    9:  begin i_tmp = i9;  q_tmp = q9;  end
                    10: begin i_tmp = i10; q_tmp = q10; end
                    11: begin i_tmp = i11; q_tmp = q11; end
                    12: begin i_tmp = i12; q_tmp = q12; end
                    13: begin i_tmp = i13; q_tmp = q13; end
                    14: begin i_tmp = i14; q_tmp = q14; end
                    15: begin i_tmp = i15; q_tmp = q15; end
                endcase

                // Sign bit to logic: 1 if positive, 0 if negative
                i_sign = ~i_tmp[15];
                q_sign = ~q_tmp[15];

                // Rotation 0°: (I, Q) ? {q, i}
                sym = {q_sign, i_sign};
                rot_sym[0][(31 - 2*i) -: 2] = sym;

                // Rotation 90°: (-Q, I) ? {i, ~q}
                sym = {i_sign, ~q_sign};
                rot_sym[1][(31 - 2*i) -: 2] = sym;

                // Rotation 180°: (-I, -Q) ? {~q, ~i}
                sym = {~q_sign, ~i_sign};
                rot_sym[2][(31 - 2*i) -: 2] = sym;

                // Rotation 270°: (Q, -I) ? {~i, q}
                sym = {~i_sign, q_sign};
                rot_sym[3][(31 - 2*i) -: 2] = sym;
            end

            // Score each rotation
            for (j = 0; j < 4; j = j + 1) begin
                rot_score[j] = 0;
                for (i = 0; i < 32; i = i + 1)
                    if (rot_sym[j][i] == uw_pattern[i])
                        rot_score[j] = rot_score[j] + 1;
            end

            // Select best rotation
            if (rot_score[0] >= rot_score[1] &&
                rot_score[0] >= rot_score[2] &&
                rot_score[0] >= rot_score[3]) begin
                best_rot <= 2'd0;
                score    <= rot_score[0];
            end else if (rot_score[1] >= rot_score[2] &&
                         rot_score[1] >= rot_score[3]) begin
                best_rot <= 2'd1;
                score    <= rot_score[1];
            end else if (rot_score[2] >= rot_score[3]) begin
                best_rot <= 2'd2;
                score    <= rot_score[2];
            end else begin
                best_rot <= 2'd3;
                score    <= rot_score[3];
            end
        end
    end
endmodule
