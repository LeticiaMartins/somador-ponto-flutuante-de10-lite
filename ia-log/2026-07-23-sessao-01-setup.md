# Diário de bordo IA — Sessão 01 (Setup)

- **Data:** 2026-07-23
- **Ferramenta:** Claude Code (modelo Claude Opus 4.8, Anthropic)
- **Responsável pela sessão:** Leticia Martins
- **Etapa do projeto:** Preparação / Etapa 1

> **Lembrete da professora:** a responsabilidade técnica é 100% do grupo. Este
> diário existe para tornar o uso da IA auditável, não para terceirizar decisão.

---

## Objetivo da sessão
Planejar o projeto, montar a estrutura do repositório e os arquivos-base
(código VHDL do PDF, testbench, template do relatório, scripts).

## Prompt inicial (do grupo, resumido)
> "Vamos planejar o desenvolvimento do trabalho de Sistemas Digitais. Leia os
> dois PDFs, crie o repositório público no GitHub com os arquivos-base (ex:
> template do relatório), vá atualizando o relatório com o que fizermos, e sirva
> de guia. A pasta vai para um pen drive para rodar no PC da faculdade; salve as
> informações necessárias para continuar em outra máquina."

## O que a IA fez nesta sessão
1. Leu os dois PDFs (descrição do projeto + código-fonte do somador).
2. Buscou o template oficial do relatório no GitHub da professora
   (`victorialejandra/template-somadorpf-vhdl`).
3. Criou a estrutura de pastas (`src/`, `sim/`, `quartus/`, `docs/`, `ia-log/`,
   `imagens/`).
4. Transcreveu do PDF: `src/fp_adder.vhd` (Listing 3.19) e
   `src/fp_adder_test.vhd` (Listing 3.20).
5. Escreveu `sim/fp_adder_tb.vhd` — testbench com 4 casos cobrindo os 4
   caminhos da normalização (ver análise crítica abaixo).
6. Criou scripts (`sim/run_sim.sh`, `salvar.sh`), `README.md` (relatório),
   `CONTINUIDADE.md` e `.gitignore`.

## Análise crítica (obrigatória para o relatório)
- **O que precisa ser VALIDADO pelo grupo:** os valores esperados dos 4 casos
  do testbench foram calculados pela IA. **Precisamos conferir na mão** (ou pela
  simulação) se batem — não confiar cegamente.
- **Dependências que a IA apontou mas não temos ainda:** `fp_adder_test.vhd`
  usa `hex_to_sseg.vhd` e `disp_mux.vhd`, que **não estão no PDF** e precisam
  ser baixados do Moodle. Sem eles a Etapa 3 não compila.
- **Alerta que a IA levantou:** a placa DE10-Lite tem 10 switches, 2 botões e 6
  displays — diferente da placa do livro (8 switches, 4 botões, 4 displays).
  As larguras de `sw`, `btn`, `an`, `sseg` vão precisar de adaptação na Etapa 2.

## Erros / alucinações da IA nesta sessão
> _(Nenhum confirmado ainda — preencher quando a simulação rodar e mostrar se
> os valores esperados calculados pela IA estavam certos.)_

## Próximos passos
- [ ] Instalar GHDL + GTKWave e rodar `sim/run_sim.sh`.
- [ ] Conferir os 4 casos do testbench na simulação.
- [ ] Baixar `hex_to_sseg.vhd` e `disp_mux.vhd` do Moodle.
