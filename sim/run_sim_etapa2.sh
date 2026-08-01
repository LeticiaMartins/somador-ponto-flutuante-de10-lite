#!/usr/bin/env bash
# =====================================================================
# run_sim_etapa2.sh -- compila e simula o fp_adder_test no GHDL (Etapa 2)
# Verifica se o roteamento de switches/botoes da DE10-Lite ainda entrega
# os operandos certos pro fp_adder (inalterado desde a Etapa 1).
# Gera um arquivo de ondas para abrir no GTKWave.
#
# Uso:   cd sim && ./run_sim_etapa2.sh
# Depois: gtkwave fp_adder_test.ghw
# =====================================================================
set -e

# pasta deste script (funciona rodando de qualquer lugar / pen drive)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$DIR/../src"
BUILD="$DIR/build_etapa2"

mkdir -p "$BUILD"
cd "$BUILD"

echo ">> Analisando (compilando) os arquivos VHDL..."
# --std=08 = VHDL-2008 (necessario p/ external names do testbench)
ghdl -a --std=08 "$SRC/hex_to_sseg.vhd"
# disp_mux.vhd NAO entra mais no build: a multiplexacao temporal do livro
# nao se aplica a DE10-Lite (displays ligados direto ao FPGA). O arquivo
# fica no repositorio so como registro -- ver cabecalho de fp_adder_test.vhd.
ghdl -a --std=08 "$SRC/fp_adder.vhd"
ghdl -a --std=08 "$SRC/fp_adder_test.vhd"
ghdl -a --std=08 "$DIR/fp_adder_test_tb.vhd"

echo ">> Elaborando o testbench..."
ghdl -e --std=08 fp_adder_test_tb

echo ">> Rodando a simulacao (gera fp_adder_test.ghw)..."
# --stop-time e uma trava de seguranca. Hoje o circuito e combinacional
# puro (sem clk, desde que o disp_mux saiu) e a simulacao termina sozinha,
# mas se algum dia o testbench ganhar um gerador de clock livre
# (clk <= not clk after 10 ns) ele agendaria eventos para sempre e a
# simulacao nunca pararia. Os casos acabam em ~100 ns; 200 ns da folga.
ghdl -r --std=08 fp_adder_test_tb --wave="$DIR/fp_adder_test.ghw" --stop-time=200ns

echo ""
echo ">> Pronto! Abra as ondas com:"
echo "     gtkwave $DIR/fp_adder_test.ghw"
