library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity atlys_lab_video is
    port ( 
             clk   : in  std_logic; -- 100 MHz
             reset : in  std_logic;
			 color : in std_logic_vector( 31 downto 0);
             tmds  : out std_logic_vector(3 downto 0);
             tmdsb : out std_logic_vector(3 downto 0)
         );
end atlys_lab_video;

architecture Cooper of atlys_lab_video is
signal blue, green, red : std_logic_vector(7 downto 0);
signal red_s, blue_s, green_s, clock_s: std_logic;
signal row, column: unsigned(10 downto 0);
signal v_sync, h_sync: std_logic;
signal pixel_clk, serialize_clk, serialize_clk_n: std_logic;
signal v_completed, blank: std_logic;
begin



    -- Clock divider - creates pixel clock from 100MHz clock
    inst_DCM_pixel: DCM
    generic map(
                   CLKFX_MULTIPLY => 2,
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => pixel_clk
            );

    -- Clock divider - creates HDMI serial output clock
    inst_DCM_serialize: DCM
    generic map(
                   CLKFX_MULTIPLY => 10, -- 5x speed of pixel clock
                   CLKFX_DIVIDE   => 8,
                   CLK_FEEDBACK   => "1X"
               )
    port map(
                clkin => clk,
                rst   => reset,
                clkfx => serialize_clk,
                clkfx180 => serialize_clk_n
            );

    --VGA component instantiation
	 inst_vga_sync: entity work.vga_sync(moore)
	 port map(
				clk => pixel_clk,
				reset => reset,
				h_sync=>h_sync,
				v_sync=>v_sync,
				v_completed=>v_completed,
				blank=>blank,
				row=> row,
				column=> column
				);
    --Pixel generator component instantiation
	 inst_pixel_gen: entity work.pixel_gen
	 port map (
					row=> row,
					column=> column,
					blank=> blank,
					color1 => color,
					r=>red,
					g=>green,
					b=>blue
					);

    -- Convert VGA signals to HDMI (actually, DVID ... but close enough)
    inst_dvid: entity work.dvid
    port map(
                clk       => serialize_clk,
                clk_n     => serialize_clk_n, 
                clk_pixel => pixel_clk,
                red_p     => red,
                green_p   => green,
                blue_p    => blue,
                blank     => blank,
                hsync     => h_sync,
                vsync     => v_sync,
                -- outputs to TMDS drivers
                red_s     => red_s,
                green_s   => green_s,
                blue_s    => blue_s,
                clock_s   => clock_s
            );

    -- Output the HDMI data on differential signalling pins
    OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
    OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
    OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
    OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );

end Cooper;