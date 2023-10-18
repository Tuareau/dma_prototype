library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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
    type REG_MAP is array (0 to 2**4) of std_logic_vector(31 downto 0);
    signal registers_map: REG_MAP;
--    type REG_IDX is (BD_BASE_ADDR, 
--                     BD_SIZE,
--                     BD_CURR_ADDR,
--                     BD_FLAGS,
--                     MEM_BASE_ADDR,
--                     MEM_SIZE,
--                     MEM_CURR_ADDR,
--                     PKT_LEN,
--                     PKT_NUM);    
    type STATE is (IDLE, RX_LSB, RX_MSB, WR_BUF, WR_DESC);
    signal dma_state: STATE := IDLE;
    
    signal rx_packet_len: std_logic_vector(63 downto 0);
    signal rx_packet_num: std_logic_vector(63 downto 0);
    signal word_buffer: std_logic_vector(63 downto 0);
    
    signal eop_flag: std_logic;
    
begin
    process(clk) begin    
        if rising_edge(clk) then   
            
            -- LITE INTERFACE LOGIC
            if mybus_s_lite_write = '1' then            
                registers_map(to_integer(unsigned(mybus_s_lite_address))) <= mybus_s_lite_data_in;
            else
                mybus_s_lite_data_out <= registers_map(to_integer(unsigned(mybus_s_lite_address)));
            end if;
            
            -- MYBUS DMA LOGIC
            case dma_state is              
                when IDLE =>                     
                    rx_packet_len <= X"0000_0000";
                    rx_packet_num <= X"0000_0000";
                    
                    word_buffer <= X"0000_0000";
                    eop_flag <= '0';
                    
                    mem_overflow_intr <= '0';
                    rx_packet_intr <= '0';
                    
                    mybus_s_stream_ready <= '1';
                    if (mybus_s_stream_valid = '1') then                        
                        dma_state <= RX_LSB;
                    end if;       
                                 
                when RX_LSB =>     
                    mem_overflow_intr <= '0';
                    rx_packet_intr <= '0';
                                            
                    if (mybus_s_stream_valid = '1') then
                        word_buffer(31 downto 0) <= mybus_s_stream_data;   
                        if (mybus_s_stream_flags = B"0001") then
                            eop_flag <= '1';
                            rx_packet_num <= std_logic_vector(unsigned(rx_packet_num) + 1); 
                        end if;
                        rx_packet_len <= std_logic_vector(unsigned(rx_packet_len) + 1);                       
                    
                        mybus_s_stream_ready <= '1';
                        dma_state <= RX_MSB;                                           
                    end if; 
                    
                when RX_MSB =>  
                    mem_overflow_intr <= '0';
                    rx_packet_intr <= '0';
                      
                    if (mybus_s_stream_valid = '1') then                 
                        word_buffer(63 downto 32) <= mybus_s_stream_data; 
                        if (mybus_s_stream_flags = B"0001") then
                            eop_flag <= '1';
                            rx_packet_num <= std_logic_vector(unsigned(rx_packet_num) + 1); 
                        end if;    
                        rx_packet_len <= std_logic_vector(unsigned(rx_packet_len) + 1);  
                                                     
                        mybus_s_stream_ready <= '0';
                        dma_state <= WR_BUF;
                    end if; 
                    
                when WR_BUF =>   
                      if (mybus_m_ready = '1') then
                          mybus_m_address <= registers_map(6);
                          registers_map(6) <= std_logic_vector(unsigned(registers_map(6)) + 1);  
                          mybus_m_data <= word_buffer;   
                          mybus_m_write <= '1';       
                          if (unsigned(registers_map(6)) - unsigned(registers_map(4)) > unsigned(registers_map(5))) then
                              mem_overflow_intr <= '1';                                    
                          else 
                              mem_overflow_intr <= '0';
                          end if;                          
                      end if;   
                      
                      if (eop_flag = '1' and unsigned(rx_packet_len) = unsigned(registers_map(7))) then 
                          dma_state <= WR_DESC;                      
                      else
                          dma_state <= IDLE;  
                      end if; 
                 
                 when WR_DESC =>   
                      if (mybus_m_ready = '1') then
                          mybus_m_address <= registers_map(2);
                          registers_map(2) <= std_logic_vector(unsigned(registers_map(6)) + 1);  
                          mybus_m_data(62 downto 0) <= rx_packet_len;
                          if unsigned(rx_packet_len) = unsigned(registers_map(7)) then
                              mybus_m_data(63) <= '0';  -- EOP 
                          else 
                              mybus_m_data(63) <= '1';  -- EEP
                          end if;  
                          mybus_m_write <= '1';                          
                      end if;   
                      dma_state <= IDLE;  
                      rx_packet_intr <= '1';                    
             end case;         
        end if;        
    end process;
end synchronous;
