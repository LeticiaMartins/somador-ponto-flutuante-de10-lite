-- =====================================================================
-- fp_adder_test_tb.vhd -- Testbench para a ETAPA 2
--
-- Objetivo: provar que o novo roteamento de switches/botoes da DE10-Lite
-- (fp_adder_test.vhd adaptado) continua entregando ao fp_adder os
-- operandos corretos, e que o fp_adder (inalterado desde a Etapa 1)
-- continua calculando certo atraves do wrapper novo.
--
-- Usamos "external names" (VHDL-2008) para observar sign_out/exp_out/
-- frac_out, que sao sinais INTERNOS do fp_adder_test (nao existem na
-- porta da entity, so 'an'/'sseg' multiplexados existem). Isso evita
-- termos que decodificar a multiplexacao temporal do disp_mux so pra
-- conferir o resultado numerico -- a parte visual (o que aparece nos
-- displays de verdade) fica pra Etapa 3, na placa.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_adder_test_tb is
end fp_adder_test_tb;

architecture sim of fp_adder_test_tb is
    signal clk  : std_logic := '0';
    signal sw   : std_logic_vector(9 downto 0) := (others => '0');
    signal key  : std_logic_vector(1 downto 0) := (others => '0');
    signal an   : std_logic_vector(3 downto 0);
    signal sseg : std_logic_vector(7 downto 0);
begin
    dut : entity work.fp_adder_test
        port map (clk => clk, sw => sw, key => key, an => an, sseg => sseg);

    -- clock livre so para o disp_mux nao ficar sem evento (nao afeta os
    -- sinais combinacionais que checamos)
    clk <= not clk after 10 ns;

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
        -- ---- Caso A: baseline, tudo em '0' ----
        -- operando 1 (fixo): sign=0, exp=1000, frac = 1&sw1&sw0&10101 = 10010101
        -- operando 2: sign2=sw7=0, exp2=sw9&sw8&key1&key0=0000, frac2=1&sw6..0=10000000
        -- A = +0.10010101 x 2^8 ; B = +0.10000000 x 2^0  (B soma quase nada)
        sw  <= (others => '0');
        key <= (others => '0');
        wait for 20 ns;
        assert (sign_out_i = '0') and (exp_out_i = "1000") and (frac_out_i = "10010101")
            report "Caso A (baseline) FALHOU" severity error;
        report "Caso A (baseline): sign=" & std_logic'image(sign_out_i) &
               " exp=" & to_hstring(exp_out_i) & " frac=" & to_hstring(frac_out_i);

        -- ---- Caso B: exp2 alto via os 2 switches extras (sw9,sw8) ----
        -- exp2 = sw9 & sw8 & key1 & key0 = "1100" = 12 (> exp1 = 8 -> B vira o "big")
        sw(9) <= '1'; sw(8) <= '1';
        wait for 20 ns;
        assert (exp_out_i = "1100")
            report "Caso B (exp2 via sw9/sw8) FALHOU: exp2 nao chegou como esperado" severity error;
        report "Caso B (exp2 alto via sw9/sw8): sign=" & std_logic'image(sign_out_i) &
               " exp=" & to_hstring(exp_out_i) & " frac=" & to_hstring(frac_out_i);

        -- ---- Caso C: exp2 completa com os 2 KEY (key1,key0) ----
        -- exp2 = "1111" = 15
        key(1) <= '1'; key(0) <= '1';
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

        report "=== Fim da simulacao (Etapa 2) ===";
        wait;
    end process;
end sim;
