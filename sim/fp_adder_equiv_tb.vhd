-- =====================================================================
-- fp_adder_equiv_tb.vhd -- Testbench de EQUIVALENCIA (Etapa 2)
--
-- Pergunta que este testbench responde:
--   "A adaptacao para a DE10-Lite mudou o resultado do circuito?"
--
-- Metodo: instanciar LADO A LADO as duas versoes do circuito de teste --
--   dut_livro : fp_adder_test_etapa1_livro  (Listing 3.20, congelado)
--   dut_de10  : fp_adder_test               (adaptado para a DE10-Lite)
-- -- alimentar as duas com estimulos CORRESPONDENTES e comparar os
-- resultados (sign_out/exp_out/frac_out) a cada combinacao.
--
-- A varredura e EXAUSTIVA sobre todas as entradas que o circuito de teste
-- do livro consegue variar: 256 valores de sw(7..0) x 16 valores de exp2
-- = 4096 combinacoes. Se as duas versoes concordarem nas 4096, a
-- adaptacao provadamente nao alterou a funcao logica -- so a fiacao.
--
-- Por que isso e melhor do que repetir os 4 casos da Etapa 1: aqueles
-- casos NAO sao alcancaveis atraves do wrapper. O circuito de teste do
-- livro fixa o operando 1 no hardware (sign1='0', exp1="1000",
-- frac1='1'&sw(1)&sw(0)&"10101"), entao expoente 0100/0001 e fracoes
-- como 10100000 sao impossiveis de gerar pelos switches. Essa limitacao
-- e do livro, nao da adaptacao -- as tres linhas sao identicas nas duas
-- versoes. A cobertura da matematica do somador em si continua sendo
-- feita pelo fp_adder_tb.vhd (Etapa 1), que aciona o fp_adder direto.
--
-- CORRESPONDENCIA DOS ESTIMULOS
--   sw(7..0)  : identico nas duas placas (sinal + fracao do operando 2,
--               e os 2 bits do operando 1)
--   exp2      : livro   -> btn(3..0), ativo em '1'
--               DE10    -> sw(9) & sw(8) & not key(1) & not key(0)
--               (os KEY da DE10-Lite sao ativos em '0'; o 'not' e
--               justamente o que preserva a equivalencia)
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;                       -- para 'finish' (VHDL-2008)

entity fp_adder_equiv_tb is
end fp_adder_equiv_tb;

architecture sim of fp_adder_equiv_tb is
    -- estimulo canonico (na "linguagem" do livro)
    signal sw   : std_logic_vector(7 downto 0) := (others => '0');
    signal btn  : std_logic_vector(3 downto 0) := (others => '0');

    -- entradas derivadas para a versao DE10-Lite
    signal sw_de10 : std_logic_vector(9 downto 0);
    signal key     : std_logic_vector(1 downto 0);

    -- clock: so o disp_mux da versao do livro precisa dele. Nao afeta os
    -- sinais combinacionais comparados aqui.
    signal clk : std_logic := '0';

    -- saidas fisicas (nao comparadas: as duas placas tem interfaces de
    -- display diferentes por construcao -- e esse o ponto da adaptacao)
    signal an_livro   : std_logic_vector(3 downto 0);
    signal sseg_livro : std_logic_vector(7 downto 0);
    signal h0, h1, h2, h3, h4, h5 : std_logic_vector(0 to 7);
begin
    clk <= not clk after 10 ns;

    -- --------- traducao dos estimulos: livro -> DE10-Lite ---------
    sw_de10(7 downto 0) <= sw;
    sw_de10(9)          <= btn(3);
    sw_de10(8)          <= btn(2);
    key(1)              <= not btn(1);   -- KEY ativo em '0'
    key(0)              <= not btn(0);

    dut_livro : entity work.fp_adder_test_etapa1_livro
        port map (clk => clk, sw => sw, btn => btn,
                  an => an_livro, sseg => sseg_livro);

    dut_de10 : entity work.fp_adder_test
        port map (sw => sw_de10, key => key,
                  HEX0 => h0, HEX1 => h1, HEX2 => h2,
                  HEX3 => h3, HEX4 => h4, HEX5 => h5);

    stim : process
        alias sign_livro is
            << signal .fp_adder_equiv_tb.dut_livro.sign_out : std_logic >>;
        alias exp_livro is
            << signal .fp_adder_equiv_tb.dut_livro.exp_out : std_logic_vector(3 downto 0) >>;
        alias frac_livro is
            << signal .fp_adder_equiv_tb.dut_livro.frac_out : std_logic_vector(7 downto 0) >>;

        alias sign_de10 is
            << signal .fp_adder_equiv_tb.dut_de10.sign_out : std_logic >>;
        alias exp_de10 is
            << signal .fp_adder_equiv_tb.dut_de10.exp_out : std_logic_vector(3 downto 0) >>;
        alias frac_de10 is
            << signal .fp_adder_equiv_tb.dut_de10.frac_out : std_logic_vector(7 downto 0) >>;

        variable divergencias : integer := 0;
        variable comparacoes  : integer := 0;
    begin
        report "=== Equivalencia livro x DE10-Lite: varrendo 16 x 256 = 4096 combinacoes ===";

        for b in 0 to 15 loop
            btn <= std_logic_vector(to_unsigned(b, 4));
            for s in 0 to 255 loop
                sw <= std_logic_vector(to_unsigned(s, 8));
                wait for 1 ns;           -- deixa a logica combinacional assentar

                comparacoes := comparacoes + 1;

                if (sign_livro /= sign_de10) or
                   (exp_livro  /= exp_de10)  or
                   (frac_livro /= frac_de10) then
                    divergencias := divergencias + 1;
                    -- so os 10 primeiros, para nao inundar o terminal
                    if divergencias <= 10 then
                        report "DIVERGENCIA em btn=" & integer'image(b) &
                               " sw=" & integer'image(s) &
                               " | livro: sign=" & std_logic'image(sign_livro) &
                               " exp=" & to_hstring(exp_livro) &
                               " frac=" & to_hstring(frac_livro) &
                               " | de10: sign=" & std_logic'image(sign_de10) &
                               " exp=" & to_hstring(exp_de10) &
                               " frac=" & to_hstring(frac_de10)
                            severity error;
                    end if;
                end if;
            end loop;
        end loop;

        report "Comparacoes realizadas: " & integer'image(comparacoes);

        if divergencias = 0 then
            report "=== RESULTADO: EQUIVALENTES. Nenhuma divergencia em " &
                   integer'image(comparacoes) & " combinacoes. ===";
        else
            report "=== RESULTADO: FALHOU -- " & integer'image(divergencias) &
                   " divergencias de " & integer'image(comparacoes) & " ==="
                severity error;
        end if;

        finish;   -- encerra a simulacao (o clock livre nao para sozinho)
    end process;
end sim;
