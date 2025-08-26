
`timescale 1ns / 1ps

// ===========================================================
// MODULE: phase_corrector
// PURPOSE: Rotate input I/Q samples based on best_rot value.
//          Used to align QPSK symbols to original phase.
// INPUTS:
//   - best_rot : 2-bit rotation value (0° / 90° / 180° / 270°)
//   - i_in     : 16-bit signed I sample (Q1.15 format assumed)
//   - q_in     : 16-bit signed Q sample
// OUTPUTS:
//   - i_out    : Rotated I sample
//   - q_out    : Rotated Q sample
// ===========================================================
module phase_corrector (
    input wire [1:0] best_rot,           // 00: 0°, 01: 90°, 10: 180°, 11: 270°
    input wire signed [15:0] i_in,       // Input In-phase component
    input wire signed [15:0] q_in,       // Input Quadrature component
    output reg signed [15:0] i_out,      // Rotated In-phase component
    output reg signed [15:0] q_out       // Rotated Quadrature component
);

    always @(*) begin
        case (best_rot)
            2'b00: begin
                // 0° rotation: no change
                i_out = i_in;
                q_out = q_in;
            end
            2'b01: begin
                // 90° rotation: (I, Q) => (Q, -I)
                i_out = q_in;
                q_out = -i_in;
            end
            2'b10: begin
                // 180° rotation: (I, Q) => (-I, -Q)
                i_out = -i_in;
                q_out = -q_in;
            end
            2'b11: begin
                // 270° rotation: (I, Q) => (-Q, I)
                i_out = -q_in;
                q_out = i_in;
            end
            default: begin
                // Should never happen, but for safety
                i_out = i_in;
                q_out = q_in;
            end
        endcase
    end

endmodule


/////////////////////////////////////////////////////////////////////////////////////////////////////



