library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Near_neighbour is

	generic(	DATA_WIDTH : natural := 8	);
	port(
		clk		: in std_logic;
		reset	: in std_logic;
		data 		: in std_logic_vector((4*DATA_WIDTH) -1 downto 0);
		request : in std_logic;
		ack 		: out std_logic := '0';
		interrupt : out std_logic;
		result  : out std_logic
	);

end entity;

architecture rtl of Near_neighbour is

	-- input signals
	signal x1_sg,x2_sg,y1_sg,y2_sg : std_logic_vector((DATA_WIDTH) -1 downto 0) := (others => '0');

	type state_type is (s0,s1, s2);
	signal state   : state_type := s0;

	-- Distance euclidian output
	signal de_result_sg : std_logic_vector((2*DATA_WIDTH) -1 downto 0) := (others => '0');

	-- signal that holds zero and its turned into one onece that state machine ack
	-- that is requesting sending
	--signal val : std_logic := '0';

	-- aux to the state zero
	-- aux = 00 -> didn`t recived anything
	-- aux = 01 -> read to recive minimum Distance
	-- aux = 10 -> recived minimum Distance
	-- aux = 11 -> read to recive minimum neighbour
	signal aux : std_logic_vector(1 downto 0) := "00";

	signal min_distance,min_neighbours :  std_logic_vector((4*DATA_WIDTH) -1 downto 0):= (others => '0');

	-- counter with the amount of min_neighbours
	signal neigh_numb : std_logic_vector((4*DATA_WIDTH) -1 downto 0):= (others => '0');
	signal one : unsigned(15 downto 0):= "0000000000000001";

	-- interrupt
	signal interrupt_sg : std_logic := '0';

	component Dist_eucl is
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
	end component;

begin

	process (clk, reset)
	begin
		if (falling_edge(clk)) then
			if reset = '1' then
				state <= s0;
				aux <= "00";
			elsif (state = s0 and request = '1' and aux ="00") then
				-- in the state zero first recive the minimum distance and second
				-- the minimum neighbours from the data chanel
				ack <= '1';
				aux <= "01";
			elsif (state = s0 and request = '0' and aux = "01") then
				ack <= '0';
				min_distance <= data;
				aux <= "10";
			elsif (state = s0 and request = '1' and aux = "10") then
				ack <= '1';
				aux <= "11";
			elsif (state = s0 and request = '0' and aux = "11") then
				ack <= '0';
				min_neighbours <= data;
				state <= s1;

			elsif (state = s1 and request = '1') then
				--val <= '1';
				ack <= '1';
				state <= s2;

				x1_sg <= (others => '0');
				x2_sg <= (others => '0');
				y1_sg <= (others => '0');
				y2_sg <= (others => '0');

			elsif (state = s2 and request = '0' ) then
				--val <= '0';
				ack <= '0';
				-- read the data from input chanel
				x1_sg <= data((4*DATA_WIDTH) -1 downto (3*DATA_WIDTH) );
				x2_sg <= data((3*DATA_WIDTH) -1 downto (2*DATA_WIDTH) );
				y1_sg <= data((2*DATA_WIDTH) -1 downto (DATA_WIDTH) );
				y2_sg <= data((DATA_WIDTH) -1 downto 0 );
				state <= s1;

			else	-- every time that it`s not sending the data recived from the processor
						-- it must send zeros to the dist euclidian
				x1_sg <= (others => '0');
				x2_sg <= (others => '0');
				y1_sg <= (others => '0');
				y2_sg <= (others => '0');

			end if;
		end if;
	end process;

	euclidian : Dist_eucl
	generic map (DATA_WIDTH => 8)
	port map (
				clk		=> clk,
				reset	=> reset,
				x1 		=> x1_sg,
				x2 		=> x2_sg,
				y1 		=> y1_sg,
				y2 		=> y2_sg,
				result => de_result_sg
				);

	process(clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				neigh_numb <= (others => '0');
			elsif((de_result_sg >= min_distance) and (aux = "11") ) then
				neigh_numb <= std_logic_vector(unsigned(neigh_numb) + unsigned(one));
			end if;
		end if;
	end process;

	process(neigh_numb)
	begin
		if(min_neighbours = neigh_numb and (aux = "11")) then
			interrupt_sg <= '1';
			result <= '1';
		else
			interrupt_sg <= '0';
			result <= '0';
		end if;
	end process;


	interrupt <= interrupt_sg;

end rtl;
