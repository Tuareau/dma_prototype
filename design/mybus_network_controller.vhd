library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mybus_network_controller is
    port(
        -- CLOCK
        clk: in std_logic;       
        
        -- MYBUS MASTER STREAM INTERFACE
        mybus_m_stream_data: out std_logic_vector(31 downto 0);
        mybus_m_stream_flags: out std_logic_vector(3 downto 0);
        mybus_m_stream_valid: out std_logic;
        mybus_m_stream_ready: in std_logic;
        
        -- TRAFFIC CONTROL
        send_packet_command: in std_logic;
        packet_size: in std_logic_vector(31 downto 0)        
    );
end;

architecture synchronous of mybus_network_controller is
    signal traffic_data: std_logic_vector(31 downto 0) := X"0000";
    signal traffic_bytes: std_logic_vector(31 downto 0) := X"0000";
    signal traffic_process: std_logic := '0';
begin
    process(clk) begin
    
        if rising_edge(clk) then   
            -- init traffic generation start     
            if (send_packet_command = '1') then                
                traffic_bytes <= packet_size;
                traffic_data <= X"0000";
                traffic_process <= '1';
            end if;
            
            -- send traffic to master stream
            if (traffic_process = '1' and mybus_m_stream_ready = '1') then
                if (traffic_bytes /= X"0000") then
                    mybus_m_stream_data <= traffic_data;
                    mybus_m_stream_valid <= '1';
                    if unsigned(traffic_bytes) < 4 then
                        mybus_m_stream_flags <= B"0001";
                    else
                        mybus_m_stream_flags <= B"0000";
                    end if;                    
                    
                    traffic_data <= std_logic_vector(unsigned(traffic_data) + 1);
                    traffic_bytes <= std_logic_vector(unsigned(traffic_bytes) - 4);                    
                else 
                    mybus_m_stream_data <= X"0000";
                    mybus_m_stream_flags <= B"0000";
                    mybus_m_stream_valid <= '0';
                    
                    traffic_process <= '0';
                end if;  
            end if;        
        end if;
        
    end process;
end synchronous;
