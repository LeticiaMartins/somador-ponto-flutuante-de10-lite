-- =====================================================================
-- fp_adder_test_etapa1_livro.vhd
-- COPIA CONGELADA da Etapa 1 -- Pong P. Chu, Listing 3.20, SEM NENHUMA
-- alteracao de logica. Mantida apenas para comparacao no relatorio (ver
-- README.md, secao 3 "O que mudamos no VHDL original").
--
-- NAO faz parte do build ativo (nao e chamada por nenhum testbench nem
-- pelo projeto Quartus) -- por isso a entity foi renomeada para
-- 'fp_adder_test_etapa1_livro', evitando colisao de nome com a versao
-- adaptada para a DE10-Lite em fp_adder_test.vhd (Etapa 2).
--
-- Board original do livro: 8 switches, 4 botoes, 4 displays de 7 segmentos.
-- Comparar com fp_adder_test.vhd (Etapa 2) para ver a adaptacao completa
-- para a DE10-Lite (10 switches, 2 botoes (KEY), 6 displays).
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_adder_test_etapa1_livro is
    port (
        clk  : in  std_logic;
        sw   : in  std_logic_vector(7 downto 0);
        btn  : in  std_logic_vector(3 downto 0);
        an   : out std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(7 downto 0)
    );
end fp_adder_test_etapa1_livro;

architecture arch of fp_adder_test_etapa1_livro is
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
