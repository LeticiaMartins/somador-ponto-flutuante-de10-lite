-- =====================================================================
-- fp_adder_tb.vhd  -- Testbench para a ETAPA 1
--
-- O fp_adder e um circuito COMBINACIONAL (nao tem clock). Por isso o
-- testbench so aplica pares de entradas e espera um tempo para o
-- resultado propagar. NAO ha clock aqui de proposito.
--
-- Formato 13 bits: sign(1) + exp(4) + frac(8), valor = (-1)^s * 0.f * 2^e
--
-- Os 4 casos cobrem os 4 caminhos da normalizacao (4o estagio):
--   Caso 1: soma simples, sem carry
--   Caso 2: subtracao com zeros a esquerda -> desloca a esquerda
--   Caso 3: subtracao pequena demais -> resultado vira ZERO
--   Caso 4: soma com carry-out -> desloca a direita e incrementa exp
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_adder_tb is
end fp_adder_tb;

architecture sim of fp_adder_tb is
    -- sinais ligados ao DUT (Device Under Test)
    signal sign1, sign2 : std_logic := '0';
    signal exp1,  exp2  : std_logic_vector(3 downto 0) := (others => '0');
    signal frac1, frac2 : std_logic_vector(7 downto 0) := (others => '0');
    signal sign_out     : std_logic;
    signal exp_out      : std_logic_vector(3 downto 0);
    signal frac_out     : std_logic_vector(7 downto 0);

    -- procedimento auxiliar para checar e reportar cada caso
    procedure check(
        signal so : in std_logic;
        signal eo : in std_logic_vector(3 downto 0);
        signal fo : in std_logic_vector(7 downto 0);
        constant nome      : in string;
        constant sesp      : in std_logic;
        constant eesp      : in std_logic_vector(3 downto 0);
        constant fesp      : in std_logic_vector(7 downto 0)) is
    begin
        if (so = sesp) and (eo = eesp) and (fo = fesp) then
            report nome & ": OK" severity note;
        else
            report nome & ": FALHOU  (esperado s=" & std_logic'image(sesp)
                & ")" severity error;
        end if;
    end procedure;

begin
    -- instancia do somador
    dut : entity work.fp_adder
        port map (
            sign1 => sign1, sign2 => sign2,
            exp1  => exp1,  exp2  => exp2,
            frac1 => frac1, frac2 => frac2,
            sign_out => sign_out, exp_out => exp_out, frac_out => frac_out
        );

    stim : process
    begin
        -- ---- Caso 1: soma simples, SEM carry ----
        -- A = +0.10100000 x 2^4 ; B = +0.10000000 x 2^2
        -- Esperado: +0.11000000 x 2^4
        sign1 <= '0'; exp1 <= "0100"; frac1 <= "10100000";
        sign2 <= '0'; exp2 <= "0010"; frac2 <= "10000000";
        wait for 20 ns;
        check(sign_out, exp_out, frac_out, "Caso 1 (soma sem carry)",
              '0', "0100", "11000000");

        -- ---- Caso 2: subtracao com zeros a esquerda (desloca esquerda) ----
        -- A = +0.10100000 x 2^4 ; B = -0.10000000 x 2^4
        -- Esperado: +0.10000000 x 2^2
        sign1 <= '0'; exp1 <= "0100"; frac1 <= "10100000";
        sign2 <= '1'; exp2 <= "0100"; frac2 <= "10000000";
        wait for 20 ns;
        check(sign_out, exp_out, frac_out, "Caso 2 (sub, shift esquerda)",
              '0', "0010", "10000000");

        -- ---- Caso 3: subtracao pequena demais -> ZERO ----
        -- A = +0.10000000 x 2^1 ; B = -0.10000000 x 2^1  (magnitudes iguais)
        -- Esperado: 0
        --
        -- sign='1' (nao '0'!): o Listing 3.19 do livro (fp_adder.vhd linha
        -- 119: "sign_out <= signb;") nao zera o sinal quando o resultado da
        -- normalizacao vira zero -- so exp e frac sao zerados (linhas
        -- 108-111). Com exp1&frac1 = exp2&frac2 (empate), o estagio 1 (linha
        -- 42: "if (exp1&frac1) > (exp2&frac2)") cai sempre no else, entao
        -- signb = sign2 = '1'. Verificado tambem no livro original
        -- (codigo-fonte-livro-pong-chu.pdf, Listing 3.19, linha 107): o
        -- mesmo comportamento existe no algoritmo publicado, nao e erro de
        -- transcricao nossa. O valor sign='0' aqui era uma suposicao errada
        -- da IA (assumiu zero com sinal canonico, estilo IEEE 754, que este
        -- formato simplificado nao implementa) -- ver ia-log da Etapa 1.
        sign1 <= '0'; exp1 <= "0001"; frac1 <= "10000000";
        sign2 <= '1'; exp2 <= "0001"; frac2 <= "10000000";
        wait for 20 ns;
        check(sign_out, exp_out, frac_out, "Caso 3 (resultado zero)",
              '1', "0000", "00000000");

        -- ---- Caso 4: soma com CARRY-OUT (desloca direita, exp+1) ----
        -- A = +0.11111111 x 2^4 ; B = +0.11111111 x 2^4
        -- Esperado: +0.11111111 x 2^5
        sign1 <= '0'; exp1 <= "0100"; frac1 <= "11111111";
        sign2 <= '0'; exp2 <= "0100"; frac2 <= "11111111";
        wait for 20 ns;
        check(sign_out, exp_out, frac_out, "Caso 4 (carry out)",
              '0', "0101", "11111111");

        report "=== Fim da simulacao ===" severity note;
        wait;
    end process;
end sim;
