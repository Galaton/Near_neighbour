library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Dist_eucl is

	generic(	DATA_WIDTH : natural := 8	);
	port(
		clk		: in std_logic;
		reset	: in std_logic;
		x1 		: in std_logic_vector(DATA_WIDTH -1 downto 0);
		x2 		: in std_logic_vector(DATA_WIDTH -1 downto 0);
		y1 		: in std_logic_vector(DATA_WIDTH -1 downto 0);
		y2 		: in std_logic_vector(DATA_WIDTH -1 downto 0);
		result : out std_logic_vector((2*DATA_WIDTH) -1 downto 0)
	);

end entity;

architecture rtl of Dist_eucl is

	-- entry registers
	signal reg_x1, reg_x2,reg_y1,reg_y2 : std_logic_vector(DATA_WIDTH -1 downto 0) :=(others => '0');
	-- Registers 2n
	signal reg_mult1,reg_mult2,reg_out : std_logic_vector((2*DATA_WIDTH) -1 downto 0) :=(others => '0');

	-- Operations 2n
	signal mult1,mult2,sqr : std_logic_vector(((2*DATA_WIDTH) -1) downto 0);
	-- Operations 4n
	signal add :std_logic_vector(((4*DATA_WIDTH) -1) downto 0) :=(others => '0');
	-- SimpleOperations
	signal sub1,sub2 : std_logic_vector(DATA_WIDTH -1 downto 0);

	-- Adds zeros
	signal zeros :std_logic_vector(((2*DATA_WIDTH) -1) downto 0):=(others => '0');

	function  sqrt  ( d : UNSIGNED ) return UNSIGNED is
	  variable a : unsigned(31 downto 0):=d;  --original input.
	  variable q : unsigned(15 downto 0):=(others => '0');  --result.
	  variable left,right,r : unsigned(17 downto 0):=(others => '0');  --input to adder/sub.r-remainder.
	  variable i : integer:=0;

	  begin

	    for i in 0 to 15 loop
	      right(0):='1';
	      right(1):=r(17);
	      right(17 downto 2):=q;
	      left(1 downto 0):=a(31 downto 30);
	      left(17 downto 2):=r(15 downto 0);
	      a(31 downto 2):=a(29 downto 0);  --shifting by 2 bit.
	      if ( r(17) = '1') then
	        r := left + right;
	      else
	        r := left - right;
	      end if;
	      q(15 downto 1) := q(14 downto 0);
	      q(0) := not r(17);
	    end loop;
	  return q;
	end sqrt;

begin

	process (clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				reg_x1 <= (others => '0');
			else
				reg_x1 <= x1;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				reg_x2 <= (others => '0');
			else
				reg_x2 <= x2;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				reg_y1 <= (others => '0');
			else
				reg_y1 <= y1;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				reg_y2 <= (others => '0');
			else
				reg_y2 <= y2;
			end if;
		end if;
	end process;

	sub1 <= std_logic_vector(unsigned(reg_x1) - unsigned(reg_x2));
	sub2 <= std_logic_vector(unsigned(reg_y1) - unsigned(reg_y2));

	mult1 <= std_logic_vector(signed(sub1) * signed(sub1));
	mult2 <= std_logic_vector(signed(sub2) * signed(sub2));

	process (clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				reg_mult1 <= (others => '0');
			else
				reg_mult1 <= mult1;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				reg_mult2 <= (others => '0');
			else
				reg_mult2 <= mult2;
			end if;
		end if;
	end process;

	add <= zeros & std_logic_vector(unsigned(reg_mult1) + unsigned(reg_mult2));

	sqr <= std_logic_vector(sqrt(unsigned(add)));

	process (clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				reg_out <= (others => '0');
			else
				reg_out <= sqr;
			end if;
		end if;
	end process;

	result <= reg_out;

end rtl;
