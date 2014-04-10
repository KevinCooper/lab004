
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity vga_sync is
    port ( clk         : in  std_logic;
           reset       : in  std_logic;
           h_sync      : out std_logic;
           v_sync      : out std_logic;
           v_completed : out std_logic;
           blank       : out std_logic;
           row         : out unsigned(10 downto 0);
           column      : out unsigned(10 downto 0)
     );
end vga_sync;


architecture Cooper of vga_sync is


signal wire_vblank, wire_hblank: std_logic;
signal wire_hcompleted: std_logic;
begin

	my_v : entity work.v_sync_gen(Cooper) 
	port map
	(
	clk=> clk,
	reset=>reset,
	h_blank=>wire_hblank,
	h_completed=>wire_hcompleted,
	v_sync=>v_sync,
	blank=>wire_vblank,
	completed=>v_completed,
	row=>row
	);
	
	my_h : entity work.h_sync_gen(Cooper)
	port map
	(
	clk=> clk,
	reset=>reset,
	h_sync=>h_sync,
	blank=>wire_hblank,
	completed=>wire_hcompleted,
	column=>column
	);

--output signals
blank <= wire_hblank or wire_vblank;

end Cooper;

architecture moore of vga_sync is


signal wire_vblank, wire_hblank: std_logic;
signal wire_hcompleted: std_logic;
begin

	my_v : entity work.v_sync_gen(moore) 
	port map
	(
	clk=> clk,
	reset=>reset,
	h_blank=>wire_hblank,
	h_completed=>wire_hcompleted,
	v_sync=>v_sync,
	blank=>wire_vblank,
	completed=>v_completed,
	row=>row
	);
	
	my_h : entity work.h_sync_gen(moore)
	port map
	(
	clk=> clk,
	reset=>reset,
	h_sync=>h_sync,
	blank=>wire_hblank,
	completed=>wire_hcompleted,
	column=>column
	);

--output signals
blank <= wire_hblank or wire_vblank;

end moore;