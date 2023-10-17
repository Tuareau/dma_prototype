library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mybus_network_controller is
    port(
        -- CLOCK
        clk: in STD_LOGIC;
    
        -- MYBUS MASTER LITE INTERFACE
        mybus_m_lite_address: out STD_LOGIC_VECTOR(4 downto 0);
        mybus_m_lite_data_in: in STD_LOGIC_VECTOR(31 downto 0);
        mybus_m_lite_data_out: out STD_LOGIC_VECTOR(31 downto 0);
        mybus_m_lite_write: out STD_LOGIC;        
        
        -- MYBUS MASTER STREAM INTERFACE
        mybus_m_stream_data: out STD_LOGIC_VECTOR(31 downto 0);
        mybus_m_stream_flags: out STD_LOGIC_VECTOR(3 downto 0);
        mybus_m_stream_valid: out STD_LOGIC_VECTOR(31 downto 0);
        mybus_m_stream_ready: in STD_LOGIC_VECTOR(31 downto 0);
        
        -- TRAFFIC CONTROL
        send_packet_command: in STD_LOGIC
    );
end;

architecture synchronous of mybus_network_controller is

begin


end;
