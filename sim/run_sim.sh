#!/usr/bin/env bash
# =====================================================================
# run_sim.sh  -- compila e simula o somador no GHDL (Etapa 1)
# Gera um arquivo de ondas para abrir no GTKWave.
#
# Uso:   cd sim && ./run_sim.sh
# Depois: gtkwave fp_adder.ghw
# =====================================================================
set -e

# pasta deste script (funciona rodando de qualquer lugar / pen drive)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$DIR/../src"
BUILD="$DIR/build"

mkdir -p "$BUILD"
cd "$BUILD"

echo ">> Analisando (compilando) os arquivos VHDL..."
# --std=08 = VHDL-2008 ; -fsynopsys nao e necessario aqui
ghdl -a --std=08 "$SRC/fp_adder.vhd"
ghdl -a --std=08 "$DIR/fp_adder_tb.vhd"

echo ">> Elaborando o testbench..."
ghdl -e --std=08 fp_adder_tb

echo ">> Rodando a simulacao (gera fp_adder.ghw)..."
ghdl -r --std=08 fp_adder_tb --wave="$DIR/fp_adder.ghw"

echo ""
echo ">> Pronto! Abra as ondas com:"
echo "     gtkwave $DIR/fp_adder.ghw"
