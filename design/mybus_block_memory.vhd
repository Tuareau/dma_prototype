library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mybus_block_memory is
    port(
        -- CLOCK
        clk: in STD_LOGIC;       
        
        -- MYBUS SLAVE INTERFACE
        mybus_s_address: in STD_LOGIC_VECTOR(19 downto 0);
        mybus_s_data: inout STD_LOGIC_VECTOR(63 downto 0);
        mybus_s_write: in STD_LOGIC;
        mybus_s_ready: out STD_LOGIC
    );
end;

architecture synchronous of mybus_block_memory is

begin


end;
