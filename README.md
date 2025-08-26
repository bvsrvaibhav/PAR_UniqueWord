# Phase Ambiguity Resolution using Unique Word in Digital Communication
Introduction
This project implements a digital communication system component designed to resolve phase ambiguity in Quadrature Phase Shift Keying (QPSK) signals. Phase ambiguity is a common issue in QPSK systems where a receiver's carrier recovery loop may lock onto one of four possible phase states (0°, 90°, 180°, or 270°), leading to incorrect symbol interpretation. To address this, the system uses a known 16-symbol Unique Word (UW) pattern embedded in the transmitted data stream.

The core function of this module is to scan an incoming stream of QPSK symbols, locate the UW, determine its correct phase orientation, and apply a corresponding phase correction to the entire data stream. This ensures all subsequent symbols are properly aligned for demodulation. The design is optimized for FPGA implementation and is particularly useful for burst-mode or packet-based communication protocols.

System Architecture
The top-level module, uw_phase_resolver, orchestrates the entire process. The system is composed of several key sub-modules:

uw_phase_resolver: The main module that controls the flow of operations using a Finite State Machine (FSM). It manages the scanning, detection, and correction phases.

window_buffer: A 16-symbol sliding window that captures consecutive I/Q samples from the input BRAMs for analysis.

uw_match_score: This module performs the core comparison logic. It takes the 16-symbol window and the known UW pattern and calculates a match score for all four possible QPSK rotations (0°, 90°, 180°, 270°). It determines the best match and corresponding rotation index.

phase_corrector: Applies the necessary phase correction to each sample based on the detected rotation. For example, a 90° rotation corrects an (I, Q) sample to (Q, -I).

tb_uw_phase_resolver: A testbench module for verifying the functionality of the system.

Key Features
Robust Phase Ambiguity Resolution: Resolves all four possible QPSK phase ambiguities (0°, 90°, 180°, 270°).

Unique Word Detection: Efficiently scans for a 16-symbol UW pattern within a large buffer of 16,384 samples.

High-Speed Operation: The design is highly parallelized, with the uw_match_score module evaluating all four rotations simultaneously.

FPGA-Optimized: Designed with an FSM-based control flow and modular structure suitable for implementation on FPGAs.

Reconfigurable: The known UW pattern can be easily changed, making the design adaptable to different standards.

Functional Description
The system operates in a series of states controlled by an FSM:

SCAN_UW: The system enters this state upon reset. A sliding window shifts through the input BRAMs, and for each 16-symbol block, the uw_match_score module calculates the match score for all four possible rotations. The best score and its corresponding index are continuously tracked.

HOLD: This state is used for intermediate synchronization, ensuring all calculations are complete before proceeding.

ROTATE: Once the best rotation and the location of the UW are identified, the system transitions to this state. The phase_corrector module reads samples from the input BRAMs, applies the determined phase correction, and writes the corrected samples to the output BRAMs (ROT_I_BRAM, ROT_Q_BRAM).

DONE: The system enters this state when all samples have been corrected. The valid signal is asserted, indicating that the corrected data is ready for subsequent processing stages.

Data Structures
Input Data: The input I/Q samples are stored in two separate dual-port BRAMs: I_BRAM and Q_BRAM, each with a capacity of 16,384 samples. Each sample is represented by a 16-bit signed integer.

Known UW Pattern: A 32-bit register (known_uw) holds the 16-symbol UW pattern. Each symbol is encoded using 2 bits (e.g., 00 for 0°, 01 for 90°, etc.).

Output Data: The phase-corrected I/Q samples are written to two separate output BRAMs: ROT_I_BRAM and ROT_Q_BRAM.

Getting Started
Prerequisites
Verilog HDL simulator (e.g., ModelSim, Vivado Simulator).

FPGA synthesis and implementation tools (e.g., Xilinx Vivado, Intel Quartus).

Simulation
Open your Verilog simulator.

Add all Verilog source files (uw_phase_resolver.v, window_buffer.v, uw_match_score.v, phase_corrector.v, and tb_uw_phase_resolver.v) to your project.

Run the tb_uw_phase_resolver testbench.

The simulation will run and display the final values of best_rot and match_index in the console, confirming successful detection and correction.

Applications
This architecture is well-suited for a variety of digital communication systems, including:

OFDM Systems: Resolving phase ambiguity at the beginning of each OFDM symbol or frame.

Burst-Mode Communications: Used in systems where the carrier phase is not continuous between data bursts.

Wireless Standards: Applicable to standards like LTE, DVB, and Wi-Fi where packet-based communication is used.

Software Defined Radio (SDR): Ideal for real-time signal processing in SDR systems on FPGAs.
