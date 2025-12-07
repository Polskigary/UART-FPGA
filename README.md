\# Nova UART Transmitter (VHDL)



A robust, synthesizable VHDL implementation of a UART Transmitter designed for the \*\*Digilent Cmod S7\*\* FPGA board (Xilinx Spartan-7).



The project demonstrates a hardware-based Finite State Machine (FSM) that cyclically transmits the string \*\*"Nova"\*\* to a PC via a serial interface, featuring visual status feedback and debounce-free reset logic.



\## Hardware Specifications



\* \*\*Target Board:\*\* Digilent Cmod S7 (xc7s25csga225-1)

\* \*\*FPGA Family:\*\* Xilinx Spartan-7

\* \*\*System Clock:\*\* 12 MHz

\* \*\*Language:\*\* VHDL-2008

\* \*\*Logic Utilization:\*\* < 1% (Pure Logic implementation)



\## UART Configuration



To receive the data correctly, configure your Serial Terminal (Tera Term, PuTTY, RealTerm) as follows:



| Parameter | Value |

| :--- | :--- |

| \*\*Baud Rate\*\* | \*\*115200\*\* |

| \*\*Data Bits\*\* | 8 |

| \*\*Parity\*\* | None |

| \*\*Stop Bits\*\* | 1 |

| \*\*Flow Control\*\* | None |



\## Project Architecture



The design is modular and consists of two main entities:



\### 1. `uart\_tx.vhd` (Core Driver)

A generic UART transmitter module responsible for parallel-to-serial conversion.

\* \*\*Features:\*\* Configurable Baud Rate via generics, Busy flag for flow control.

\* \*\*FSM States:\*\* `IDLE` -> `START\_BIT` -> `DATA\_BITS` -> `STOP\_BIT`.

\* \*\*Timing:\*\* Uses a precise counter to derive the baud rate from the 12 MHz system clock.



\### 2. `Top.vhd` (Controller)

The top-level logic that manages the transmission sequence.

\* \*\*ROM:\*\* Stores the ASCII message: `\['N', 'o', 'v', 'a', CR, LF]`.

\* \*\*Timer:\*\* Triggers the transmission sequence every \*\*1 second\*\*.

\* \*\*Heartbeat:\*\* Blinks the onboard LED (Pin E2) to indicate system activity.

\* \*\*Handshake:\*\* Monitors the UART Core's `busy` signal to ensure data integrity during transmission.



\## Directory Structure



Nova-UART-FPGA/

├── src/                # VHDL Source files

│   ├── Top.vhd       	 # Top Level Entity \& FSM

│   └── uart\_tx.vhd     # UART Transmitter Core

├── cns/        	 # Physical constraints

│   └── Pins.xdc        # Pin mapping for Digilent Cmod S7

└── README.md           # Project documentation

