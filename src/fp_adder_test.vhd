-- =====================================================================
-- fp_adder_test.vhd
-- Circuito de teste para a placa (Pong P. Chu, Listing 3.20).
--
-- A placa nao tem entradas fisicas suficientes (26 bits de operandos),
-- entao um operando fica CONSTANTE e o outro usa as chaves (switches).
-- O resultado vai para os displays de 7 segmentos.
--
-- ATENCAO (Etapa 2/3): este arquivo depende de dois componentes do livro
-- que NAO estao no PDF do projeto e precisam ser baixados do Moodle:
--     - hex_to_sseg.vhd  (decodificador hexadecimal -> 7 segmentos)
--     - disp_mux.vhd     (multiplexacao temporal dos 4 displays)
-- Alem disso, os nomes/larguras de 'sw', 'btn', 'an', 'sseg' devem ser
-- adaptados para a DE10-Lite (que tem 10 switches, 2 botoes e 6 displays).
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_adder_test is
    port (
        clk  : in  std_logic;
        sw   : in  std_logic_vector(7 downto 0);
        btn  : in  std_logic_vector(3 downto 0);
        an   : out std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(7 downto 0)
    );
end fp_adder_test;

architecture arch of fp_adder_test is
    signal sign1, sign2 : std_logic;
    signal exp1,  exp2  : std_logic_vector(3 downto 0);
    signal frac1, frac2 : std_logic_vector(7 downto 0);
    signal sign_out     : std_logic;
    signal exp_out      : std_logic_vector(3 downto 0);
    signal frac_out     : std_logic_vector(7 downto 0);
    signal led3, led2, led1, led0 : std_logic_vector(7 downto 0);
begin
    -- monta os operandos de entrada do somador
    sign1 <= '0';
    exp1  <= "1000";
    frac1 <= '1' & sw(1) & sw(0) & "10101";
    sign2 <= sw(7);
    exp2  <= btn;
    frac2 <= '1' & sw(6 downto 0);

    -- instancia o somador de ponto flutuante
    fp_add_unit : entity work.fp_adder
        port map (
            sign1 => sign1, sign2 => sign2, exp1 => exp1, exp2 => exp2,
            frac1 => frac1, frac2 => frac2,
            sign_out => sign_out, exp_out => exp_out, frac_out => frac_out
        );

    -- decodificadores hex -> 7 segmentos
    -- expoente
    sseg_unit_0 : entity work.hex_to_sseg
        port map (hex => exp_out, dp => '0', sseg => led0);
    -- 4 LSBs da fracao
    sseg_unit_1 : entity work.hex_to_sseg
        port map (hex => frac_out(3 downto 0), dp => '1', sseg => led1);
    -- 4 MSBs da fracao
    sseg_unit_2 : entity work.hex_to_sseg
        port map (hex => frac_out(7 downto 4), dp => '0', sseg => led2);

    -- sinal (barra do meio = negativo, apagado = positivo)
    led3 <= "11111110" when sign_out = '1' else
            "11111111";

    -- multiplexacao temporal dos displays de 7 segmentos
    disp_unit : entity work.disp_mux
        port map (
            clk => clk, reset => '0',
            in0 => led0, in1 => led1, in2 => led2, in3 => led3,
            an => an, sseg => sseg
        );
end arch;
