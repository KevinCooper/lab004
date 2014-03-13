--Author: Kevin Cooper
--Purpose: Implement the picoblaze processor, utilize the same port for input and output
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity cool_sauce is
    port ( 
             clk   : in  std_logic; -- 100 MHz
				 SW: in STD_LOGIC_VECTOR(7 downto 0);
				 LED: out STD_LOGIC_VECTOR(7 downto 0);
				 reset: in STD_LOGIC;
				 BTN0: in STD_LOGIC;
				 uart_rx : in std_logic;
				 uart_tx : out std_logic
         );
end cool_sauce;

architecture Cooper of cool_sauce is

  component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
             scratch_pad_memory_size : integer := 64);
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
  end component;
  
 component custom_rom                           
    generic(             C_FAMILY : string := "S6"; 
                C_RAM_SIZE_KWORDS : integer := 1;
             C_JTAG_LOADER_ENABLE : integer := 0);
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;
  
  component uart_tx6
		Port ( data_in : in std_logic_vector(7 downto 0);
			en_16_x_baud : in std_logic;
			serial_out : out std_logic;
			buffer_write : in std_logic;
			buffer_data_present : out std_logic;
			buffer_half_full : out std_logic;
			buffer_full : out std_logic;
			buffer_reset : in std_logic;
			clk : in std_logic);
end component;

component uart_rx6
		Port ( serial_in : in std_logic;
			en_16_x_baud : in std_logic;
			data_out : out std_logic_vector(7 downto 0);
			buffer_read : in std_logic;
			buffer_data_present : out std_logic;
			buffer_half_full : out std_logic;
			buffer_full : out std_logic;
			buffer_reset : in std_logic;
			clk : in std_logic);
end component;
  
--
--
-- Signals used to connect KCPSM6
--
signal         address : std_logic_vector(11 downto 0);
signal     instruction : std_logic_vector(17 downto 0);
signal     bram_enable : std_logic;
signal         in_port : std_logic_vector(7 downto 0);
signal        out_port : std_logic_vector(7 downto 0);
signal         port_id : std_logic_vector(7 downto 0);
signal    write_strobe : std_logic;
signal  k_write_strobe : std_logic;
signal     read_strobe : std_logic;
signal       interrupt : std_logic;
signal   interrupt_ack : std_logic;
signal    kcpsm6_sleep : std_logic;
signal    kcpsm6_reset : std_logic;
signal 	 LEDS: STD_LOGIC_VECTOR(7 downto 0);
signal SWS: STD_LOGIC_VECTOR(7 downto 0);
signal BTNSS: STD_LOGIC_VECTOR(7 downto 0);
--
--Signals used for the Baud rate
--
signal baud_count : integer range 0 to 325 := 0;
signal en_16_x_baud : std_logic := '0';
--
-- Signals used to connect UART_TX6
--
signal      uart_tx_data_in : std_logic_vector(7 downto 0);
signal     write_to_uart_tx : std_logic;
signal uart_tx_data_present : std_logic;
signal    uart_tx_half_full : std_logic;
signal         uart_tx_full : std_logic;
signal         uart_tx_reset : std_logic;
--
-- Signals used to connect UART_RX6
--
signal     uart_rx_data_out : std_logic_vector(7 downto 0);
signal    read_from_uart_rx : std_logic;
signal uart_rx_data_present : std_logic;
signal    uart_rx_half_full : std_logic;
signal         uart_rx_full : std_logic;
signal        uart_rx_reset : std_logic;

begin


  --
  -- In many designs (especially your first) interrupt and sleep are not used.
  -- Tie these inputs Low until you need them. Tying 'interrupt' to 'interrupt_ack' 
  -- preserves both signals for future use and avoids a warning message.
  -- 
  kcpsm6_sleep <= '0';
  interrupt <= interrupt_ack;
processor: kcpsm6
    generic map (                 hwbuild => X"00", 
                         interrupt_vector => X"3FF",
                  scratch_pad_memory_size => 64)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => k_write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     sleep => kcpsm6_sleep,
                     reset => kcpsm6_reset,
                       clk => clk);
							  
  test: custom_rom                   --Name to match your PSM file
    generic map(             C_FAMILY => "S6",   --Family 'S6', 'V6' or '7S'
                    C_RAM_SIZE_KWORDS => 2,      --Program size '1', '2' or '4'
                 C_JTAG_LOADER_ENABLE => 1)      --Include JTAG Loader when set to '1' 
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => kcpsm6_reset,
                       clk => clk);
							  
	tx: uart_tx6
		port map ( 
			data_in => uart_tx_data_in,
			en_16_x_baud => en_16_x_baud,
			serial_out => uart_tx,
			buffer_write => write_to_uart_tx,
			buffer_data_present => uart_tx_data_present,
			buffer_half_full => uart_tx_half_full,
			buffer_full => uart_tx_full,
			buffer_reset => uart_tx_reset,
			clk => clk);
			
	rx: uart_rx6
		port map ( 
			serial_in => uart_rx,
			en_16_x_baud => en_16_x_baud,
			data_out => uart_rx_data_out ,
			buffer_read => read_from_uart_rx,
			buffer_data_present => uart_rx_data_present,
			buffer_half_full => uart_rx_half_full,
			buffer_full => uart_rx_full,
			buffer_reset => uart_rx_reset,
			clk => clk);
			
	output_ports: process( clk, write_strobe)
	begin
		LEDS <= LEDS;
		if(rising_edge(clk) and write_strobe='1') then
			if(port_id=x"07") then
				LED <= out_port;
			end if;
		end if;
	end process;

	input_ports: process( clk, read_strobe)
	begin
		if(rising_edge(clk) and read_strobe='1') then
			if(port_id=X"AF") then
				in_port <= SW;
			end if;
			if(port_id=X"07") then
				in_port <= BTN0 & BTN0 & BTN0 & BTN0 & BTN0 & BTN0 & BTN0 & BTN0;
			end if;
		end if;
	end process;
	
	baud_rate: process(clk)
	begin
		if clk'event and clk = '1' then
			if baud_count = 325 then
				baud_count <= 0;
				en_16_x_baud <= '1';
			else
				baud_count <= baud_count + 1;
				en_16_x_baud <= '0';
			end if;
		end if;
	end process baud_rate;
	
	--LED Output
end Cooper;