
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY test_cool IS
END test_cool;
 
ARCHITECTURE behavior OF test_cool IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cool_sauce
    PORT(
         clk : IN  std_logic;
         SW : IN  std_logic_vector(7 downto 0);
         LED : OUT  std_logic_vector(7 downto 0);
         reset : IN  std_logic;
         BTN0 : IN  std_logic;
         uart_rx : IN  std_logic;
         uart_tx : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal SW : std_logic_vector(7 downto 0) := (others => '0');
   signal reset : std_logic := '0';
   signal BTN0 : std_logic := '0';
   signal uart_rx : std_logic := '0';

 	--Outputs
   signal LED : std_logic_vector(7 downto 0);
   signal uart_tx : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cool_sauce PORT MAP (
          clk => clk,
          SW => SW,
          LED => LED,
          reset => reset,
          BTN0 => BTN0,
          uart_rx => uart_rx,
          uart_tx => uart_tx
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
		reset<='1';
		wait for clk_period*5;
		reset <='0';
      -- hold reset state for 100 ns.	
		uart_rx<='1';
		wait for 104 us;
		uart_rx<='0';
		wait for 104 us;
		uart_rx<='1';
		wait for 104 us;
      wait;
   end process;

END;
