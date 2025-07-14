# Serial-Receiver-FSM
Designed a framed 4-bit serial receiver using a finite state machine (FSM) in Verilog with error detection, data shift register, and done flag generation.
# UART-style Serial Bit Receiver using FSM (Verilog)

This project implements a **serial bit receiver** in Verilog using a **Finite State Machine (FSM)**. It detects a framed input packet consisting of a **start bit**, **4 data bits**, and a **stop bit**, and sets the `done` flag when a valid transmission is received.

---

## FSM Overview

### FSM States

| State      | Description                                |
|------------|--------------------------------------------|
| `IDLE`     | Wait for start bit (rx == 0)               |
| `RECEIVE`  | Shift in 4 data bits (LSB first)           |
| `WAIT_STOP`| Check stop bit (rx == 1)                   |
| `DONE`     | Assert `done = 1` for one clock cycle      |
| `ERROR`    | Wait in error state until line is idle     |

---

## Inputs & Outputs

| Signal | Direction | Description                         |
|--------|-----------|-------------------------------------|
| `clk`  | Input     | System clock                        |
| `rst`  | Input     | Synchronous reset                   |
| `rx`   | Input     | Serial bit input                    |
| `data` | Output    | 4-bit parallel output (received)    |
| `done` | Output    | High for one cycle when frame done  |

---

## Testbench Highlights

- Sends valid framed packets:  
  - Example: Start (0) + Data (1010) + Stop (1)
- Injects an invalid packet with wrong stop bit (to test error recovery)
- Simulates reset and line idleness
- Dumps waveform as `.vcd` for GTKWave

---

## Tools Used

- Verilog (SystemVerilog-style FSM)
- Icarus Verilog / GTKWave (EDA Playground)
- Timescale: `1ns/1ps`

---

## Features

- Moore FSM: `done` asserted only in `DONE` state
- Robust error handling (invalid stop bit → `ERROR`)
- Fully modular: can be extended to wider data widths or parity
- Easily extensible to UART / serial protocol systems

---

## Future Extensions

- Add parity bit verification
- Make frame size parameterized (e.g., 8-bit mode)
- FIFO buffering for continuous reception
- Integrate with transmitter for full duplex UART
