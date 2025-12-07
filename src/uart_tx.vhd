----------------------------------------------------------------------------------
-- Module Name:    uart_tx
-- Description:    Simple UART Transmitter with configurable Baud Rate.
--                 Implements a standard 8N1 frame (8 data bits, No parity, 1 Stop bit).
-- Target Device:  Digilent Cmod S7 (Spartan-7)
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Generic (
        BAUD_RATE   : integer := 115200;   -- Target baud rate
        CLOCK_FREQ  : integer := 12000000; -- System clock frequency
        DATA_WIDTH  : integer := 8;        -- Bits per frame (usually 8)
        RESET_STATE : std_logic := '1'     -- Active Reset Level
    );
    Port (
        clk_i   : in  std_logic; -- System Clock
        rst_i   : in  std_logic; -- Reset Input
        
        sta_bit : in  std_logic; -- Start Strobe (Trigger transmission)
        byte_in : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Data to send
        
        busy    : out std_logic; -- High when transmission is in progress
        tx_line : out std_logic  -- Serial Output Line (TX)
    );
end uart_tx;

architecture Behavioral of uart_tx is

    -- Baud Rate Generator constants
    constant TIME_OF_BIT : integer := CLOCK_FREQ / BAUD_RATE;
    signal counter       : integer range 0 to TIME_OF_BIT := 0;
    
    -- State Machine definitions
    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal cur_state : state_type := IDLE;
    
    -- Internal registers
    signal data_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal index    : integer range 0 to DATA_WIDTH := 0;
    
    -- Reset buffer (optional, depending on synthesis strategy)
    signal rst_reg  : std_logic := not RESET_STATE;

begin
    
    process(clk_i)
    begin
        if rising_edge(clk_i) then
            -- Synchronous Reset
            if rst_reg = RESET_STATE then
                cur_state <= IDLE;
                tx_line   <= '1';
                busy      <= '0';
                counter   <= 0;
                index     <= 0;
                
            else
                case cur_state is
                
                    -- STATE: IDLE
                    -- Wait for the start signal. Keep line High (Mark state).
                    when IDLE =>
                        counter <= 0;
                        busy    <= '0';
                        tx_line <= '1';
                        
                        if sta_bit = '1' then
                            cur_state <= START_BIT;
                            data_reg  <= byte_in; -- Latch input data
                            busy      <= '1';     -- Signal that we are busy
                        end if;
                        
                    -- STATE: START BIT
                    -- Drive line Low for one bit period to wake up the receiver.
                    when START_BIT =>
                        tx_line <= '0';
                        
                        if counter < TIME_OF_BIT - 1 then
                            counter <= counter + 1;
                        else
                            counter   <= 0;
                            cur_state <= DATA_BITS;
                        end if;
                           
                    -- STATE: DATA BITS
                    -- Shift out 8 bits, LSB first.
                    when DATA_BITS =>
                        -- 1. Drive output bit IMMEDIATELY upon entering state/index change
                        tx_line <= data_reg(index);
 
                        -- 2. Bit Timing: Wait for the baud period
                        if counter < TIME_OF_BIT - 1 then
                            counter <= counter + 1;
                        else
                            counter <= 0;
 
                            -- 3. Check if all bits are sent
                            if index < DATA_WIDTH - 1 then
                                index <= index + 1; -- Move to next bit
                            else
                                index     <= 0;     -- Reset index
                                cur_state <= STOP_BIT;
                            end if;
                        end if;
                         
                    -- STATE: STOP BIT
                    -- Drive line High for one bit period to close the frame.
                    when STOP_BIT =>
                        tx_line <= '1'; -- Force line High (Stop condition)
                        
                        if counter < TIME_OF_BIT - 1 then
                            counter <= counter + 1;
                        else
                            counter   <= 0;
                            cur_state <= IDLE; -- Transmission complete
                        end if;
                        
                    -- Fallback
                    when others =>
                        cur_state <= IDLE;
                    
                end case;                
            end if;
        end if;
    end process;

    -- Buffer the reset signal
    rst_reg <= rst_i;
    
end Behavioral;