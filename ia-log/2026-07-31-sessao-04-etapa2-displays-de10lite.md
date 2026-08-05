# Diário de bordo IA — Sessão 04 (Etapa 2: correção da adaptação dos displays)

- **Data:** 2026-07-31
- **Ferramenta:** Claude Code (modelo Claude Opus 5, Anthropic)
- **Responsável pela sessão:** Leticia Martins
- **Local:** computador da faculdade (projeto copiado do pen drive para
  `~/sistemas-digitais-work`)
- **Etapa do projeto:** Etapa 2 — correção e fechamento

> **Lembrete da professora:** a responsabilidade técnica é 100% do grupo. Este
> diário existe para tornar o uso da IA auditável, não para terceirizar decisão.

---

## Prompt inicial da sessão
> "Essa correção que fizemos no script de simulação vale também para a Etapa 3
> (gravação na placa)?" Foi essa pergunta que expôs o problema do `disp_mux`:
> ao investigar, percebemos que a adaptação da Etapa 2 estava incompleta.

## Objetivo da sessão
Retomar o projeto no computador da faculdade e rodar a simulação da Etapa 2,
pendente desde a sessão 03. O que era para ser uma sessão de execução virou
uma sessão de correção — a adaptação da Etapa 2 estava incompleta.

## O que foi feito

### 1. Retomada do ambiente
Projeto copiado do pen drive para o disco local, identidade Git configurada
só neste repositório, bit de execução dos scripts restaurado (o pen drive é
FAT e não preserva permissão de execução). Ferramentas verificadas:
GHDL 4.1.0 ✅, GTKWave 3.3.116 ✅, Quartus 24.1std ✅, `gh` **não instalado**
(sem push a partir desta máquina).

### 2. Achado: `run_sim_etapa2.sh` nunca terminaria
O script chamava `ghdl -r` sem `--stop-time`, e o testbench da sessão 03 tinha
`clk <= not clk after 10 ns` — uma atribuição concorrente que agenda eventos
para sempre. Como a simulação VHDL só termina quando não sobra evento
agendado, ela rodaria indefinidamente gravando o `.ghw`. Consistente com o
registro da sessão 03, que diz que só `-a`/`-e` (compilação) foram validados,
nunca o `-r`. Corrigido com `--stop-time=200ns`.

### 3. Achado principal: o `disp_mux` não se aplica à DE10-Lite
A pergunta do grupo — *"essa alteração se aplica para a etapa 3 da síntese
física?"* — levou à revisão do caminho dos displays, e aí apareceu o problema
de verdade.

O `disp_mux` (Listing 4.13) existe no livro para **economizar pinos**: nas
placas Xilinx (Nexys/Basys) os 4 displays compartilham um único barramento de
8 segmentos, e o vetor `an` seleciona qual está aceso a cada instante,
varrendo a ~800 Hz. A DE10-Lite **não é assim**: os 6 displays são ligados
diretamente ao FPGA, cada um com seus próprios pinos. Não há barramento
compartilhado nem sinal de anodo — **a saída `an` não teria onde ser ligada
na placa**.

Ou seja, a Etapa 2 tinha adaptado switches e botões, mas mantido intacto
justamente o componente que não existe nessa placa.

### 4. Fonte consultada para a correção
Em vez de confiar na memória do modelo sobre a pinagem da DE10-Lite, fomos ao
roteiro da própria professora (`docs/MCTA024_Lab3_2026-2a.pdf`, seção "Seven
Segment Display"), que estabelece:

- há 6 displays, `HEX0`..`HEX5`, cada um declarado
  `HEX0 : out std_logic_vector(0 to 6)` — 7 bits, **ordem ascendente**;
- os segmentos são numerados 0 a 6 e são **ativos em `'0'`**;
- ela avisa explicitamente que o código do Chu declara `6 downto 0` e que
  isso "introduz erros propositalmente" — é exatamente a armadilha em que
  estávamos.

### 5. Correções aplicadas
- **`src/fp_adder_test.vhd`** — reescrito: `disp_mux` removido, saídas
  passam a ser `HEX0`..`HEX5` (`0 to 6`) ligadas diretamente, `clk` removido
  (o circuito virou combinacional puro), `HEX4`/`HEX5` apagados
  explicitamente para não acenderem segmentos aleatórios.
- **Ordem dos bits:** `HEX0 <= led0(6 downto 0);`. Parece cópia bit a bit,
  mas não é — em VHDL a atribuição entre vetores é **posicional**, então o
  elemento mais à esquerda do slice `downto` (índice 6 = segmento *a*) cai no
  mais à esquerda do alvo `to` (índice 0 = segmento *a*). É a tradução entre
  as duas convenções. Comentado no código para ninguém "consertar" depois.
- **Polaridade dos botões:** os `KEY` da DE10-Lite são ativos em `'0'`, ao
  contrário dos `btn` do livro. Aplicado `not` nos dois bits de `key` em
  `exp2`, preservando a semântica original.
- **`src/hex_to_sseg.vhd` e `src/fp_adder.vhd` não foram tocados** — seguem
  transcrições fiéis do livro. Toda a adaptação continua concentrada na
  "casca", como já era o princípio do projeto.
- **`src/disp_mux.vhd`** — mantido no repositório, mas fora do build, com
  cabeçalho explicando por que não se aplica (útil para o relatório).
- **`sim/fp_adder_test_tb.vhd`** — atualizado para a nova interface; gerador
  de clock removido; estímulos dos botões agora usam a convenção física
  (`"11"` = soltos); acrescentado Caso E (HEX4/HEX5 apagados).

### 6. Simulação executada — Etapa 2 validada
Os 5 casos passaram, e a simulação termina sozinha em 80 ns.

| Caso | Estímulo | `sign`, `exp`, `frac` | |
|---|---|---|---|
| A | `sw=0`, botões soltos | `0`, `8`, `95` | ✅ |
| B | `sw9=sw8=1` | `0`, `C`, `89` | ✅ |
| C | + ambos `KEY` pressionados | `0`, `F`, `81` | ✅ |
| D | + `sw7=1` | `1`, `E`, `FE` | ✅ |
| E | `HEX4`/`HEX5` | `1111111` | ✅ |

Os valores foram conferidos manualmente contra o algoritmo, não apenas pelos
`assert` — ver o passo a passo do Caso D no `README.md`.

### 7. Prova de equivalência (a pedido do grupo)
O grupo pediu para rodar os **mesmos casos da Etapa 1** no circuito adaptado,
com o raciocínio correto de que, se só adaptamos para a placa, o resultado
tem que ser idêntico.

Verificando, descobrimos que **os casos da Etapa 1 são inalcançáveis através
do circuito de teste** — e isso vale igualmente para a versão do livro. O
Listing 3.20 fixa o operando 1 no hardware (`exp1 <= "1000"`, `frac1 <= '1' &
sw(1) & sw(0) & "10101"`), então expoente `0100`/`0001` e frações como
`10100000` não são geráveis por nenhum ajuste de switches. Limitação do
livro, não da adaptação: as três linhas são idênticas nas duas versões.

Em vez de abandonar a ideia, implementamos a versão forte dela em
`sim/fp_adder_equiv_tb.vhd`: as duas versões do circuito de teste instanciadas
lado a lado, alimentadas com estímulos correspondentes, comparando
`sign_out`/`exp_out`/`frac_out` em **todas as 4096 combinações** possíveis
(256 × `sw(7..0)` vezes 16 × `exp2`).

```
=== RESULTADO: EQUIVALENTES. Nenhuma divergencia em 4096 combinacoes. ===
```

Isso é mais forte que repetir 4 casos: prova que as duas versões computam a
mesma função para **todo** o espaço de entrada acessível. E, como o `exp2`
chega por caminhos físicos diferentes nas duas (botões ativos em `'1'` no
livro, `sw(9)`/`sw(8)` + `KEY` ativos em `'0'` na DE10-Lite), a equivalência
também valida a inversão de polaridade — se o `not` estivesse errado, as
duas divergiriam.

Complementarmente, reexecutamos o testbench da Etapa 1 (`sim/run_sim.sh`),
que aciona o `fp_adder` diretamente: os 4 casos continuam passando, e o
`git log` confirma que `src/fp_adder.vhd` não é tocado desde o commit
inicial.

## Análise crítica (obrigatória para o relatório)

**Erro da IA nesta etapa (o segundo do projeto):** na sessão 03, a IA
adaptou switches, botões e larguras de porta, mas manteve o `disp_mux` do
livro sem questionar se a arquitetura de displays da DE10-Lite era a mesma
da placa Xilinx. Ela chegou a registrar no cabeçalho do arquivo que "a
DE10-Lite tem 6 displays, avaliar se todos serão usados" — tratou como
questão de *quantidade* (4 de 6) o que era uma diferença *estrutural*
(multiplexado vs. direto). O erro passou porque a validação da sessão 03 foi
só de compilação: `ghdl -a`/`-e` aceita o circuito sem reclamar, já que em
simulação o `an` é apenas um sinal como outro qualquer. O problema só
apareceria na placa, na Etapa 3.

**A correção humana:** o grupo perguntou se a correção do `--stop-time`
valia para a Etapa 3 — pergunta sobre síntese física, não sobre simulação.
Foi isso que levou a IA a revisar o caminho dos displays e encontrar o
problema. Quando a IA propôs seguir e rodar os testes da Etapa 2 antes de
corrigir, o grupo recusou: a Etapa 2 *é* a adaptação para a DE10-Lite, então
não fazia sentido validar um código que não roda na placa. A ordem foi
corrigir primeiro, testar depois. A verificação da pinagem foi feita contra o
roteiro da professora, não contra a memória do modelo.

**Lição metodológica:** "compila" e "simula" não são evidência de que o
circuito é sintetizável *naquela placa*. Diferenças de arquitetura de I/O
(multiplexado vs. direto, ativo em alto vs. baixo, ordem de bits) são
invisíveis no GHDL e só aparecem na síntese ou na placa. Vale revisar cada
componente herdado do livro perguntando *por que ele existe*, não só *se ele
compila*.

## Pendências resolvidas ainda nesta sessão (com o `DE10_LITE.qsf`)
O grupo baixou do Moodle o arquivo de pinos oficial (`docs/DE10_LITE.qsf`),
que resolveu as duas pendências que estavam abertas e revelou uma correção:

- **Polaridade dos `KEY`: confirmada.** O arquivo declara os dois `KEY` com
  padrão de I/O `"3.3 V Schmitt Trigger"` — botão com tratamento de repique
  em hardware e ativo em nível baixo. A inversão (`not key`) que tínhamos
  implementado por inferência está correta. Nenhuma mudança necessária.
- **Ponto decimal: recuperado.** O texto do roteiro mostra os displays com 7
  bits (`0 to 6`), mas o `.qsf` atribui **48 pinos** de display (6 × 8),
  incluindo o DP (`PIN_D15 -to HEX0[7]`). Nossa entity de 7 bits deixaria o
  pino do ponto decimal órfão. Ajustamos os `HEX` para 8 bits e ligamos o DP
  (`HEX0 <= led0(6 downto 0) & led0(7);`), aproveitando o bit que o
  `hex_to_sseg` do livro já produzia e que estávamos descartando.
- **Nomes das portas** passados para maiúscula (`SW`, `KEY`, `HEX0`…) para
  casar literalmente com o arquivo da professora. VHDL é *case-insensitive*,
  então nada muda na simulação.

As três simulações foram reexecutadas após essas mudanças: Etapa 1 (4 casos),
Etapa 2 (5 casos) e equivalência (4096/4096) — todas continuam passando.

**Aviso registrado:** existe em `~/Documentos/projeto/sign_mag_add.qsf` (outro
projeto, fora deste repositório) um `.qsf` que **não serve** para a DE10-Lite:
tem pinos atribuídos em duplicidade, declara `KEY[2]`/`KEY[3]` (a placa só tem
2 botões) e aponta o dispositivo `10M08DAF484C8G` em vez do `10M50DAF484C7G`.
Pinagem errada não gera erro de compilação — a placa apenas não funciona.

## Pendências de verificação (ainda abertas)
- Confirmar com a professora/Moodle se `hex_to_sseg.vhd` tem versão oficial
  dela diferente da transcrição do livro (pendente desde a sessão 03).

## Etapa 3 — concluída na mesma sessão

Com a Etapa 2 fechada, seguimos direto para a síntese física:

1. Projeto Quartus criado em `quartus/` (`10M50DAF484C7G`, top-level
   `fp_adder_test`), com `fp_adder.vhd`, `hex_to_sseg.vhd` e
   `fp_adder_test.vhd`.
2. Pinagem importada de `docs/DE10_LITE.qsf`, baixado do Moodle pelo grupo.
   Pinos não utilizados configurados como *"As input tri-stated"*.
3. Compilação com **0 erros**; gravação na placa via USB-Blaster,
   `100% Successful`.
4. Os 4 comportamentos do somador testados no hardware, com ajustes de
   switches calculados previamente em simulação.
5. **Polaridade dos botões confirmada na placa física:** com `SW9`/`SW8`
   levantados, `HEX0` mostra `C` com os botões soltos e `F` com os dois
   pressionados — exatamente o previsto. Fecha a inferência que a IA tinha
   feito e que o `.qsf` já indicava.

### Simulação no Questa
Executada via script `sim/run_questa.do`, para atender ao critério de 100% da
nota. Dois detalhes que precisaram ser resolvidos e não são óbvios:
- `vcom -2008` — o testbench usa *external names*, recurso do VHDL-2008;
- `vsim -voptargs="+acc"` — sem isso o otimizador do Questa elimina
  `sign_out`/`exp_out`/`frac_out` (sinais internos, sem uso na saída) e os
  *external names* deixam de resolver.

Os 5 casos passaram com valores **idênticos** aos do GHDL. Dois simuladores
independentes concordando é verificação adicional: um erro de transcrição no
testbench apareceria como divergência entre eles. Saída arquivada em
`sim/resultado-questa.txt`.

**Nota metodológica:** a primeira execução do `.do` foi feita pela IA em modo
console, apenas para validar o script antes de entregá-lo. O arquivo
`resultado-questa.txt` versionado é o da execução **do grupo** na interface
gráfica (31/07, 22:28:45) — a evidência corresponde ao que o grupo de fato
rodou, não ao teste da ferramenta.

## Próximos passos
Registrados em `CONTINUIDADE.md`, seção "ONDE PARAMOS", para retomada em
casa. Em resumo: fazer o push (pendente), subir as fotos da placa, preencher
nomes/data/CRediT no README e dar acesso da professora ao repositório.

## Estado dos arquivos ao final desta sessão
Commit `546efdd` em `main`, com 22 arquivos, sincronizado para o pen drive.
**O push ao GitHub ficou pendente** — o `gh` não está instalado no computador
da faculdade, então sai de casa com `./salvar.sh`.

A cópia de trabalho local (`~/sistemas-digitais-work`) foi apagada ao final,
por ser máquina de laboratório compartilhada. O pen drive voltou a ser o
repositório canônico.
