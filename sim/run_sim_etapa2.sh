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
ghdl -a --std=08 "$SRC/disp_mux.vhd"
ghdl -a --std=08 "$SRC/fp_adder.vhd"
ghdl -a --std=08 "$SRC/fp_adder_test.vhd"
ghdl -a --std=08 "$DIR/fp_adder_test_tb.vhd"

echo ">> Elaborando o testbench..."
ghdl -e --std=08 fp_adder_test_tb

echo ">> Rodando a simulacao (gera fp_adder_test.ghw)..."
ghdl -r --std=08 fp_adder_test_tb --wave="$DIR/fp_adder_test.ghw"

echo ""
echo ">> Pronto! Abra as ondas com:"
echo "     gtkwave $DIR/fp_adder_test.ghw"
