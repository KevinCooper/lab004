
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity pixel_gen is
    port ( row      : in unsigned(10 downto 0);
           column   : in unsigned(10 downto 0);
           blank    : in std_logic;
			  color1	  : in std_logic_vector(31 downto 0);
           r        : out std_logic_vector(7 downto 0);
           g        : out std_logic_vector(7 downto 0);
           b        : out std_logic_vector(7 downto 0));
end pixel_gen;

architecture Cooper of pixel_gen is

begin


process( row, column, color1, color2, blank) is
begin
	if(blank ='1') then
		r<="00000000";
		g<="00000000";
		b<="00000000";
	elsif( color1(0) ='1' and color1(1) ='1') then
		g<="11111111";
	elsif( color1(0) ='0' and color1(1) ='1') then
		b<="11111111";
	elsif( color1(0) ='1' and color1(1) ='0') then
		r<="11111111";
	end if;
end process;


end Cooper;

