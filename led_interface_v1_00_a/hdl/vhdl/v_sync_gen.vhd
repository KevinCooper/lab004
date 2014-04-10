
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity v_sync_gen is
    port ( clk         : in  std_logic;
           reset       : in std_logic;
           h_blank     : in std_logic;
           h_completed : in std_logic;
           v_sync      : out std_logic;
           blank       : out std_logic;
           completed   : out std_logic;
           row         : out unsigned(10 downto 0)
     );
end v_sync_gen;

architecture Cooper of v_sync_gen is
	type states is (activeVideo, frontPorch, sync, backPorch);
	signal state_reg, state_next: states;
	signal clock_state, clock_next: unsigned(10 downto 0);
begin

	clock_next <= clock_state + 1;
	
	-- state register
   process(clk,reset)
   begin
		--clock_next <= clock_state +1;
      if (reset='1') then
         state_reg <= activeVideo;
			clock_state <= (others => '0');
      elsif (clk'event and clk='1' and h_completed='1') then
         state_reg <= state_next;
			if(clock_state = 524) then
				clock_state <= (others => '0');
			else
				clock_state <= clock_next;
			end if;
      end if;
   end process;
	
	--Next State Logic
	process(clock_state) is
	begin
		state_next <= state_next;
		if(clock_state = 524) then
			state_next <= activeVideo;
		elsif(clock_state = 479) then
			state_next <= frontPorch;
		elsif(clock_state = 489) then
			state_next <= sync;
		elsif(clock_state = 491) then
			state_next <= backPorch;
		end if;
	end process;
	
	--Output Logic
	v_sync <= '0' when state_reg = sync else
				 '1';
	blank  <= '0' when state_reg = activeVideo else
	          '1';
	row <= clock_state when clock_state < 480 else
				 (others => '0');
	completed <= '1' when clock_state = 524 else
					 '0';
end Cooper;

architecture moore of v_sync_gen is
                type v_state_type is (active_video, front_porch, sync, back_porch, cycle_complete);
                signal state_next, state_reg : v_state_type;

                signal count_next, count_reg : unsigned(10 downto 0);

                signal v_sync_next, v_sync_reg : std_logic;
                signal blank_next, blank_reg : std_logic;
                signal completed_next, completed_reg : std_logic;
                signal row_next, row_reg : unsigned(10 downto 0);
                
                shared variable active_video_cycles : natural := 480;
                shared variable front_porch_cycles : natural := 10;           
                shared variable sync_cycles : natural := 2;
                shared variable back_porch_cycles : natural := 33;
begin
                -- next count
                count_next <= (others => '0') when state_next /= state_reg else
                                                                                                count_reg + 1 when h_completed = '1' else
                                                                                                count_reg;
                
                -- count reg
                process (clk, reset)
                begin
                                if reset = '1' then
                                                count_reg <= (others => '0');
                                elsif rising_edge(clk) then
                                                count_reg <= count_next;
                                else
                                                count_reg <= count_reg;
                                end if;
                end process;
                
                -- state reg
                process (clk, reset)
                begin
                                if reset = '1' then
                                                state_reg <= active_video;
                                elsif rising_edge(clk) then
                                                state_reg <= state_next;
                                else
                                                state_reg <= state_reg;
                                end if;
                end process;
                
                -- next state
                process (state_reg, count_reg, h_completed)
                begin
                                state_next <= state_reg;
                                
                                if h_completed = '1' then
                                                case state_reg is
                                                                when active_video =>
                                                                                if count_reg = (active_video_cycles - 1) then
                                                                                                state_next <= front_porch;
                                                                                end if;
                                                                when front_porch =>    
                                                                                if count_reg = (front_porch_cycles - 1) then
                                                                                                state_next <= sync;
                                                                                end if;
                                                                when sync =>
                                                                                if count_reg = (sync_cycles - 1) then
                                                                                                state_next <= back_porch;
                                                                                end if;
                                                                when back_porch =>                     
                                                                                if count_reg = (back_porch_cycles - 2) then                                        -- -2 to account for one cycle in cycle complete
                                                                                                state_next <= cycle_complete;
                                                                                end if;
                                                                when cycle_complete =>             
                                                                                state_next <= active_video;
                                                end case;
                                end if;
                end process;
                
                -- next output
                v_sync_next <= '0' when state_next = sync else '1';
                blank_next <= '0' when state_next = active_video else '1';
                completed_next <= '1' when state_next = cycle_complete else '0';
                row_next <= count_next when state_next = active_video else (others => '0');
                
                -- look ahead buffers
                process (clk)
                begin
                                if rising_edge(clk) then
                                                v_sync_reg <= v_sync_next;
                                                blank_reg <= blank_next;
                                                completed_reg <= completed_next;
                                                row_reg <= row_next;
                                end if;
                end process;
                
                -- assigning outputs
                v_sync <= v_sync_reg;
                blank <= blank_reg;
                completed <= completed_reg;
                row <= row_reg;
                
end moore;
