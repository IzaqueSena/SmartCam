library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity smart_cam_fd is
    port(
        clock           : in std_logic;
        reset           : in std_logic;
        ligar           : in std_logic;
        entrada_serial  : in std_logic;
        ruido           : in std_logic;
        posicao_ruido   : in std_logic;
        modo            : in std_logic_vector(1 downto 0);
        zera_filmagem   : in std_logic;
		  zera_contagem   : in std_logic;
        conta_filmagem  : in std_logic;
        controle_camera : out std_logic;
        fim_filmagem    : out std_logic;
        sair_controle   : out std_logic;
        pwm_vertical    : out std_logic;
        pwm_horizontal  : out std_logic;
		  db_pos_horizontal : out std_logic_vector(2 downto 0);
		  db_pos_vertical : out std_logic_vector(2 downto 0)
    );
end entity smart_cam_fd;

architecture smart_cam_fd_ar of smart_cam_fd is

    component rx_serial_7O1 is 
        port( 
            clock             : in  std_logic; 
            reset             : in  std_logic; 
            dado_serial       : in  std_logic; 
            recebe_dado       : in  std_logic;  
            dado_recebido     : out std_logic_vector(6 downto 0); 
            tem_dado          : out std_logic; 
            paridade_recebida : out std_logic; 
            pronto            : out std_logic;	
            db_dado_serial    : out std_logic; 
            db_estado         : out std_logic_vector(3 downto 0) 
        ); 
    end component;

    component contadorg_updown_m is
        generic (
            constant M: integer := 50 -- modulo do contador
        );
        port (
            clock   : in  std_logic;
				zera_as : in  std_logic;
				zera_s  : in  std_logic;
				conta   : in  std_logic;
				diminui : in std_logic;
				ref     : in std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
				Q       : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
				inicio  : out std_logic;
				fim     : out std_logic;
				meio    : out std_logic
       );
    end component;

    component contador_m is
        generic (
            constant M : integer := 50;  
            constant N : integer := 6 
        );
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector (N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component contador_m;

    component controle_servo is
        port (
            clock:      in std_logic;
            reset:      in std_logic;
            posicao:    in std_logic_vector(2 downto 0);
            pwm:        out std_logic;
            db_reset:   out std_logic;
            db_pwm:     out std_logic;
            db_posicao: out std_logic_vector(2 downto 0)
        );
    end component controle_servo;
    

    signal s_caracter_lido, caracter_lido : std_logic_vector(6 downto 0);
    signal s_pronto_rx: std_logic;
    signal conta_pos_horizontal, diminui_pos_horizontal, conta_pos_vertical, diminui_pos_vertical: std_logic;
    signal s_posicao_horizontal, s_posicao_vertical, posicao_0, posicao_1, posicao_padrao_vertical, posicao_padrao_horizontal, s_posicao_cont_horizontal, s_posicao_cont_vertical : std_logic_vector(2 downto 0);
	 

begin

    posicao_padrao_vertical   <= "100";
	 posicao_padrao_horizontal <= "011";
    posicao_0 <= "000";
    posicao_1 <= "110";

    RX: rx_serial_7O1 
    port map( 
        clock              => clock,
        reset              => reset,
        dado_serial        => entrada_serial,
        recebe_dado        => '1',
        dado_recebido      => caracter_lido,
        tem_dado           => open,
        paridade_recebida  => open,
        pronto             => s_pronto_rx,
        db_dado_serial     => open,
        db_estado          => open
    );
	 
	 
	 
	 with s_pronto_rx select
    s_caracter_lido <= caracter_lido when '1',
                       (others => '0') when others;
	
		
    with s_caracter_lido select
    conta_pos_vertical <= '1' when "1110011", 
                            '0' when others;
    
    with s_caracter_lido select
    conta_pos_horizontal <= '1' when "1100100",
                            '0' when others;

    with s_caracter_lido select
    diminui_pos_vertical <= '1' when "1110111",
                            '0' when others;

    with s_caracter_lido select
    diminui_pos_horizontal <= '1' when "1100001",
                                '0' when others;
    
    with s_caracter_lido select
    controle_camera <= '1' when "1100011",
                       '0' when others;
    
    with s_caracter_lido select
    sair_controle <= '1' when "1110110",
                     '0' when others;

    CONT_POS_VERTICAL: contadorg_updown_m
        generic map (
            M => 8 
        )
        port map (
        clock => clock,
        zera_as  => zera_contagem,
        zera_s  => zera_contagem,
        conta => conta_pos_vertical,
        diminui => diminui_pos_vertical,
		  ref   => s_posicao_vertical,
        Q     => s_posicao_cont_vertical,
        inicio => open,
        fim   => open,
        meio  => open
    );

    CONT_POS_HORIZONTAL: contadorg_updown_m
        generic map (
            M => 7 
        )
        port map (
        clock => clock,
        zera_as  => zera_contagem,
        zera_s  => zera_contagem,
        conta => conta_pos_horizontal,
        diminui => diminui_pos_horizontal,
		  ref   => s_posicao_horizontal,
        Q     => s_posicao_cont_horizontal,
        inicio => open,
        fim   => open,
        meio  => open
    );

    with modo select
    s_posicao_vertical <= s_posicao_cont_vertical when "11",
                          posicao_padrao_vertical when others;
    
    with modo select
    s_posicao_horizontal <= s_posicao_cont_horizontal when "11",
                            posicao_0 when "01",
                            posicao_1 when "10",
                            posicao_padrao_horizontal when others;


    SERVO_VERTICAL: controle_servo
    port map (
        clock      => clock,
        reset      => reset,
        posicao    => s_posicao_vertical,
        pwm        => pwm_vertical,
        db_reset   => open,
        db_pwm     => open,
        db_posicao => open  
    );

    SERVO_HORIZONTAL: controle_servo
    port map (
        clock      => clock,
        reset      => reset,
        posicao    => s_posicao_horizontal,
        pwm        => pwm_horizontal,
        db_reset   => open,
        db_pwm     => open,
        db_posicao => open  
    );

    -- freq clock = 50 MHz => 5 seg * 50 MHz = 250 000 000 periodos de clock
    CONT_20SEG: contador_m 
        generic map (
            M => 250000000,
            N => 10 
        )
        port map (
            clock => clock,
            zera  => zera_filmagem,
            conta => conta_filmagem,
            Q     => open,
            fim   => fim_filmagem,
            meio  => open
        );
		 
	  db_pos_horizontal <= s_posicao_horizontal;
	  db_pos_vertical <= s_posicao_vertical;

end architecture;