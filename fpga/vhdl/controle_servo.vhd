library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
    port (
        clock:      in std_logic;
        reset:      in std_logic;
        posicao:    in std_logic_vector(2 downto 0);
        pwm:        out std_logic;
        db_reset:   out std_logic;
        db_pwm:     out std_logic;
        db_posicao: out std_logic_vector(2 downto 0)
    );
end entity controle_servo;

architecture servo of controle_servo is
    component circuito_pwm is
        generic (
            conf_periodo  : integer := 3500;  -- periodo do sinal pwm
            largura_000   : integer :=    0;  -- largura do pulso p/ 000
            largura_001   : integer :=   50;  -- largura do pulso p/ 001
            largura_010   : integer :=  500;  -- largura do pulso p/ 010
            largura_011   : integer := 1000;  -- largura do pulso p/ 011
            largura_100   : integer := 1500;  -- largura do pulso p/ 100
            largura_101   : integer := 2000;  -- largura do pulso p/ 101
            largura_110   : integer := 2500;  -- largura do pulso p/ 110
            largura_111   : integer := 3000   -- largura do pulso p/ 111
        );
        port (
            clock   : in  std_logic;
            reset   : in  std_logic;
            largura : in  std_logic_vector(2 downto 0);  
            pwm     : out std_logic 
        );
    end component;

    signal s_pwm: std_logic;

    begin
        use_circuito_pwm: circuito_pwm
            generic map (
                conf_periodo => 1000000, 
                largura_000   =>  35000, 
                largura_001   =>  45700,  
                largura_010   =>  56450,  
                largura_011   =>  67150,
                largura_100   =>  77850, 
                largura_101   =>  88550,  
                largura_110   =>  99300,  
                largura_111   => 110000    
            )
            port map (
                clock => clock,
                reset => reset,
                largura => posicao,
                pwm => s_pwm
            );

            db_reset <= reset;
            pwm <= s_pwm;
            db_pwm <= s_pwm;
            db_posicao <= posicao;

end architecture servo;

