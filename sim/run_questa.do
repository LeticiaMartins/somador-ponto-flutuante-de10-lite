# =====================================================================
# run_questa.do -- simulacao da Etapa 2 no Questa (Intel Starter Edition)
#
# Por que este script existe: o Quartus, ao abrir o Questa via
# "Tools -> Run Simulation Tool -> RTL Simulation", compila apenas os
# arquivos DE PROJETO (src/). Os testbenches nao fazem parte do projeto
# Quartus -- eles nao vao para a placa -- entao precisam ser compilados
# aqui.
#
# Uso, no console do Questa (prompt "Questa>"):
#     do /caminho/para/sim/run_questa.do
#
# Se o Questa foi aberto pelo Quartus, o caminho completo e:
#     do /home/ufabc/sistemas-digitais-work/sim/run_questa.do
#
# O script descobre sozinho onde estao os fontes, entao funciona
# tambem a partir do pen drive ou de outra maquina.
# =====================================================================

# --- descobre a raiz do projeto --------------------------------------
# O Questa nao expoe o caminho do proprio .do ("info script" retorna um
# caminho interno do simulador, nao o arquivo). Entao procuramos a raiz
# subindo de pasta em pasta a partir do diretorio atual, ate achar
# "src/fp_adder.vhd". Funciona quando o Questa e aberto pelo Quartus
# (que abre em quartus/simulation/questa), rodando de qualquer subpasta
# do projeto, no disco local ou no pen drive.
#
# Se por algum motivo nao encontrar, defina o caminho na mao antes:
#     set PROJ_ROOT /home/ufabc/sistemas-digitais-work
#     do .../sim/run_questa.do
if {[info exists PROJ_ROOT]} {
    set ROOT [file normalize $PROJ_ROOT]
} else {
    set ROOT ""
    set d [pwd]
    for {set i 0} {$i < 8} {incr i} {
        if {[file exists [file join $d src fp_adder.vhd]]} { set ROOT $d ; break }
        set p [file dirname $d]
        if {$p eq $d} { break }
        set d $p
    }
}
if {$ROOT eq ""} {
    error "Nao achei a raiz do projeto a partir de [pwd]. Defina 'set PROJ_ROOT <caminho>' antes do 'do'."
}

set SRC_DIR [file join $ROOT src]
set SIM_DIR [file join $ROOT sim]

echo "== projeto : $ROOT"
echo "== fontes  : $SRC_DIR"
echo "== testes  : $SIM_DIR"

# --- biblioteca de trabalho limpa ------------------------------------
# (nao reaproveita a rtl_work que o Quartus criou: aqui precisamos do
#  testbench junto, compilado com VHDL-2008)
catch {vdel -all}
vlib work
vmap work work

# --- compilacao ------------------------------------------------------
# -2008 e obrigatorio: o testbench usa "external names" (<< signal ... >>),
# recurso do VHDL-2008, para espiar sinais internos do DUT.
# disp_mux.vhd nao entra: nao faz parte do circuito da DE10-Lite.
vcom -2008 $SRC_DIR/hex_to_sseg.vhd
vcom -2008 $SRC_DIR/fp_adder.vhd
vcom -2008 $SRC_DIR/fp_adder_test.vhd
vcom -2008 $SIM_DIR/fp_adder_test_tb.vhd

# --- elaboracao ------------------------------------------------------
# +acc mantem os sinais internos acessiveis. Sem isso o otimizador pode
# eliminar sign_out/exp_out/frac_out e os external names do testbench
# deixam de resolver.
vsim -voptargs="+acc" work.fp_adder_test_tb

# --- ondas (so no modo grafico) --------------------------------------
if {![batch_mode]} {
    add wave -divider "Entradas da placa"
    add wave -radix binary sim:/fp_adder_test_tb/sw
    add wave -radix binary sim:/fp_adder_test_tb/key

    add wave -divider "Operando 1 (fixo no hardware)"
    add wave           sim:/fp_adder_test_tb/dut/sign1
    add wave -radix hex sim:/fp_adder_test_tb/dut/exp1
    add wave -radix hex sim:/fp_adder_test_tb/dut/frac1

    add wave -divider "Operando 2 (switches + botoes)"
    add wave           sim:/fp_adder_test_tb/dut/sign2
    add wave -radix hex sim:/fp_adder_test_tb/dut/exp2
    add wave -radix hex sim:/fp_adder_test_tb/dut/frac2

    add wave -divider "Resultado"
    add wave           sim:/fp_adder_test_tb/dut/sign_out
    add wave -radix hex sim:/fp_adder_test_tb/dut/exp_out
    add wave -radix hex sim:/fp_adder_test_tb/dut/frac_out

    add wave -divider "Displays (0 to 7, ativos em 0)"
    add wave -radix binary sim:/fp_adder_test_tb/hex0
    add wave -radix binary sim:/fp_adder_test_tb/hex1
    add wave -radix binary sim:/fp_adder_test_tb/hex2
    add wave -radix binary sim:/fp_adder_test_tb/hex3
}

# --- executa ---------------------------------------------------------
run -all

if {![batch_mode]} {
    wave zoom full
    echo ""
    echo "=== Simulacao concluida. Confira os 5 casos no Transcript. ==="
}
