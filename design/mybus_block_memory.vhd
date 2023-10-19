library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mybus_block_memory is
    port(
        -- CLOCK
        clk: in std_logic;       
        
        -- MYBUS SLAVE INTERFACE
        mybus_s_address: in std_logic_vector(19 downto 0);
        mybus_s_data: in std_logic_vector(63 downto 0);
        mybus_s_write: in std_logic;
        mybus_s_ready: out std_logic
    );
end;

architecture synchronous of mybus_block_memory is
    type MEMORY is array (0 to 2**20) of std_logic_vector(63 downto 0);
    signal mem: MEMORY;    
begin
    process(clk) begin
        if rising_edge(clk) then
            if mybus_s_write = '1' then
                mybus_s_ready <= '0';
                mem(to_integer(unsigned(mybus_s_address))) <= mybus_s_data;
            else 
                mybus_s_ready <= '1';
            end if;
        end if;
    end process;
end synchronous;
