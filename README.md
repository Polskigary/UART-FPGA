A VHDL project running on the **Digilent Cmod S7** FPGA. It demonstrates a custom UART controller that cyclically sends the message **"Nova"** to a computer.

What it does
* **Sends Data:** Transmits the text "Nova" + New Line every second.
* **Visual Feedback:** The onboard LED blinks to show the system is alive.
* **User Control:** Pressing `BTN0` resets the transmission.

Hardware Setup

| Component | Detail |
| :--- | :--- |
| **FPGA Board** | Digilent Cmod S7 (Spartan-7) |
| **Clock** | 12 MHz |
| **Output Pin** | L12 (UART TX) |
| **Reset Pin** | D2 (Button 0) |

Connection Settings
To see the message, open your Serial Terminal (like Tera Term or PuTTY) and use these exact settings:

| Setting | Value |
| :--- | :--- |
| **Baud Rate** | **115200** |
| **Data Bits** | 8 |
| **Parity** | None |
| **Stop Bits** | 1 |

Project Structure

* `src/Top.vhd` - **The Brain.** Controls the timing and sends characters one by one.
* `src/uart_tx.vhd` - **The Worker.** Handles the low-level serialization of bits.
* `constraints/` - Pin mapping files (.xdc).

How to use
1. **Clone** this repo.
2. Open **Vivado** and create a project for **XC7S25**.
3. Add files from `src` and `constraints`.
4. Generate Bitstream & Program the device.
5. Congrats, it should work.
