-- =====================================================================
-- fp_adder_test.vhd
-- Circuito de teste para a placa (Pong P. Chu, Listing 3.20).
--
-- ETAPA 2: adaptado para a DE10-Lite (10 switches, 2 botoes (KEY), 6
-- displays de 7 segmentos NAO multiplexados). O livro original foi escrito
-- para uma placa Xilinx com 8 switches, 4 botoes e 4 displays
-- multiplexados. A versao original, congelada e sem alteracoes, esta em
-- fp_adder_test_etapa1_livro.vhd (so para comparacao no relatorio -- nao
-- faz parte do build ativo).
--
-- O 'fp_adder' (Listing 3.19) continua INALTERADO. Toda a adaptacao de
-- hardware esta nesta "casca", como na versao anterior.
--
-- ---------------------------------------------------------------------
-- Mudancas em relacao ao original (Listing 3.20):
--
-- 1. ENTRADAS
--    - 'btn(3 downto 0)' -> 'key(1 downto 0)': a DE10-Lite so tem 2 botoes
--      fisicos, nao 4. O 'exp2' (4 bits), que no livro vinha inteiro dos
--      botoes, agora e formado por 'sw(9) & sw(8) & (not key(1)) & (not
--      key(0))' -- os 2 switches extras que a DE10-Lite tem a mais (10 vs
--      8 do livro) cobrem os 2 bits que os botoes que faltam nao dao mais.
--    - 'sw' passa de 8 para 10 bits (sw(9 downto 0)).
--    - 'sign1, exp1, frac1' (operando fixo) e 'sign2, frac2' (via
--      sw(7 downto 0)) NAO mudaram -- mesma logica do livro.
--
-- 2. SAIDAS -- mudanca estrutural desta revisao
--    O livro usa multiplexacao temporal (componente 'disp_mux', Listing
--    4.13): os 4 displays da placa Xilinx compartilham UM barramento de
--    segmentos, e o vetor 'an' escolhe qual display esta aceso a cada
--    instante. Isso economiza pinos.
--
--    A DE10-Lite NAO e assim: os 6 displays (HEX0..HEX5) sao ligados
--    diretamente ao FPGA, cada um com seus proprios pinos. Nao existe
--    barramento compartilhado nem sinal de anodo -- o 'an' do livro nao
--    tem onde ser ligado nesta placa.
--
--    Portanto o 'disp_mux' foi REMOVIDO do circuito (o arquivo
--    src/disp_mux.vhd continua no repositorio apenas como registro da
--    Etapa 2 anterior; nao faz mais parte do build). Cada decodificador
--    aciona o seu display diretamente. Efeito colateral: o circuito
--    perde sua unica parte sequencial e o 'clk' deixa de ser necessario
--    -- o projeto inteiro passa a ser combinacional puro.
--
-- 3. ORDEM DOS BITS DO DISPLAY  <-- LER ANTES DE "CORRIGIR" ABAixo
--    Convencao do livro   : sseg(6 downto 0), sseg(6) = segmento 'a'
--    Convencao DE10-Lite  : HEX (0 to 6)    , HEX (0) = segmento 'a'
--    Os dois sao ativos em '0'. Ver roteiro MCTA024_Lab3_2026-2a.pdf,
--    secao "Seven Segment Display" (a professora cita explicitamente
--    essa inversao de ordem como fonte de erro).
--
-- 4. Displays HEX4/HEX5 nao sao usados pelo circuito, mas sao declarados
--    e apagados de proposito: pino de display nao atribuido fica solto e
--    acende segmentos aleatorios na placa.
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_adder_test is
    port (
        -- nomes em MAIUSCULA para casar exatamente com docs/DE10_LITE.qsf
        -- (VHDL e case-insensitive, mas assim nao resta duvida no Quartus)
        SW   : in  std_logic_vector(9 downto 0);
        KEY  : in  std_logic_vector(1 downto 0);
        -- ordem (0 to 7) = convencao da DE10-Lite: bits 0..6 sao os
        -- segmentos 'a'..'g' e o bit 7 e o ponto decimal (ver nota 3).
        HEX0 : out std_logic_vector(0 to 7);   -- expoente do resultado
        HEX1 : out std_logic_vector(0 to 7);   -- fracao, 4 LSBs
        HEX2 : out std_logic_vector(0 to 7);   -- fracao, 4 MSBs
        HEX3 : out std_logic_vector(0 to 7);   -- sinal do resultado
        HEX4 : out std_logic_vector(0 to 7);   -- nao usado (apagado)
        HEX5 : out std_logic_vector(0 to 7)    -- nao usado (apagado)
    );
end fp_adder_test;

architecture arch of fp_adder_test is
    signal sign1, sign2 : std_logic;
    signal exp1,  exp2  : std_logic_vector(3 downto 0);
    signal frac1, frac2 : std_logic_vector(7 downto 0);
    signal sign_out     : std_logic;
    signal exp_out      : std_logic_vector(3 downto 0);
    signal frac_out     : std_logic_vector(7 downto 0);
    -- saidas do hex_to_sseg, ainda na convencao do livro (7 downto 0,
    -- com o bit 7 = ponto decimal)
    signal led3, led2, led1, led0 : std_logic_vector(7 downto 0);

    -- displays sao ativos em '0' -> tudo em '1' = display apagado
    -- (8 bits: 7 segmentos + ponto decimal)
    constant DISPLAY_APAGADO : std_logic_vector(0 to 7) := "11111111";
begin
    -- =================================================================
    -- Montagem dos operandos de entrada do somador
    -- =================================================================
    -- operando 1: fixo, so os 2 LSBs variam (reaproveita sw(1)/sw(0),
    -- igual ao livro original)
    sign1 <= '0';
    exp1  <= "1000";
    frac1 <= '1' & sw(1) & sw(0) & "10101";

    -- operando 2: sinal + fracao pelos mesmos 8 switches do livro;
    -- expoente vem dos 2 switches extras + os 2 botoes da DE10-Lite.
    --
    -- Os KEY da DE10-Lite sao ATIVOS EM '0' (solto = '1', pressionado =
    -- '0'), ao contrario dos 'btn' ativos em '1' da placa Xilinx do
    -- livro. O 'not' preserva a semantica original: botao solto
    -- contribui '0' para o expoente, pressionado contribui '1'.
    -- >> Confirmar a polaridade no DE10-Lite User Manual antes da
    -- >> gravacao na placa (Etapa 3). Se estiver invertido, basta
    -- >> remover os dois 'not' desta linha.
    sign2 <= sw(7);
    exp2  <= sw(9) & sw(8) & (not key(1)) & (not key(0));
    frac2 <= '1' & sw(6 downto 0);

    -- =================================================================
    -- Somador de ponto flutuante (INALTERADO desde a Etapa 1)
    -- =================================================================
    fp_add_unit : entity work.fp_adder
        port map (
            sign1 => sign1, sign2 => sign2, exp1 => exp1, exp2 => exp2,
            frac1 => frac1, frac2 => frac2,
            sign_out => sign_out, exp_out => exp_out, frac_out => frac_out
        );

    -- =================================================================
    -- Decodificadores hex -> 7 segmentos (hex_to_sseg = Listing 3.12,
    -- transcricao fiel do livro, nao alterada)
    -- =================================================================
    -- expoente
    sseg_unit_0 : entity work.hex_to_sseg
        port map (hex => exp_out, dp => '0', sseg => led0);
    -- 4 LSBs da fracao
    sseg_unit_1 : entity work.hex_to_sseg
        port map (hex => frac_out(3 downto 0), dp => '1', sseg => led1);
    -- 4 MSBs da fracao
    sseg_unit_2 : entity work.hex_to_sseg
        port map (hex => frac_out(7 downto 4), dp => '0', sseg => led2);

    -- sinal (barra do meio = negativo, apagado = positivo).
    -- Bit 0 = segmento 'g' na convencao do livro; '0' = aceso.
    led3 <= "11111110" when sign_out = '1' else
            "11111111";

    -- =================================================================
    -- Ligacao direta aos displays da DE10-Lite (sem multiplexacao)
    -- =================================================================
    -- ATENCAO: as atribuicoes abaixo NAO sao redundantes, mesmo parecendo
    -- copia bit a bit. O lado direito e um slice 'downto' (elemento mais
    -- a esquerda = indice 6 = segmento 'a'); o lado esquerdo e declarado
    -- 'to' (elemento mais a esquerda = indice 0 = segmento 'a'). Em VHDL a
    -- atribuicao entre vetores e POSICIONAL, nao por indice: o elemento
    -- mais a esquerda da direita vai para o mais a esquerda da esquerda.
    -- Resultado: segmento 'a' do livro cai no segmento 'a' da placa, e
    -- assim por diante. Trocar qualquer um dos dois sentidos embaralha
    -- os segmentos na placa (o display acende os traços errados).
    --
    -- O bit 7 do livro e o ponto decimal, e ele TAMBEM tem pino na placa
    -- (docs/DE10_LITE.qsf: PIN_D15 -to HEX0[7], e equivalentes nos outros
    -- displays). Por isso ele vai no fim da concatenacao, caindo no indice
    -- 7 do vetor 'to' -- que e exatamente onde o arquivo da professora
    -- espera o DP. O texto do roteiro mostra os displays com 7 bits
    -- (0 to 6) por simplicidade, mas o .qsf atribui os 8.
    --
    --   led(6..0) = segmentos a..g       -> HEX(0..6)
    --   led(7)    = ponto decimal        -> HEX(7)
    HEX0 <= led0(6 downto 0) & led0(7);
    HEX1 <= led1(6 downto 0) & led1(7);
    HEX2 <= led2(6 downto 0) & led2(7);
    HEX3 <= led3(6 downto 0) & led3(7);

    -- displays sobrando: apagados explicitamente (ver nota 4)
    HEX4 <= DISPLAY_APAGADO;
    HEX5 <= DISPLAY_APAGADO;
end arch;
