// window_buffer.v
`timescale 1ns / 1ps

module window_buffer (
    input clk,
    input rst,
    input in_en,
    input signed [15:0] in_i,
    input signed [15:0] in_q,

    output reg signed [15:0] out_i0, output reg signed [15:0] out_q0,
    output reg signed [15:0] out_i1, output reg signed [15:0] out_q1,
    output reg signed [15:0] out_i2, output reg signed [15:0] out_q2,
    output reg signed [15:0] out_i3, output reg signed [15:0] out_q3,
    output reg signed [15:0] out_i4, output reg signed [15:0] out_q4,
    output reg signed [15:0] out_i5, output reg signed [15:0] out_q5,
    output reg signed [15:0] out_i6, output reg signed [15:0] out_q6,
    output reg signed [15:0] out_i7, output reg signed [15:0] out_q7,
    output reg signed [15:0] out_i8, output reg signed [15:0] out_q8,
    output reg signed [15:0] out_i9, output reg signed [15:0] out_q9,
    output reg signed [15:0] out_i10, output reg signed [15:0] out_q10,
    output reg signed [15:0] out_i11, output reg signed [15:0] out_q11,
    output reg signed [15:0] out_i12, output reg signed [15:0] out_q12,
    output reg signed [15:0] out_i13, output reg signed [15:0] out_q13,
    output reg signed [15:0] out_i14, output reg signed [15:0] out_q14,
    output reg signed [15:0] out_i15, output reg signed [15:0] out_q15
);

    always @(posedge clk) begin
        if (rst) begin
            out_i0 <= 0;  out_q0 <= 0;
            out_i1 <= 0;  out_q1 <= 0;
            out_i2 <= 0;  out_q2 <= 0;
            out_i3 <= 0;  out_q3 <= 0;
            out_i4 <= 0;  out_q4 <= 0;
            out_i5 <= 0;  out_q5 <= 0;
            out_i6 <= 0;  out_q6 <= 0;
            out_i7 <= 0;  out_q7 <= 0;
            out_i8 <= 0;  out_q8 <= 0;
            out_i9 <= 0;  out_q9 <= 0;
            out_i10 <= 0; out_q10 <= 0;
            out_i11 <= 0; out_q11 <= 0;
            out_i12 <= 0; out_q12 <= 0;
            out_i13 <= 0; out_q13 <= 0;
            out_i14 <= 0; out_q14 <= 0;
            out_i15 <= 0; out_q15 <= 0;
        end else if (in_en) begin
            // Shift left
            out_i0  <= out_i1;   out_q0  <= out_q1;
            out_i1  <= out_i2;   out_q1  <= out_q2;
            out_i2  <= out_i3;   out_q2  <= out_q3;
            out_i3  <= out_i4;   out_q3  <= out_q4;
            out_i4  <= out_i5;   out_q4  <= out_q5;
            out_i5  <= out_i6;   out_q5  <= out_q6;
            out_i6  <= out_i7;   out_q6  <= out_q7;
            out_i7  <= out_i8;   out_q7  <= out_q8;
            out_i8  <= out_i9;   out_q8  <= out_q9;
            out_i9  <= out_i10;  out_q9  <= out_q10;
            out_i10 <= out_i11;  out_q10 <= out_q11;
            out_i11 <= out_i12;  out_q11 <= out_q12;
            out_i12 <= out_i13;  out_q12 <= out_q13;
            out_i13 <= out_i14;  out_q13 <= out_q14;
            out_i14 <= out_i15;  out_q14 <= out_q15;
            out_i15 <= in_i;     out_q15 <= in_q;   // new sample at end
        end
    end
endmodule

