library ieee;
use ieee.std_logic_1164.all;

entity smart_cam_uc is
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
end entity smart_cam_uc;

architecture fsm_arch of smart_cam_uc is
    type tipo_estado is (inicial, aguardando_ruido, filmando_posicao_0_ruido, filmando_posicao_1_ruido, controlando_camera);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    process (ligar, controle_camera, ruido, fim_filmagem, sair_controle, Eatual) 
    begin
      case Eatual is
        when inicial =>                if ligar='1' then Eprox <= aguardando_ruido;
                                       else              Eprox <= inicial;
                                       end if;
        when aguardando_ruido =>       if controle_camera='0' and ruido='0' then Eprox <= aguardando_ruido;
                                       elsif controle_camera='0' and ruido='1' and posicao_ruido='0' then Eprox <= filmando_posicao_0_ruido;
                                       elsif controle_camera='0' and ruido='1' and posicao_ruido='1' then Eprox <= filmando_posicao_1_ruido;
                                       else                                         Eprox <= controlando_camera;
                                       end if;
        when filmando_posicao_0_ruido => if controle_camera='0' and fim_filmagem='0' then Eprox <= filmando_posicao_0_ruido;
                                       elsif controle_camera='0'and fim_filmagem='1' then Eprox <= aguardando_ruido;
                                       else                                              Eprox <= controlando_camera;
                                       end if;
        when filmando_posicao_1_ruido => if controle_camera='0' and fim_filmagem='0' then Eprox <= filmando_posicao_1_ruido;
                                       elsif controle_camera='0'and fim_filmagem='1' then Eprox <= aguardando_ruido;
                                       else                                              Eprox <= controlando_camera;
                                       end if;
        when controlando_camera =>     if sair_controle='0' then Eprox <= controlando_camera;
                                       else                      Eprox <= aguardando_ruido;
                                       end if;
        when others =>                 Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
  with Eatual select 
      modo <= "00" when aguardando_ruido,
              "01" when filmando_posicao_0_ruido,
              "10" when filmando_posicao_1_ruido,
              "11" when controlando_camera,
              "00" when others;

  with Eatual select
      zera_filmagem <= '1' when aguardando_ruido,
                       '0' when others;

  with Eatual select
      conta_filmagem <= '1' when filmando_posicao_0_ruido,
                        '1' when filmando_posicao_1_ruido,
                        '0' when others; 
  
  
  with Eatual select
      zera_contagem <= '0' when controlando_camera,
									 '1' when others; 

  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when aguardando_ruido, 
                   "0010" when filmando_posicao_0_ruido, 
                   "0011" when filmando_posicao_1_ruido, 
                   "0100" when controlando_camera,
                   "1111" when others;

end architecture fsm_arch;