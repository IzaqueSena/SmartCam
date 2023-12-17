library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity smart_cam is
    port(
        clock           : in std_logic;
        reset           : in std_logic;
        ligar           : in std_logic;
        entrada_serial  : in std_logic;
        ruido           : in std_logic;
        posicao_ruido   : in std_logic;
        pwm_vertical    : out std_logic;
        pwm_horizontal  : out std_logic;
        db_estado       : out std_logic_vector(6 downto 0);
		  db_pos_horizontal : out std_logic_vector(6 downto 0);
		  db_pos_vertical : out std_logic_vector(6 downto 0)		  
    );
end entity smart_cam;

architecture estrutural of smart_cam is

    component smart_cam_fd is
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
    end component smart_cam_fd;

    component smart_cam_uc is
        port(
            clock           : in std_logic;
            reset           : in std_logic;
            ligar           : in std_logic;
            controle_camera : in std_logic;
            ruido           : in std_logic;
            posicao_ruido   : in std_logic;
            fim_filmagem     : in std_logic;
            sair_controle   : in std_logic;
            modo            : out std_logic_vector(1 downto 0);
				zera_contagem   : out std_logic;
            zera_filmagem   : out std_logic;
            conta_filmagem  : out std_logic;
            db_estado       : out std_logic_vector(3 downto 0)
        );
    end component smart_cam_uc;

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component hexa7seg;

    signal s_zera_filmagem, s_conta_filmagem, s_controle_camera, s_fim_filmagem, s_sair_controle, s_zera_contagem : std_logic; 
    signal s_modo : std_logic_vector(1 downto 0);
    signal s_db_estado : std_logic_vector(3 downto 0);
	 signal s_pos_vertical, s_pos_horizontal: std_logic_vector(2 downto 0); 

begin

    FD: smart_cam_fd
        port map(
            clock           => clock,
            reset           => reset,
            ligar           => ligar, 
            entrada_serial  => entrada_serial,
            ruido           => ruido,
            posicao_ruido   => posicao_ruido,
            modo            => s_modo,
            zera_filmagem   => s_zera_filmagem,
				zera_contagem   => s_zera_contagem,
            conta_filmagem  => s_conta_filmagem, 
            controle_camera => s_controle_camera,
            fim_filmagem    => s_fim_filmagem, 
            sair_controle   => s_sair_controle,
            pwm_vertical    => pwm_vertical,
            pwm_horizontal  => pwm_horizontal,
				db_pos_horizontal => s_pos_horizontal,
				db_pos_vertical => s_pos_vertical
        );
    
    UC: smart_cam_uc
        port map (
            clock           => clock,
            reset           => reset,
            ligar           => ligar,
            controle_camera => s_controle_camera,
            ruido           => ruido,
            posicao_ruido   => posicao_ruido,
            fim_filmagem    => s_fim_filmagem,
            sair_controle   => s_sair_controle,
            modo            => s_modo,
				zera_contagem   => s_zera_contagem,
            zera_filmagem   => s_zera_filmagem,
            conta_filmagem  => s_conta_filmagem,
            db_estado       => s_db_estado
        );
    
    HEX7SEG_3 : hexa7seg
        port map (
            hexa => s_db_estado,
            sseg => db_estado
        );
		  
	 HEX7SEG_HORIZONTAL : hexa7seg
        port map (
            hexa => ('0' & s_pos_horizontal),
            sseg => db_pos_horizontal
        );
		  
	  HEX7SEG_VERTICAL : hexa7seg
        port map (
            hexa => ('0' & s_pos_vertical),
            sseg => db_pos_vertical
        );
    
end architecture;