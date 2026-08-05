# Diário de bordo IA — Sessão 02 (Etapa 1: simulação)

- **Data:** 2026-07-24
- **Ferramenta:** Claude Code (modelo Claude Sonnet 5, Anthropic)
- **Responsável pela sessão:** Leticia Martins
- **Etapa do projeto:** Etapa 1 (validação do VHDL original via GHDL/GTKWave)

> **Lembrete da professora:** a responsabilidade técnica é 100% do grupo. Este
> diário existe para tornar o uso da IA auditável, não para terceirizar decisão.

---

## Prompt inicial da sessão
> "Simular o VHDL original do somador (`fp_adder`) no GHDL e conferir os 4 casos
> do testbench contra o resultado esperado do livro, antes de mexer no hardware."

## Objetivo da sessão
Rodar a simulação do `fp_adder` (Etapa 1: "comprovar que o algoritmo matemático
funciona antes de alterar o hardware") e conferir na mão os 4 casos de teste do
testbench, cujos valores esperados foram calculados pela IA na sessão 01 e
ainda não tinham sido validados.

## O que foi feito
1. Rodado `sim/run_sim.sh` (GHDL: `-a` / `-e` / `-r --wave`) e aberto o
   resultado no GTKWave, seguindo o roteiro do **Lab 1** (`MCTA024_Lab1_GHDL_
   Linux_2026-2a.pdf`, fornecido pela professora).
2. 3 dos 4 casos bateram (Caso 1, 2 e 4: `OK`). O **Caso 3** (resultado zero)
   reportou `FALHOU`.
3. Investigação do Caso 3 no GTKWave: `exp_out` e `frac_out` bateram com o
   esperado (`0000`, `00000000`); só `sign_out` divergiu (saiu `1`, esperado
   era `0`).
4. Leitura linha a linha do `src/fp_adder.vhd` e comparação com o **Listing
   3.19 original do livro** (`docs/codigo-fonte-livro-pong-chu.pdf`, Pong P.
   Chu, *FPGA Prototyping by VHDL Examples*, seção 3.7.4):
   - `sign_out <= signb;` (linha 107 do livro / 119 do nosso arquivo) não tem
     nenhum caso especial para zerar o sinal quando o resultado é zero — só
     `expn`/`fracn` são zerados (linhas 97-98 do livro / 110-111 do nosso).
   - No Caso 3, `exp1&frac1 = exp2&frac2` (empate de magnitude). O 1º estágio
     usa `>` estrito (linha 30 do livro / 42 do nosso), então todo empate cai
     no `else` e escolhe o operando 2 como "big" — por isso `sign_out =
     sign2 = '1'`.
   - **Nossa transcrição do `fp_adder.vhd` é fiel ao Listing 3.19** (conferido
     linha por linha); não há erro de cópia da sessão 01.

## Análise crítica (obrigatória para o relatório)
- **Achado confirmado:** o algoritmo simplificado do livro **não implementa
  "zero com sinal canônico"** (diferente do `+0`/`-0` do IEEE 754). Quando o
  resultado numérico é zero, o `sign_out` do circuito reflete apenas qual
  operando o estágio de ordenação escolheu como "big" em caso de empate — não
  há garantia de que venha `0`. Isso é uma limitação real do algoritmo
  publicado por Pong Chu (seção 3.7.4 não menciona esse caso), não uma falha
  de hardware nem de transcrição do grupo.
- **Erro identificado na IA:** o valor esperado `sign='0'` no Caso 3 do
  testbench (sessão 01) partiu de uma suposição não verificada — que o
  circuito canonizaria o sinal do zero, como no IEEE 754. O livro nunca
  afirma isso; a suposição estava errada.
- **Correção aplicada:** `sim/fp_adder_tb.vhd`, Caso 3, valor esperado
  atualizado de `sign='0'` para `sign='1'` (comportamento real e correto do
  circuito original), com comentário explicando a causa raiz e a referência
  ao Listing 3.19.

## Erros / alucinações da IA nesta sessão
- Sessão 01: valor esperado `sign='0'` para o Caso 3 do testbench —
  suposição de comportamento tipo IEEE 754 não suportada pelo livro-texto.
  Corrigido nesta sessão (ver acima).

## Confirmação final
Após a correção, a simulação foi rodada novamente. Capturas de tela em
`imagens/` (21-01 a 21-04) mostram, com todos os sinais inseridos no
GTKWave, os 4 casos batendo com o esperado — em especial o Caso 3
(janela ~50ns): `sign_out=1, exp_out=0000, frac_out=00000000`, confirmando
a correção aplicada nesta sessão.

## Próximos passos
- [x] Rodar `sim/run_sim.sh` e conferir os 4 casos no GTKWave.
- [x] Investigar e corrigir a divergência do Caso 3.
- [x] Rodar a simulação de novo com o testbench corrigido e confirmar que os
      4 casos passam (ver capturas em `imagens/`).
- [ ] Baixar `hex_to_sseg.vhd` e `disp_mux.vhd` do Moodle (necessários pra
      Etapa 3 — ver Listing 3.20).
- [ ] Confirmar com a professora/material do Moodle se a "Simulação no
      Questa validada" (critério de 100% da nota) é adicional ao GHDL, ou se
      GHDL é aceito como equivalente.
