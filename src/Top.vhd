library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entity: Top Level Design
-- Description: Controls the UART transmission logic, sending the "Nova" string cyclically.
-- Target Device:  Digilent Cmod S7 (Spartan-7)
entity Top is
    Generic (
        CLOCK_FREQ : integer := 12000000 -- System Clock Frequency (Cmod S7: 12 MHz)
    );
    Port (
        clk          : in  STD_LOGIC; -- Pin M9 (System Clock)
        rst          : in  STD_LOGIC; -- Pin D2 (Button BTN0 - Reset)
        led          : out STD_LOGIC; -- Pin E2 (Status LED)
        uart_txd_out : out STD_LOGIC  -- Pin L12 (UART TX Output to PC)
    );
end Top;

architecture Behavioral of Top is

    -- ROM definition for the message
    -- Message: "Nova" + CR (Carriage Return) + LF (Line Feed)
    type rom_type is array (0 to 5) of std_logic_vector(7 downto 0);
    
    constant ROM : rom_type := (
        0 => x"4E", -- 'N'
        1 => x"6F", -- 'o'
        2 => x"76", -- 'v'
        3 => x"61", -- 'a'
        4 => x"0D", -- CR (Carriage Return)
        5 => x"0A"  -- LF (Line Feed)
    );
        
    -- Internal Signals
    signal timer      : integer range 0 to CLOCK_FREQ := 0;
    signal start      : std_logic := '0';
    signal data       : std_logic_vector(7 downto 0) := (others => '0');
    signal Top_busy   : std_logic;
    signal char_index : integer range 0 to 6 := 0;
    
    -- Finite State Machine (FSM) states
    type state_type is (WAIT_TIMER, PREP_CHAR, SEND_PULSE, WAIT_BUSY, CHECK_DONE);
    signal state : state_type := WAIT_TIMER;
    
begin

    -- Instantiate UART Transmitter Core
    UART : entity work.uart_tx
    generic map(
        BAUD_RATE   => 115200,    -- Configured for high speed
        CLOCK_FREQ  => 12000000,  -- System clock matches the board
        DATA_WIDTH  => 8,
        RESET_STATE => '1'
    )
    port map(
        rst_i   => rst,
        clk_i   => clk,
        tx_line => uart_txd_out,
        
        sta_bit => start,
        byte_in => data, 
        busy    => Top_busy        
    );
        
    -- Main Control Process
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state      <= WAIT_TIMER;
                timer      <= 0;
                char_index <= 0;
                start      <= '0';
                led        <= '0';
            else
                
                case state is
                
                    -- STATE 1: Wait for 1 second interval
                    when WAIT_TIMER =>
                        if timer < CLOCK_FREQ - 1 then
                            timer <= timer + 1;
                            
                            -- Visual feedback: Blink LED for the first 0.5s
                            if timer < CLOCK_FREQ/2 then 
                                led <= '1'; 
                            else 
                                led <= '0'; 
                            end if;
                        else
                            timer      <= 0;
                            char_index <= 0; -- Reset index to the beginning of the string
                            state      <= PREP_CHAR;
                        end if;

                    -- STATE 2: Fetch current character from ROM
                    when PREP_CHAR =>
                        data  <= ROM(char_index);
                        state <= SEND_PULSE;

                    -- STATE 3: Trigger UART transmission
                    when SEND_PULSE =>
                        start <= '1';
                        
                        -- Handshake: Wait for UART to acknowledge busy status
                        if Top_busy = '1' then
                            start <= '0'; -- Clear start signal to prevent double send
                            state <= WAIT_BUSY;
                        end if;

                    -- STATE 4: Wait for UART to finish transmission
                    when WAIT_BUSY =>
                        if Top_busy = '0' then
                            state <= CHECK_DONE;
                        end if;

                    -- STATE 5: Check if whole message is sent
                    when CHECK_DONE =>
                        if char_index < 5 then
                            char_index <= char_index + 1; -- Move to next character
                            state      <= PREP_CHAR;
                        else
                            state      <= WAIT_TIMER; -- Message done, return to wait state
                        end if;

                end case;
            end if;
        end if;
    end process;
    
end Behavioral;