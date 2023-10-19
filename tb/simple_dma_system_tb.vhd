library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity simple_dma_system_tb is
end simple_dma_system_tb;

architecture sim of simple_dma_system_tb is

    component simple_dma_system
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
    end component;

    signal clk: std_logic := '0';
    
    signal mybus_m_lite_address: std_logic_vector(4 downto 0) := (others => '0');
    signal mybus_m_lite_data_in: std_logic_vector(31 downto 0) := (others => '0');
    signal mybus_m_lite_data_out: std_logic_vector(31 downto 0) := (others => '0');
    signal mybus_m_lite_write: std_logic := '0';
    
    signal mem_overflow_intr: std_logic;
    signal rx_pkt_intr: std_logic;
    
    signal pkt_size: std_logic_vector(31 downto 0) := (others => '0');
    signal snd_pkt_cmd: std_logic := '0';
    
begin    

    dma_system: simple_dma_system port map(
        CLK => clk,
        MYBUS_M_LITE_ADDRESS => mybus_m_lite_address,
        MYBUS_M_LITE_DATA_IN => mybus_m_lite_data_in,
        MYBUS_M_LITE_DATA_OUT => mybus_m_lite_data_out,
        MYBUS_M_LITE_WRITE => mybus_m_lite_write,
        MEM_OVERFLOW_INTR => mem_overflow_intr,
        RX_PKT_INTR => rx_pkt_intr,
        PKT_SIZE => pkt_size,
        SND_PKT_CMD => snd_pkt_cmd
    );    
    
    clk_gen: process begin
        clk <= '0';
        wait for 5ns;
        clk <= '1';
        wait for 5ns;    
    end process clk_gen;
    
    sim: process begin
        wait for 20ns;
        -- INIT PACKET TRAFFIC PARAMETERS
        pkt_size <= std_logic_vector(to_unsigned(32, pkt_size'length)); -- 32 bytes
        snd_pkt_cmd <= '0';
        wait for 10ns;
        -- SET DMA REGISTERS
        wait until clk = '1';
        mybus_m_lite_address <= B"0_0000"; -- BD_BASE_ADDR
        mybus_m_lite_data_in <= X"0000_0000"; -- is 0x0000
        mybus_m_lite_write <= '1';
        wait for 5ns;
        mybus_m_lite_write <= '0';
        wait for 10ns;
        
        wait until clk = '1';
        mybus_m_lite_address <= B"0_0001"; -- BD_SIZE
        mybus_m_lite_data_in <= X"0000_0200"; -- is 512 64-bit words
        mybus_m_lite_write <= '1';
        wait for 5ns;
        mybus_m_lite_write <= '0';
        wait for 10ns;

        wait until clk = '1';
        mybus_m_lite_address <= B"0_0010"; -- BD_CURR_ADDR
        mybus_m_lite_data_in <= X"0000_0000"; -- is 0x0000
        mybus_m_lite_write <= '1';
        wait for 5ns;
        mybus_m_lite_write <= '0';
        wait for 10ns;        
 
        wait until clk = '1';
        mybus_m_lite_address <= B"0_0011"; -- BD_FLAGS
        mybus_m_lite_data_in <= X"F0F0_F0F0"; -- is 0xF0F0...
        mybus_m_lite_write <= '1';
        wait for 5ns;
        mybus_m_lite_write <= '0';
        wait for 10ns;  
        
        wait until clk = '1';
        mybus_m_lite_address <= B"0_0100"; -- MEM_BASE_ADDR
        mybus_m_lite_data_in <= X"0000_1000"; -- is 0x0000_1000
        mybus_m_lite_write <= '1';
        wait for 5ns;
        mybus_m_lite_write <= '0';
        wait for 10ns;  
        
        wait until clk = '1';
        mybus_m_lite_address <= B"0_0101"; -- MEM_SIZE
        mybus_m_lite_data_in <= X"0000_4000"; -- is 16384 64-bit words
        mybus_m_lite_write <= '1';
        wait for 5ns;
        mybus_m_lite_write <= '0';
        wait for 10ns;  
        
        wait until clk = '1';
        mybus_m_lite_address <= B"0_0110"; -- MEM_CURR_ADDR
        mybus_m_lite_data_in <= X"0000_1000"; -- is 0x0000_1000
        mybus_m_lite_write <= '1';
        wait for 5ns;
        mybus_m_lite_write <= '0';
        wait for 10ns;     
        
        wait until clk = '1';
        mybus_m_lite_address <= B"0_0111"; -- PKT_LEN
        mybus_m_lite_data_in <= X"0000_0020"; -- is 4 * 8 = 32 bytes
        mybus_m_lite_write <= '1';
        wait for 5ns;
        mybus_m_lite_write <= '0';
        wait for 10ns;                
        
        wait until clk = '1';
        mybus_m_lite_address <= B"0_1000"; -- PKT_NUM
        mybus_m_lite_data_in <= X"0000_0003"; -- is 3 packets
        mybus_m_lite_write <= '1';
        wait for 5ns;
        mybus_m_lite_write <= '0';
        wait for 50ns;  
        
        -- SEND PACKET #1
        wait until clk = '1';
        snd_pkt_cmd <= '1';
        wait for 5ns;
        snd_pkt_cmd <= '0';
        wait on rx_pkt_intr; 
        wait for 50ns;      
               
        -- SEND PACKET #2
        wait until clk = '1';
        snd_pkt_cmd <= '1';
        wait for 5ns;
        snd_pkt_cmd <= '0';
        wait on rx_pkt_intr; 
        wait for 50ns;    
        
        -- SEND PACKET #3
        wait until clk = '1';
        snd_pkt_cmd <= '1';
        wait for 5ns;
        snd_pkt_cmd <= '0';
        wait on rx_pkt_intr; 
        wait for 50ns;    
        
        -- END SIMULATION
        wait;         
          
    end process sim;    

end sim;
