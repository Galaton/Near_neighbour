
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity Test_near is

end entity;

architecture T42 of Test_near is

  signal clk_sg,request_sg,resett_sg : std_logic := '0';
	signal  interrupt_sg,result_sg,ack_sg: std_logic ;
  signal data_sg : std_logic_vector(31 downto 0);

  component Near_neighbour is
  	generic(	DATA_WIDTH : natural := 8	);
  	port(
  		clk		: in std_logic;
  		reset	: in std_logic;
  		data 		: in std_logic_vector((4*DATA_WIDTH) -1 downto 0);
  		request : in std_logic;
  		ack 		: out std_logic;
  		interrupt : out std_logic;
  		result  : out std_logic
  	);
  end component;

	begin

		clk_sg <= not clk_sg after 20 ns;

	near : Near_neighbour
	port map(
  clk => clk_sg,
  reset => resett_sg,
  data => data_sg,
  request => request_sg,
  ack => ack_sg,
  interrupt => interrupt_sg,
  result => result_sg);

	process
	begin
    --- ====== testing inicialaze ====== ---
    -- request sending
    request_sg <= '1';
    -- expec ack 1
		wait for 60 ns;
		request_sg <= '0';
    -- min_distance=10
     data_sg <= "00000000000000000000000000001010";
		wait for 60 ns;
    request_sg <= '1';
    -- expec ack 1
    wait for 60 ns;
    request_sg <= '0';
    -- min_neighbours=1
    data_sg <= "00000000000000000000000000000001";
    wait for 60 ns;
    --- ==================================== ---
    --- ====== Testing sending data ====== ---


		wait for 50000 ns;

	end process;

end T42;
