# Diário de bordo IA — Sessão 03 (Etapa 2: componentes faltantes)

- **Data:** 2026-07-24
- **Ferramenta:** Claude Code (modelo Claude Sonnet 5, Anthropic)
- **Responsável pela sessão:** Leticia Martins
- **Etapa do projeto:** Início da Etapa 2 (adaptação para DE10-Lite)

> **Lembrete da professora:** a responsabilidade técnica é 100% do grupo. Este
> diário existe para tornar o uso da IA auditável, não para terceirizar decisão.

---

## Objetivo da sessão
Resolver a dependência pendente desde a sessão 01: `fp_adder_test.vhd`
(Listing 3.20) instancia `hex_to_sseg` e `disp_mux`, que não estavam em
nenhum dos PDFs fornecidos pela professora.

## O que foi feito
1. O grupo perguntou de onde veio a afirmação "baixar do Moodle" — resposta:
   era uma inferência da sessão 01 (não confirmada), baseada no slide da
   professora que lista "Código e explicações (Moodle)". Não era fato
   verificado.
2. O grupo forneceu o link do ebook completo do livro-texto
   (`https://blog.aku.edu.tr/ismailkoyuncu/files/2017/04/02_ebook.pdf`;
   já era a fonte citada no cabeçalho de `docs/codigo-fonte-livro-pong-chu.pdf`).
3. Baixamos o ebook completo (~17,5 MB) e buscamos os dois componentes:
   - **`hex_to_sseg`** — Listing 3.12, seção 3.7.1, páginas 56-57.
   - **`disp_mux`** — Listing 4.13, seção 4.5.1, páginas 90-91.
4. **Cuidado metodológico:** a extração automática de texto do PDF
   (`pdftotext`) veio corrompida (sublinhados viravam hífen, alguns
   literais binários embaralhados) — não confiável para transcrever bits
   de padrão de display. Por isso, cada página foi lida visualmente
   (imagem renderizada da página, não o texto extraído) antes de transcrever
   o código, e os padrões de 7 segmentos foram conferidos manualmente contra
   o padrão conhecido (dígito "0" acende tudo menos o segmento central `g`;
   dígito "1" acende só `b`/`c`) para confirmar a ordem de bits.
5. Criados `src/hex_to_sseg.vhd` e `src/disp_mux.vhd`, com cabeçalho
   indicando a fonte exata (listing/seção/página) e o método de verificação.

## Análise crítica (obrigatória para o relatório)
- **Ainda não verificado pelo grupo:** o grupo decidiu usar a transcrição do
  livro em vez de esperar confirmar o Moodle. Se o Moodle tiver uma versão
  diferente/adaptada pela professora, vale comparar antes da Etapa 3.
- **Achado a resolver na Etapa 2:** `disp_mux` (Listing 4.13) multiplexa
  apenas **4** displays (`in0..in3`), mas a DE10-Lite tem **6** displays
  (HEX0-HEX5). Isso não trava a Etapa 2 (o `fp_adder_test` original só usa 4
  dígitos: sinal + expoente + 2 dígitos de fração), mas é uma decisão de
  projeto a tomar: usar só 4 dos 6 displays, ou estender o multiplexador
  para 6 vias.
- Nenhum erro/alucinação da IA identificado nesta sessão (arquivos
  conferidos visualmente contra o livro antes de salvar).

## Adaptação para a DE10-Lite (mapeamento de pinos)

Decisão de projeto tomada nesta sessão, com o grupo:

- `exp2` (4 bits) — no livro vinha inteiro dos 4 botões. A DE10-Lite só tem
  2 (`KEY0/KEY1`). Solução: `exp2 <= sw(9) & sw(8) & key(1) & key(0)` — os
  2 switches extras que a DE10-Lite tem a mais (10 vs 8 do livro) cobrem os
  2 bits que os botões que faltam não conseguem mais dar. Usa 100% dos
  switches/botões disponíveis, sem tirar capacidade do circuito original.
- `sign1, exp1, frac1` (operando fixo) e `sign2, frac2` (via `sw(7 downto 0)`)
  não mudaram — mesma lógica do livro.
- Displays: mantido em 4 (dos 6 disponíveis na DE10-Lite), igual ao
  original — sinal + expoente + 2 dígitos de fração. Pode ser estendido
  para 6 depois, se o grupo quiser.

**Organização dos arquivos (a pedido do grupo, para manter histórico como
cópias físicas, não só via git log):**
- `src/fp_adder_test.vhd` — versão ativa, adaptada para a DE10-Lite (Etapa 2).
- `src/fp_adder_test_etapa1_livro.vhd` — cópia congelada do Listing 3.20
  original (sem nenhuma alteração), só para comparação no relatório. Entity
  renomeada para evitar colisão de nome ao compilar os dois juntos.

**Novo testbench (`sim/fp_adder_test_tb.vhd`):** instancia o
`fp_adder_test` adaptado e observa `sign_out`/`exp_out`/`frac_out` — sinais
*internos* do wrapper — via *external names* (VHDL-2008), técnica que evita
ter que decodificar a multiplexação temporal do `disp_mux` só para conferir
o resultado numérico. Verificado (só `ghdl -a`/`-e`, análise/elaboração, sem
rodar `-r`) que compila sem erro antes de entregar para o grupo rodar.

## Próximos passos
- [x] Localizar e transcrever `hex_to_sseg.vhd` e `disp_mux.vhd`.
- [x] Decidir o mapeamento de pinos da DE10-Lite.
- [x] Adaptar `fp_adder_test.vhd` com os novos nomes/larguras de porta.
- [x] Criar novo testbench (Etapa 2) provando que a lógica matemática do
      `fp_adder` continua correta através do wrapper adaptado.
- [x] Conferir que compila (análise/elaboração GHDL, sem rodar).
- [x] Atualizar `README.md` (seção 3, Etapa 2) com a adaptação feita.

## Onde retomar (próxima sessão)
1. **Rodar a simulação de verdade (grupo):**
   ```bash
   cd sim   # ou ~/sistemas-digitais-work/sim se copiar pro disco local de novo
   chmod +x run_sim_etapa2.sh
   ./run_sim_etapa2.sh
   gtkwave build_etapa2/fp_adder_test.ghw &
   ```
   Conferir se os 4 casos (A-D) do `fp_adder_test_tb.vhd` reportam `sign/exp/
   frac` batendo com os comentários no início de cada caso no próprio
   arquivo. Se algum falhar, mesmo processo de investigação da Etapa 1
   (inspecionar waveform, comparar com a lógica esperada).
2. Depois de validado: preencher a seção "Evidências de Validação" da Etapa 2
   no `README.md` com os prints (mesmo padrão da Etapa 1: tabela de casos +
   imagens em `imagens/`).
3. Decidir se querem estender `disp_mux`/`fp_adder_test` para usar os 6
   displays da DE10-Lite (hoje usa só 4) — opcional, não bloqueia.
4. Confirmar no Moodle se `hex_to_sseg.vhd`/`disp_mux.vhd` têm uma versão
   oficial da professora diferente da transcrição do livro que usamos (ver
   sessão 03) — comparar antes da Etapa 3.
5. Depois da Etapa 2 fechada: seguir pra **Etapa 3** (Quartus + placa física
   — roteiro em `docs/MCTA024_Lab3_2026-2a.pdf`), que aí sim usa os arquivos
   `ContadorBinario`/pinout como aquecimento antes do projeto do somador em
   si.
6. Lembrar de confirmar com a professora/Moodle se a "Simulação no Questa
   validada" (critério de 100% da nota, ver `docs/descricao-projeto.pdf`)
   é adicional ao GHDL ou se GHDL é aceito como equivalente.

## Estado dos arquivos ao final desta sessão
Tudo salvo no pendrive (`/media/ufabc/UBUNTU 24_0/sistemas-digitais`), que é
o repositório canônico. Nada foi commitado nem enviado ao GitHub nesta
sessão (decisão do grupo: só sincronizar de casa). `git status` mostra tudo
como alterações não commitadas — normal, revisar e commitar quando
conveniente.
