library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps is
    port(
        -- CLOCK
        clk: out STD_LOGIC;
        
        -- NETWORK TRAFFIC CONTROL
        send_packet_command: out STD_LOGIC;        
        
        -- INTERRUPTS CONTROL
        mem_overflow_intr: in STD_LOGIC;
        rx_packet_intr: in STD_LOGIC
    );
end;

architecture synchronous of ps is

begin


end;
