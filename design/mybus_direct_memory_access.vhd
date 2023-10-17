library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mybus_direct_memory_access is
    port(
        -- CLOCK
        clk: in STD_LOGIC;   
        
        -- MYBUS SLAVE LITE INTERFACE
        mybus_s_lite_address: in STD_LOGIC_VECTOR(4 downto 0);
        mybus_s_lite_data_in: in STD_LOGIC_VECTOR(31 downto 0);
        mybus_s_lite_data_out: out STD_LOGIC_VECTOR(31 downto 0);
        mybus_s_lite_write: in STD_LOGIC;        
        
        -- MYBUS MASTER INTERFACE
        mybus_m_address: out STD_LOGIC_VECTOR(19 downto 0);
        mybus_m_data: inout STD_LOGIC_VECTOR(63 downto 0);
        mybus_m_write: out STD_LOGIC;
        mybus_m_ready: in STD_LOGIC;
        
        -- MYBUS SLAVE STREAM INTERFACE
        mybus_s_stream_data: in STD_LOGIC_VECTOR(31 downto 0);
        mybus_s_stream_flags: in STD_LOGIC_VECTOR(3 downto 0);
        mybus_s_stream_valid: in STD_LOGIC;
        mybus_s_stream_ready: out STD_LOGIC;
        
        -- INTERRUPTS
        mem_overflow_intr: out STD_LOGIC;
        rx_packet_intr: out STD_LOGIC
    );
end;

architecture synchronous of mybus_direct_memory_access is

begin


end;
