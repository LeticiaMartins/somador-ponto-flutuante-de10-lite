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

*(Espaço para incluir a tabela dos 4 casos de teste e/ou diagrama detalhado.)*

*Etapa 2*
## 3. Adaptações de Hardware (DE10-Lite)
Indicar o que a arquitetura original usava e quais mudanças foram feitas para a
implementação na placa.

**O que mudamos no VHDL original:**
* Removemos... _(a preencher na Etapa 2)_
* Roteamos ... _(a preencher na Etapa 2)_
* Reorganizamos ... _(a preencher na Etapa 2)_

**Descrição gráfica do sistema**
* Caso mude em relação ao item 2, atualizar aqui.

## 4. Evidências de Validação

### Simulação
Imagem do funcionamento do 4º estágio (normalização), considerando os 4 casos.

![Formas de onda no GTKWave](imagens/ondas-etapa1.png)

_Casos simulados (ver `sim/fp_adder_tb.vhd`):_

| Caso | Descrição | Comportamento do 4º estágio |
|---|---|---|
| 1 | soma sem carry | normaliza sem deslocar |
| 2 | subtração com zeros à esquerda | desloca à esquerda |
| 3 | subtração pequena demais | resultado = 0 |
| 4 | soma com carry-out | desloca à direita, `exp+1` |

### Código VHDL Final
O código final está em [`src/fp_adder.vhd`](src/fp_adder.vhd). Os trechos mais
importantes da adaptação serão destacados aqui na Etapa 2.

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

**O Erro da IA (Alucinação):**
> _(a preencher conforme os erros que encontrarmos e corrigirmos)_

**A Correção Humana:**
> _(a preencher: como o grupo corrigiu/validou o que a IA gerou)_

## 6. Contribuição dos participantes
Taxonomia [CRediT](https://credit.niso.org/):
 * **[Nome do Aluno 1]** — Administração do Projeto, Desenvolvimento de software, Análise Formal
 * **[Nome do Aluno 2]** — Validação de dados e experimentos
 * **[Nome do Aluno 3]** — Redação do manuscrito original, Validação de dados e experimentos
