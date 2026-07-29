# Tutorial: Implementação de Somador Ponto Flutuante na DE10-Lite

**Autores:** [Nome do Aluno 1], [Nome do Aluno 2], [Nome do Aluno 3]

**Disciplina:** Sistemas Digitais (MCTA024) — Q2.2026

**Professora:** Victoria Alejandra Herrera

**Data:** [Data da entrega]

---

> **Como este repositório está organizado**
> ```
> ├── src/                VHDL de projeto (fp_adder, fp_adder_test)
> ├── sim/                Testbench + script de simulação (GHDL/GTKWave)
> ├── quartus/            Projeto Intel Quartus (Etapa 3)
> ├── docs/               PDFs de referência do projeto
> ├── imagens/            Prints de ondas e da placa para o relatório
> ├── ia-log/             Diário de bordo do uso de IA (auditoria)
> └── CONTINUIDADE.md     Como retomar o projeto em outra máquina (pen drive)
> ```

---
*Etapa 1*
## 1. Objetivo do Projeto
Este projeto adapta o somador de ponto flutuante simplificado (13 bits) do
livro-texto (*Pong P. Chu, FPGA Prototyping by VHDL Examples*) para a placa
Terasic **DE10-Lite (FPGA Intel MAX 10)**. O objetivo é demonstrar a síntese
lógica e a simulação de hardware usando VHDL.

**Formato de ponto flutuante (13 bits):**

| Campo | Bits | Descrição |
|---|---|---|
| `sign` (s) | 1 | sinal (1 = negativo) |
| `exp` (e) | 4 | expoente (sem sinal) |
| `frac` (f) | 8 | significando / fração (sem sinal) |

O valor representado é **(-1)ˢ × 0.f × 2ᵉ**. A representação é sempre
*normalizada* (MSB da fração = 1) ou *zero*.

## 2. Descrição gráfica do funcionamento do sistema

O somador processa a soma em **4 estágios** encadeados (combinacionais):

```
 entradas                                                         saída
 (s1,e1,f1)   ┌────────┐   ┌──────────┐   ┌──────────┐   ┌────────────┐
 (s2,e2,f2)──▶│ 1.      │──▶│ 2.        │─▶│ 3.        │─▶│ 4.          │──▶ (s,e,f)
              │ Ordenar │   │ Alinhar   │  │ Somar/    │  │ Normalizar  │
              │ (b/s)   │   │ (shift dir)│  │ Subtrair  │  │ (shift esq) │
              └────────┘   └──────────┘   └──────────┘   └────────────┘
```

1. **Ordenar (sort):** coloca o número de maior magnitude em cima (*big*) e o
   menor embaixo (*small*). Compara `exp&frac` dos dois operandos.
2. **Alinhar (align):** desloca a fração do menor número à **direita** por
   `expb - exps`, igualando os expoentes.
3. **Somar/Subtrair:** se os sinais são iguais, soma; se diferentes, subtrai.
   Usa 1 bit extra para o *carry-out*.
4. **Normalizar:** três casos —
   - *carry-out* (soma estourou): desloca à direita, `exp+1`;
   - *zeros à esquerda* (subtração): desloca à esquerda e conta os zeros;
   - *pequeno demais*: resultado vira **zero**.

**Interface do circuito (entradas/saídas do VHDL):**

| Porta | Direção | Largura | Descrição |
|---|---|---|---|
| `sign1, sign2` | in | 1 | sinais dos operandos |
| `exp1, exp2` | in | 4 | expoentes |
| `frac1, frac2` | in | 8 | frações |
| `sign_out` | out | 1 | sinal do resultado |
| `exp_out` | out | 4 | expoente do resultado |
| `frac_out` | out | 8 | fração do resultado |

*Etapa 2*
## 3. Adaptações de Hardware (DE10-Lite)

A placa do livro (Nexys/Basys, Xilinx) tem 8 switches, 4 botões e 4 displays
de 7 segmentos. A DE10-Lite tem **10 switches, 2 botões (KEY) e 6 displays
(HEX0-HEX5)** — larguras diferentes em quase todo I/O usado pelo circuito de
teste (`fp_adder_test.vhd`, Listing 3.20).

**O que mudamos no VHDL original:**
* **`exp2` (4 bits):** no livro vinha inteiro dos 4 botões (`btn(3 downto 0)`).
  A DE10-Lite só tem 2 botões físicos, então passamos a montar `exp2` como
  `sw(9) & sw(8) & key(1) & key(0)` — os **2 switches extras** que a
  DE10-Lite tem a mais (10 vs 8 do livro) cobrem exatamente os 2 bits que os
  botões que faltam não conseguem mais fornecer. Usa 100% dos switches e
  botões disponíveis, sem tirar capacidade de teste do circuito original.
* **`sw`:** largura ampliada de 8 para 10 bits (`sw(9 downto 0)`).
* **`btn` → `key`:** renomeado e reduzido de 4 para 2 bits, para bater com
  os nomes reais dos botões da DE10-Lite (`KEY0`/`KEY1`).
* **`sign1, exp1, frac1`** (operando fixo) e **`sign2, frac2`** (via
  `sw(7 downto 0)`) **não mudaram** — mesma lógica do livro.
* **Displays:** mantivemos em 4 (dos 6 disponíveis), igual ao circuito
  original — sinal + expoente + 2 dígitos de fração. Pode ser estendido
  para os 6 displays depois.
* A versão original (Listing 3.20, sem nenhuma alteração) foi preservada
  como cópia física em
  [`src/fp_adder_test_etapa1_livro.vhd`](src/fp_adder_test_etapa1_livro.vhd)
  para comparação direta com a versão adaptada em
  [`src/fp_adder_test.vhd`](src/fp_adder_test.vhd).
* Dois componentes que o `fp_adder_test` usa (`hex_to_sseg` e `disp_mux`) não
  estavam nos PDFs do projeto — foram localizados e transcritos do
  livro-texto completo (Listings 3.12 e 4.13); ver
  [`ia-log/2026-07-24-sessao-03-etapa2-componentes.md`](ia-log/2026-07-24-sessao-03-etapa2-componentes.md).

**Descrição gráfica do sistema**
* Sem mudança na estrutura dos 4 estágios do somador (item 2) — a adaptação
  desta etapa é só na "casca" (`fp_adder_test`) que conecta switches/botões/
  displays ao `fp_adder`, que continua inalterado.

**Validação pendente:** o testbench novo
([`sim/fp_adder_test_tb.vhd`](sim/fp_adder_test_tb.vhd)) e o script
([`sim/run_sim_etapa2.sh`](sim/run_sim_etapa2.sh)) já foram criados e
conferidos quanto à compilação (GHDL `-a`/`-e`), mas a simulação
(`-r` + GTKWave) ainda **não foi rodada pelo grupo** — ver `ia-log` da
sessão 03 para os próximos passos.

## 4. Evidências de Validação

### Simulação (Etapa 1 — GHDL + GTKWave)

Rodamos `sim/run_sim.sh` (GHDL: análise → elaboração → execução, gerando
`fp_adder.ghw`) e inspecionamos os 4 casos do testbench (`sim/fp_adder_tb.vhd`)
no GTKWave, conforme o roteiro do Lab 1 fornecido pela professora.

![Visão geral das ondas no GTKWave](imagens/teste-etapa-1-caso-base.png)

_Casos simulados e resultado observado:_

| Caso | Descrição | Entradas (A, B) | Saída esperada (s, e, f) | Resultado | Evidência |
|---|---|---|---|---|---|
| 1 | soma sem carry | +0.10100000×2⁴ , +0.10000000×2² | 0, 0100, 11000000 | ✅ OK | [teste-etapa-1-caso-1.png](imagens/teste-etapa-1-caso-1.png) |
| 2 | subtração, zeros à esquerda → desloca à esquerda | +0.10100000×2⁴ , −0.10000000×2⁴ | 0, 0010, 10000000 | ✅ OK | [teste-etapa-1-caso-2.png](imagens/teste-etapa-1-caso-2.png) |
| 3 | subtração pequena demais → resultado = 0 | +0.10000000×2¹ , −0.10000000×2¹ | **1**, 0000, 00000000 | ✅ OK (após correção — ver análise abaixo) | [teste-etapa-1-caso-3.png](imagens/teste-etapa-1-caso-3.png) |
| 4 | soma com carry-out → desloca à direita, `exp+1` | +0.11111111×2⁴ , +0.11111111×2⁴ | 0, 0101, 11111111 | ✅ OK | [teste-etapa-1-caso-4.png](imagens/teste-etapa-1-caso-4.png) |

**Achado de validação — sinal do zero não é canônico:** na primeira rodada, o
Caso 3 falhou porque o testbench esperava `sign=0`. Investigando o waveform e
comparando linha a linha com o **Listing 3.19 original do livro**
(`docs/codigo-fonte-livro-pong-chu.pdf`), confirmamos que:

- `sign_out <= signb;` (linha 107 do livro) nunca é forçado a `0` quando o
  resultado numérico é zero — só `exp`/`frac` são zerados. Isso é assim **no
  livro original**, não é um erro da nossa transcrição.
- Como no Caso 3 as magnitudes de entrada são iguais (`exp&frac` empatados), o
  1º estágio (comparação `>` estrita) sempre resolve o empate escolhendo o
  operando 2 como "big" — por isso `sign_out` sai `1`.
- Conclusão: o algoritmo simplificado do livro **não implementa "zero com
  sinal canônico"** (diferente do `+0` do IEEE 754). É uma limitação real e
  documentada do design original, não um bug do circuito.

O valor esperado do testbench foi corrigido para `sign=1` (ver
`sim/fp_adder_tb.vhd`, Caso 3, e o registro completo em
[`ia-log/2026-07-24-sessao-02-etapa1-simulacao.md`](ia-log/2026-07-24-sessao-02-etapa1-simulacao.md)).

### Código VHDL Final (Etapa 1)
`src/fp_adder.vhd` é uma transcrição fiel do Listing 3.19 do livro-texto, **sem
nenhuma alteração de lógica** — conferida linha a linha nesta etapa
especificamente por causa do achado acima. Os trechos adaptados para a
DE10-Lite serão destacados aqui na Etapa 2.

*Etapa 3*

### Funcionamento na Placa
Imagens do funcionamento na placa DE10-Lite para os 4 casos. _(a preencher)_

*Etapa 4*
## 5. Diário de Bordo de IA
Utilizamos o **Claude (Anthropic)** para auxiliar no entendimento do código,
na geração do testbench, na organização do repositório e na adaptação para a
DE10-Lite. O registro completo e cronológico está na pasta
[`ia-log/`](ia-log/). Abaixo, a análise crítica.

**Prompts Utilizados:**
> _(ver `ia-log/` para o registro completo dos prompts)_

**O Erro da IA (Alucinação) — Etapa 1:**
> Ao criar o testbench `sim/fp_adder_tb.vhd` (sessão 1), a IA calculou os 4
> casos de teste, incluindo o Caso 3 (resultado zero), e assumiu — sem
> verificar contra o livro-texto — que o circuito canonizaria o sinal do zero
> como `0`, seguindo a convenção do IEEE 754 (`+0`/`-0`). Essa suposição
> estava errada: o formato simplificado do livro nunca define esse
> comportamento.

**A Correção Humana:**
> Rodamos a simulação (Etapa 1) e o Caso 3 falhou. Em vez de aceitar o erro
> como um problema do circuito, investigamos o waveform no GTKWave e
> comparamos `src/fp_adder.vhd` linha a linha com o Listing 3.19 original do
> livro (`docs/codigo-fonte-livro-pong-chu.pdf`), confirmando que nossa
> transcrição é fiel e que o comportamento observado (`sign_out=1`) é o
> comportamento correto e esperado do algoritmo publicado. Corrigimos o valor
> esperado no testbench (não o circuito) e documentamos o achado — ver
> [`ia-log/2026-07-24-sessao-02-etapa1-simulacao.md`](ia-log/2026-07-24-sessao-02-etapa1-simulacao.md)
> para a análise completa e as capturas de tela em `imagens/` para a evidência.

## 6. Contribuição dos participantes
Taxonomia [CRediT](https://credit.niso.org/):
 * **[Nome do Aluno 1]** — Administração do Projeto, Desenvolvimento de software, Análise Formal
 * **[Nome do Aluno 2]** — Validação de dados e experimentos
 * **[Nome do Aluno 3]** — Redação do manuscrito original, Validação de dados e experimentos
