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
		interrupt : out std_logic := '0';
		result  : out std_logic := '0'
	);

end entity;

architecture rtl of Near_neighbour is

	-- input signals
	signal x1_sg,x2_sg,y1_sg,y2_sg,fix_x,fix_y : std_logic_vector((DATA_WIDTH) -1 downto 0) := (others => '0');

	type state_type is (s0,s1, s2);
	signal state   : state_type := s0;

	-- Distance euclidian output
	signal de_result_sg1,de_result_sg2 : std_logic_vector((2*DATA_WIDTH) -1 downto 0) := (others => '0');

	-- signal that holds zero and its turned into one onece that state machine ack
	-- that is requesting sending
	--signal val : std_logic := '0';

	-- aux to the state zero
	-- aux = 00 -> didn`t recived anything
	-- aux = 01 -> read to recive minimum Distance
	-- aux = 10 -> recived minimum Distance
	-- aux = 11 -> read to recive minimum neighbour
	signal aux : std_logic_vector(2 downto 0) := "000";

	signal min_distance,min_neighbours :  std_logic_vector((4*DATA_WIDTH) -1 downto 0):= (others => '0');

	-- counter with the amount of min_neighbours
	signal neigh_numb_total,neigh_numb1,neigh_numb2 : std_logic_vector((4*DATA_WIDTH) -1 downto 0):= (others => '0');
	constant one : unsigned(15 downto 0):= "0000000000000001";
	
	
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
				aux <= "000";
			elsif (state = s0 and request = '1' and aux ="000") then
				-- in the state zero first recive the minimum distance and second
				-- the minimum neighbours from the data chanel
				ack <= '1';
				aux <= "001";
			elsif (state = s0 and request = '0' and aux = "001") then
				ack <= '0';
				min_distance <= data;
				aux <= "010";
			elsif (state = s0 and request = '1' and aux = "010") then
				ack <= '1';
				aux <= "011";
			elsif (state = s0 and request = '0' and aux = "011") then
				ack <= '0';
				min_neighbours <= data;
				aux <= "100";
			elsif (state = s0 and request = '1' and aux = "100") then
				ack <= '1';
				aux <= "110";
			elsif (state = s0 and request = '0' and aux = "110") then
				ack <= '0';
				fix_y <= data((DATA_WIDTH) -1 downto 0);
				fix_x <= data((2*DATA_WIDTH) -1 downto (DATA_WIDTH) );
				aux <= "111";
				aux <= "111";
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

	euclidian1 : Dist_eucl
	generic map (DATA_WIDTH => 8)
	port map (
				clk		=> clk,
				reset	=> reset,
				x1 		=> x1_sg,
				x2 		=> fix_x,
				y1 		=> y1_sg,
				y2 		=> fix_y,
				result => de_result_sg1
				);

	euclidian2 : Dist_eucl
	generic map (DATA_WIDTH => 8)
	port map (
				clk		=> clk,
				reset	=> reset,
				x1 		=> x2_sg,
				x2 		=> fix_x,
				y1 		=> y2_sg,
				y2 		=> fix_y,
				result => de_result_sg2
				);

	process(clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				neigh_numb1 <= (others => '0');
			elsif((de_result_sg1 >= min_distance) and (aux = "111") ) then
				neigh_numb1 <= std_logic_vector(unsigned(neigh_numb1) + unsigned(one));
			end if;
		end if;
	end process;

	process(clk)
	begin
		if (rising_edge(clk)) then
			if(reset = '1') then
				neigh_numb2 <= (others => '0');
			elsif((de_result_sg2 >= min_distance) and (aux = "111") ) then
				neigh_numb2 <= std_logic_vector(unsigned(neigh_numb2) + unsigned(one));
			end if;
		end if;
	end process;

	neigh_numb_total <= std_logic_vector(unsigned(neigh_numb2) + unsigned(neigh_numb1));

	process(neigh_numb_total)
	begin
		if(min_neighbours = neigh_numb_total and (aux = "111")) then
			interrupt_sg <= '1';
			result <= '1';
		else
			interrupt_sg <= '0';
			result <= '0';
		end if;
	end process;


	interrupt <= interrupt_sg;

end rtl;
