
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity h_sync_gen is
    port ( clk       : in  std_logic;
           reset     : in  std_logic;
           h_sync    : out std_logic;
           blank     : out std_logic;
           completed : out std_logic;
           column    : out unsigned(10 downto 0)
     );
end h_sync_gen;

architecture Cooper of h_sync_gen is
	type states is (activeVideo, frontPorch, sync, backPorch);
	signal state_reg, state_next: states;
	signal clock_state, clock_next: unsigned(10 downto 0);
begin

	-- state register
   process(clk,reset)
   begin
      if (reset='1') then
         state_reg <= activeVideo;
			clock_state <= (others => '0');
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
			clock_state <= clock_next;
      end if;
   end process;
	
	--Next State Logic
	process(clk) is
	begin
			clock_next <= clock_state +1;
			state_next <= state_next;
			if(clock_state = 799) then
				state_next <= activeVideo;
				clock_next <= (others => '0');
			elsif(clock_state = 639) then
				state_next <= frontPorch;
			elsif(clock_state = 655) then
				state_next <= sync;
			elsif(clock_state = 751) then
				state_next <= backPorch;
			end if;
	end process;
	
	--Output Logic
	h_sync <= '0' when state_reg = sync else
				 '1';
	blank  <= '0' when state_reg = activeVideo else
	          '1';
	column <= clock_state when clock_state < 640 else
				 (others => '0');
	completed <= '1' when clock_state = 799 else
					 '0';

end Cooper;


architecture moore of h_sync_gen is
                type h_state_type is (active_video, front_porch, sync, back_porch, cycle_complete);
                signal state_reg, state_next : h_state_type;
                
                signal count_next, count_reg : unsigned(10 downto 0);
                
                signal h_sync_next, blank_next, completed_next : std_logic;
                signal h_sync_reg, blank_reg, completed_reg : std_logic;
                signal column_next, column_reg : unsigned(10 downto 0);
                
                constant back_porch_count : unsigned(10 downto 0) := to_unsigned(47,11);                                      -- one less becasue cycle_complete gets a clock cycle
                constant front_porch_count : unsigned(10 downto 0) := to_unsigned(16,11);
                constant sync_count : unsigned(10 downto 0) := to_unsigned(96,11);
                constant active_video_count : unsigned(10 downto 0) := to_unsigned(640,11);
begin

                -- state reg
                
                process (clk, reset)
                begin
                                if reset = '1' then
                                                state_reg <= active_video;
                                elsif rising_edge(clk) then
                                                state_reg <= state_next;
                                end if;
                end process;
                
                
                -- count reg
                
                count_next <= (others => '0') when state_next /= state_reg else
                                                                                                count_reg + 1;
                                                                                                
                process (clk, reset)
                begin
                                if reset = '1' then
                                                count_reg <= (others => '0');
                                elsif rising_edge(clk) then
                                                count_reg <= count_next;
                                end if;
                end process;

                -- next state logic
                process (state_reg, count_reg)
                begin
                                -- default
                                state_next <= state_reg;
                                
                                case state_reg is
                                                when active_video =>
                                                                if count_reg = (active_video_count - 1) then
                                                                                state_next <= front_porch;
                                                                end if;
                                                when front_porch =>
                                                                if count_reg = (front_porch_count - 1) then
                                                                                state_next <= sync;
                                                                end if;
                                                when sync =>
                                                                if count_reg = (sync_count - 1) then
                                                                                state_next <= back_porch;
                                                                end if;
                                                when back_porch =>
                                                                if count_reg = (back_porch_count - 1) then
                                                                                state_next <= cycle_complete;
                                                                end if;
                                                when cycle_complete =>
                                                                state_next <= active_video;
                                end case;
                end process;

                -- output logic
                process (state_next, count_next)
                begin
                                -- defaults
                                h_sync_next <= '0';
                                blank_next <= '0';
                                completed_next <= '0';
                                column_next <= (others => '0');
                                
                                case state_next is
                                                when active_video =>
                                                                column_next <= count_next;
                                                                h_sync_next <= '1';
                                                when front_porch =>
                                                                h_sync_next <= '1';
                                                                blank_next <= '1';
                                                when sync =>
                                                                blank_next <= '1';
                                                when back_porch =>
                                                                h_sync_next <= '1';
                                                                blank_next <= '1';
                                                when cycle_complete =>
                                                                h_sync_next <= '1';
                                                                blank_next <= '1';
                                                                completed_next <= '1';
                                end case;
                end process;
                
                -- look-ahead buffer
                process (clk)
                begin
                                if rising_edge(clk) then
                                                h_sync_reg <= h_sync_next;
                                                blank_reg <= blank_next;
                                                completed_reg <= completed_next;
                                                column_reg <= column_next;
                                end if;
                end process;
                
                h_sync <= h_sync_reg;
                blank <= blank_reg;
                completed <= completed_reg;
                column <= column_reg;
end moore;

