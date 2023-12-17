library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_uc is 
    port ( 
        clock            : in  std_logic;
        reset            : in  std_logic;
        entrada_serial   : in  std_logic;
        tick             : in  std_logic;
        fim              : in  std_logic;
        zera             : out std_logic;
        conta            : out std_logic;
        carrega          : out std_logic;
        desloca          : out std_logic;
        registra         : out std_logic;
        pronto           : out std_logic;
        db_estado        : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rx_serial_uc_arch of rx_serial_uc is

    type tipo_estado is (inicial, preparacao, espera, recepcao, armazena, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

  -- memoria de estado
  process (reset, clock)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (entrada_serial, tick, fim, Eatual) 
  begin

    case Eatual is

      when inicial =>      if entrada_serial='0' then Eprox <= preparacao;
                           else                Eprox <= inicial;
                           end if;

      when preparacao =>   Eprox <= espera;

      when espera =>       if tick='1' then   Eprox <= recepcao;
                           elsif fim='0' then Eprox <= espera;
                           else               Eprox <= armazena;
                           end if;

      when recepcao =>  if fim='0' then Eprox <= espera;
                           else            Eprox <= armazena;
                           end if;

      when armazena =>     Eprox <= final;                           

      when final =>        Eprox <= inicial;

      when others =>       Eprox <= inicial;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      carrega <= '1' when preparacao, '0' when others;

  with Eatual select
      zera <= '1' when preparacao, '0' when others;

  with Eatual select
      desloca <= '1' when recepcao, '0' when others;

  with Eatual select
      conta <= '1' when recepcao, '0' when others;

  with Eatual select
      registra <= '1' when armazena, '0' when others;

  with Eatual select
      pronto <= '1' when final, '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial,
                   "0001" when preparacao, 
                   "0010" when espera, 
                   "0100" when recepcao, 
                   "1111" when final,    -- Final
                   "1110" when others;   -- Erro

end architecture rx_serial_uc_arch;