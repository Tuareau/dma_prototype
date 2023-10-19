library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity simple_dma_system is
    port(
        -- CLOCK
        CLK: in std_logic;
        
        -- MYBUS MASTER LITE INTERFACE
        MYBUS_M_LITE_ADDRESS: in std_logic_vector(4 downto 0);    
        MYBUS_M_LITE_DATA_IN: in std_logic_vector(31 downto 0);   
        MYBUS_M_LITE_DATA_OUT: out std_logic_vector(31 downto 0);   
        MYBUS_M_LITE_WRITE: in std_logic;       
        
        -- INTERRUPTS CONTROL
        MEM_OVERFLOW_INTR: out std_logic;
        RX_PKT_INTR: out std_logic;
        
        -- PACKET TRAFFIC CONTROL
        PKT_SIZE: in std_logic_vector(31 downto 0);    
        SND_PKT_CMD: in std_logic
    );
end;

architecture synchronous of simple_dma_system is

    component mybus_block_memory
        port(
        -- CLOCK
        clk: in std_logic;       
        
        -- MYBUS SLAVE INTERFACE
        mybus_s_address: in std_logic_vector(19 downto 0);
        mybus_s_data: inout std_logic_vector(63 downto 0);
        mybus_s_write: in std_logic;
        mybus_s_ready: out std_logic
    );
    end component;
    
    component mybus_network_controller
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
    end component;
    
    component mybus_direct_memory_access
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
    end component;     

    signal MYBUS_ADDRESS: std_logic_vector(19 downto 0);
    signal MYBUS_DATA: std_logic_vector(63 downto 0);
    signal MYBUS_WRITE: std_logic;
    signal MYBUS_READY: std_logic;
    
    signal MYBUS_STREAM_DATA: std_logic_vector(31 downto 0);
    signal MYBUS_STREAM_FLAGS: std_logic_vector(3 downto 0);
    signal MYBUS_STREAM_VALID: std_logic;
    signal MYBUS_STREAM_READY: std_logic;
begin

    mybus_dma: mybus_direct_memory_access port map(
        clk => CLK, 
        mybus_s_lite_address => MYBUS_M_LITE_ADDRESS, 
        mybus_s_lite_data_in => MYBUS_M_LITE_DATA_IN, 
        mybus_s_lite_data_out => MYBUS_M_LITE_DATA_OUT, 
        mybus_s_lite_write => MYBUS_M_LITE_WRITE,
        mybus_m_address => MYBUS_ADDRESS,
        mybus_m_data => MYBUS_DATA,
        mybus_m_write => MYBUS_WRITE,
        mybus_m_ready => MYBUS_READY,
        mybus_s_stream_data => MYBUS_STREAM_DATA,
        mybus_s_stream_flags => MYBUS_STREAM_FLAGS,
        mybus_s_stream_valid => MYBUS_STREAM_VALID,
        mybus_s_stream_ready => MYBUS_STREAM_READY,
        mem_overflow_intr => MEM_OVERFLOW_INTR,
        rx_packet_intr => RX_PKT_INTR        
    );    

    mybus_bram: mybus_block_memory port map(
        clk => CLK, 
        mybus_s_address => MYBUS_ADDRESS, 
        mybus_s_data => MYBUS_DATA, 
        mybus_s_write => MYBUS_WRITE, 
        mybus_s_ready => MYBUS_READY    
    );  
    
    mybus_ntw_ctrl: mybus_network_controller port map(
        clk => CLK, 
        mybus_m_stream_data => MYBUS_STREAM_DATA, 
        mybus_m_stream_flags => MYBUS_STREAM_FLAGS, 
        mybus_m_stream_valid => MYBUS_STREAM_VALID, 
        mybus_m_stream_ready => MYBUS_STREAM_READY,
        send_packet_command => SND_PKT_CMD,
        packet_size => PKT_SIZE
    );      

end;


