-- =====================================================================
-- disp_mux.vhd
-- Multiplexacao temporal de 4 displays de 7 segmentos (economiza pinos).
--
-- Fonte: Pong P. Chu, "FPGA Prototyping by VHDL Examples", Listing 4.13
-- (secao 4.5.1). Este componente NAO estava nos PDFs do projeto/livro
-- fornecidos pela professora; foi transcrito do livro completo, conferido
-- visualmente pagina a pagina (o texto extraido automaticamente do PDF
-- vinha corrompido).
-- Requerido por fp_adder_test.vhd (Listing 3.20).
--
-- ATENCAO (Etapa 2/3): este design original multiplexa 4 displays (in0..
-- in3). A DE10-Lite tem 6 displays (HEX0..HEX5) -- avaliar se todos os 6
-- serao usados ou se 4 bastam pro nosso caso (sinal + expoente + 2 digitos
-- de fracao = 4 digitos, como no fp_adder_test original).
-- =====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity disp_mux is
    port (
        clk, reset           : in  std_logic;
        in3, in2, in1, in0   : in  std_logic_vector(7 downto 0);
        an                   : out std_logic_vector(3 downto 0);
        sseg                 : out std_logic_vector(7 downto 0)
    );
end disp_mux;

architecture arch of disp_mux is
    -- taxa de atualizacao em torno de 800 Hz (50MHz / 2^16)
    constant N : integer := 18;
    signal q_reg, q_next : unsigned(N-1 downto 0);
    signal sel : std_logic_vector(1 downto 0);
begin
    -- registrador
    process (clk, reset)
    begin
        if reset = '1' then
            q_reg <= (others => '0');
        elsif (clk'event and clk = '1') then
            q_reg <= q_next;
        end if;
    end process;

    -- logica de proximo estado do contador
    q_next <= q_reg + 1;

    -- 2 MSBs do contador controlam o multiplexador 4-para-1
    -- e geram o sinal de enable ativo em '0'
    sel <= std_logic_vector(q_reg(N-1 downto N-2));
    process (sel, in0, in1, in2, in3)
    begin
        case sel is
            when "00" =>
                an   <= "1110";
                sseg <= in0;
            when "01" =>
                an   <= "1101";
                sseg <= in1;
            when "10" =>
                an   <= "1011";
                sseg <= in2;
            when others =>
                an   <= "0111";
                sseg <= in3;
        end case;
    end process;
end arch;
