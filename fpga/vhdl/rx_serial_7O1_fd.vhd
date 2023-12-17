library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_7O1_fd is
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        zera            : in  std_logic;
        conta           : in  std_logic;
        carrega         : in  std_logic;
        desloca         : in  std_logic;
        registra        : in  std_logic;
        entrada_serial  : in  std_logic;
        dado_recebido   : out std_logic_vector(6 downto 0);
        paridade        : out std_logic;
        fim             : out std_logic
    );
end entity;

architecture behavioral of rx_serial_7O1_fd is
     
    component deslocador_n
    generic (
        constant N : integer
    );
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        carrega        : in  std_logic; 
        desloca        : in  std_logic; 
        entrada_serial : in  std_logic; 
        dados          : in  std_logic_vector(N-1 downto 0);
        saida          : out std_logic_vector(N-1 downto 0)
    );
    end component;

    component contador_m
    generic (
        constant M : integer;
        constant N : integer
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector(N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
    );
    end component;

    component registrador_n is
        generic (
            constant N: integer := 8 
        );
        port (
            clock  : in  std_logic;
            clear  : in  std_logic;
            enable : in  std_logic;
            D      : in  std_logic_vector (N-1 downto 0);
            Q      : out std_logic_vector (N-1 downto 0) 
        );
    end component;
    
    signal s_saida_d: std_logic_vector(8 downto 0);
    signal s_saida_reg: std_logic_vector(8 downto 0);

begin
    U1: deslocador_n 
        generic map (
            N => 9
        )  
        port map (
            clock          => clock, 
            reset          => reset, 
            carrega        => carrega, 
            desloca        => desloca, 
            entrada_serial => entrada_serial, 
            dados          => (others => '0'), 
            saida          => s_saida_d
        );

    U2: contador_m 
        generic map (
            M => 11, 
            N => 4
        ) 
        port map (
            clock => clock, 
            zera  => zera, 
            conta => conta, 
            Q     => open, 
            fim   => fim, 
            meio  => open
        );

    U3: registrador_n
        generic map (
            N => 9
        )
        port map(
            clock  => clock,
            clear  => reset,
            enable => registra,
            D      => s_saida_d,
            Q      => s_saida_reg
        );

    dado_recebido <= s_saida_reg(6 downto 0);
    paridade <= s_saida_reg(7);
    
end architecture;