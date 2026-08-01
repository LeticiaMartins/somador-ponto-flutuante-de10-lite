#!/usr/bin/env bash
# =====================================================================
# run_sim_equivalencia.sh -- prova que a adaptacao para a DE10-Lite nao
# mudou o resultado do circuito (Etapa 2).
#
# Instancia lado a lado a versao congelada do livro (Listing 3.20) e a
# versao adaptada, alimenta as duas com estimulos correspondentes e
# compara os resultados nas 4096 combinacoes possiveis de entrada.
#
# Uso:  cd sim && ./run_sim_equivalencia.sh
#
# Nao gera arquivo de ondas: e um teste de pass/fail sobre 4096 casos,
# nao algo que se inspeciona no GTKWave. Para ver ondas, use
# ./run_sim_etapa2.sh.
# =====================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$DIR/../src"
BUILD="$DIR/build_equivalencia"

mkdir -p "$BUILD"
cd "$BUILD"

echo ">> Analisando (compilando) os arquivos VHDL..."
ghdl -a --std=08 "$SRC/hex_to_sseg.vhd"
# disp_mux entra AQUI (e so aqui): a versao congelada do livro depende
# dele. O circuito adaptado para a DE10-Lite nao usa mais este componente.
ghdl -a --std=08 "$SRC/disp_mux.vhd"
ghdl -a --std=08 "$SRC/fp_adder.vhd"
ghdl -a --std=08 "$SRC/fp_adder_test_etapa1_livro.vhd"
ghdl -a --std=08 "$SRC/fp_adder_test.vhd"
ghdl -a --std=08 "$DIR/fp_adder_equiv_tb.vhd"

echo ">> Elaborando o testbench de equivalencia..."
ghdl -e --std=08 fp_adder_equiv_tb

echo ">> Comparando as duas versoes (4096 combinacoes)..."
ghdl -r --std=08 fp_adder_equiv_tb
