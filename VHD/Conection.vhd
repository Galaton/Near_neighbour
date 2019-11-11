LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;


ENTITY Conection IS
	GENERIC
	(
		DATA_WIDTH : natural := 8;
		N_WIDTH : natural := 4
	);
	PORT (
		OSC_CLK : IN STD_LOGIC;
		RESET_N : IN STD_LOGIC
	);
END Conection;

ARCHITECTURE rtl OF Conection IS

component Near is
	port (
		clk_clk          : in  std_logic                     := '0'; --       clk.clk
		reset_reset_n    : in  std_logic                     := '0'; --     reset.reset_n
		data_export      : out std_logic_vector(31 downto 0);        --      data.export
		ack_export       : in  std_logic                     := '0'; --       ack.export
		request_export   : out std_logic;                            --   request.export
		interrupt_export : in  std_logic                     := '0'; -- interrupt.export
		result_export    : in  std_logic                     := '0'  --    result.export
	);
end component Near;

component Near_neighbour is

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

end component;

signal dados_sg: std_logic_vector((4*DATA_WIDTH) -1 downto 0);
signal ack_sg,request_sg,interrupt_sg,result_sg : std_logic;

BEGIN

nieghbour : Near_neighbour
	generic map(DATA_WIDTH => 8)
	port map(
		clk		=> OSC_CLK,
		reset	=> RESET_N,
		data 		=> dados_sg,
		request => request_sg,
		ack 		=> ack_sg,
		interrupt => interrupt_sg,
		result  => result_sg
	);

NiosII : Near
	port map(
		clk_clk         => OSC_CLK,
		reset_reset_n   => RESET_N,
		data_export     => dados_sg,
		ack_export      => ack_sg,
		request_export  => request_sg,
		interrupt_export=> interrupt_sg,
		result_export=> result_sg
		);

END rtl;
