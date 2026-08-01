-- =====================================================================
-- fp_adder_test_tb.vhd -- Testbench para a ETAPA 2
--
-- Objetivo: provar que o novo roteamento de switches/botoes/displays da
-- DE10-Lite (fp_adder_test.vhd adaptado) continua entregando ao fp_adder
-- os operandos corretos, e que o fp_adder (inalterado desde a Etapa 1)
-- continua calculando certo atraves do wrapper novo.
--
-- Usamos "external names" (VHDL-2008) para observar sign_out/exp_out/
-- frac_out, que sao sinais INTERNOS do fp_adder_test (na porta da entity
-- so existem os displays ja decodificados em 7 segmentos). Isso evita ter
-- que decodificar os padroes de segmento so pra conferir o resultado
-- numerico -- a parte visual fica pra Etapa 3, na placa.
--
-- NOTA (revisao da Etapa 2): o DUT nao tem mais 'clk' nem multiplexacao
-- de displays (o disp_mux do livro nao se aplica a DE10-Lite, que liga
-- cada display direto ao FPGA). O circuito e combinacional puro, entao
-- este testbench nao tem gerador de clock e a simulacao termina sozinha.
--
-- Convencao dos botoes: os KEY da DE10-Lite sao ativos em '0'. Aqui
-- key = "11" significa NENHUM botao pressionado.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_adder_test_tb is
end fp_adder_test_tb;

architecture sim of fp_adder_test_tb is
    signal sw  : std_logic_vector(9 downto 0) := (others => '0');
    signal key : std_logic_vector(1 downto 0) := (others => '1');  -- soltos
    signal hex0, hex1, hex2, hex3, hex4, hex5 : std_logic_vector(0 to 7);
begin
    dut : entity work.fp_adder_test
        port map (
            sw => sw, key => key,
            HEX0 => hex0, HEX1 => hex1, HEX2 => hex2,
            HEX3 => hex3, HEX4 => hex4, HEX5 => hex5
        );

    stim : process
        -- sinais internos do DUT, observados via external name (VHDL-2008).
        -- Declarados aqui (parte declarativa do processo), pois 'dut' so
        -- existe elaborado depois da parte declarativa da arquitetura --
        -- na declarativa da arquitetura o external name nao resolve ainda.
        alias sign_out_i is
            << signal .fp_adder_test_tb.dut.sign_out : std_logic >>;
        alias exp_out_i is
            << signal .fp_adder_test_tb.dut.exp_out : std_logic_vector(3 downto 0) >>;
        alias frac_out_i is
            << signal .fp_adder_test_tb.dut.frac_out : std_logic_vector(7 downto 0) >>;
    begin
        -- ---- Caso A: baseline, switches em '0', botoes soltos ----
        -- operando 1 (fixo): sign=0, exp=1000, frac = 1&sw1&sw0&10101 = 10010101
        -- operando 2: sign2=sw7=0, frac2=1&sw6..0=10000000,
        --             exp2 = sw9 & sw8 & not key1 & not key0 = "0000"
        -- A = +0.10010101 x 2^8 ; B = +0.10000000 x 2^0  (B soma quase nada)
        sw  <= (others => '0');
        key <= (others => '1');          -- nenhum botao pressionado
        wait for 20 ns;
        assert (sign_out_i = '0') and (exp_out_i = "1000") and (frac_out_i = "10010101")
            report "Caso A (baseline) FALHOU" severity error;
        report "Caso A (baseline): sign=" & std_logic'image(sign_out_i) &
               " exp=" & to_hstring(exp_out_i) & " frac=" & to_hstring(frac_out_i);

        -- ---- Caso B: exp2 alto via os 2 switches extras (sw9,sw8) ----
        -- exp2 = 1 & 1 & not '1' & not '1' = "1100" = 12 (> exp1 = 8 -> B vira o "big")
        sw(9) <= '1'; sw(8) <= '1';
        wait for 20 ns;
        assert (exp_out_i = "1100")
            report "Caso B (exp2 via sw9/sw8) FALHOU: exp2 nao chegou como esperado" severity error;
        report "Caso B (exp2 alto via sw9/sw8): sign=" & std_logic'image(sign_out_i) &
               " exp=" & to_hstring(exp_out_i) & " frac=" & to_hstring(frac_out_i);

        -- ---- Caso C: exp2 completa com os 2 KEY PRESSIONADOS ----
        -- KEY ativo em '0': pressionar os dois leva key = "00",
        -- entao exp2 = 1 & 1 & not '0' & not '0' = "1111" = 15.
        -- Este caso tambem valida a inversao de polaridade dos botoes.
        key(1) <= '0'; key(0) <= '0';    -- os dois pressionados
        wait for 20 ns;
        assert (exp_out_i = "1111")
            report "Caso C (exp2 via key1/key0) FALHOU: KEY nao chegou ao exp2" severity error;
        report "Caso C (exp2 completo via switches+KEY): sign=" & std_logic'image(sign_out_i) &
               " exp=" & to_hstring(exp_out_i) & " frac=" & to_hstring(frac_out_i);

        -- ---- Caso D: sign2 via sw7 (inverte o sinal do operando 2) ----
        sw(7) <= '1';
        wait for 20 ns;
        assert (sign_out_i = '1')
            report "Caso D (sign2 via sw7) FALHOU: sinal nao propagou" severity error;
        report "Caso D (sign2 via sw7, operando 2 negativo): sign=" & std_logic'image(sign_out_i) &
               " exp=" & to_hstring(exp_out_i) & " frac=" & to_hstring(frac_out_i);

        -- ---- Caso E: displays sobrando ficam apagados ----
        -- Ativos em '0', entao apagado = todos os bits em '1'.
        assert (hex4 = "11111111") and (hex5 = "11111111")
            report "Caso E FALHOU: HEX4/HEX5 deveriam estar apagados" severity error;
        report "Caso E (HEX4/HEX5 apagados): OK";

        report "=== Fim da simulacao (Etapa 2) ===";
        wait;
    end process;
end sim;
