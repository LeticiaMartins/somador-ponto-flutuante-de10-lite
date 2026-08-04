# Diário de bordo IA — Sessão 05 (Fotos da placa / documentação)

- **Data:** 2026-08-04
- **Ferramenta:** Claude Code (modelo Claude Opus 4.8, Anthropic)
- **Responsável pela sessão:** Leticia Martins
- **Etapa do projeto:** Etapa 4 (documentação / entrega)

> **Lembrete da professora:** a responsabilidade técnica é 100% do grupo. Este
> diário existe para tornar o uso da IA auditável, não para terceirizar decisão.

---

## Objetivo da sessão
Anexar ao relatório as fotos da DE10-Lite tiradas no laboratório (testes da
Etapa 3) e ligá-las às tabelas/validações correspondentes no README.

## Prompt inicial (do grupo, resumido)
> "Baixei as fotos na pasta 'Foto das placas'. Acho que está na ordem dos
> testes, começa mostrando 958 no display." (depois: "As fotos mostram 958,
> 81F, 89C, 9d8, 8A9, A85, -001, respectivamente" e "pode deixar as fotos do
> jeito que tirei mesmo, sem rotacionar".)

## O que a IA fez nesta sessão
1. Abriu as 7 fotos (`IMG_9591`–`IMG_9597`) e propôs uma leitura dos displays.
2. **O grupo confirmou as leituras exatas** (958, 81F, 89C, 9D8, 8A9, A85, -001).
3. Cruzou cada leitura com os valores esperados já documentados nas tabelas do
   relatório para mapear foto → caso de teste:
   - `958` → estado inicial (switches todos para baixo; operando padrão)
   - `9D8` → Caso 1 (soma sem carry, `SW8`)
   - `8A9` → Caso 2 (carry-out, `SW9`)
   - `A85` → Caso 3 (subtração + normalização, `SW9 SW7`)
   - `-001` → Caso 4 (resultado zero)
   - `89C` / `81F` → validação da polaridade dos botões (`HEX0` C→F)
4. Redimensionou as fotos (lado maior 1400 px, JPEG) para não pesar o repositório
   — **sem rotacionar**, a pedido do grupo — e salvou em `imagens/` com nomes
   `placa-etapa-3-*.jpg`.
5. Substituiu os `_(a preencher)_` da tabela "Funcionamento na Placa" pelos links
   das imagens e inseriu as fotos inline (baseline, Caso 1, Caso 4, botões C/F).

## Decisão técnica / auditoria
- O mapeamento foto→caso não foi "achismo": cada foto foi validada contra o valor
  esperado (`sign`/`frac`/`exp`) que já constava do relatório desde as Etapas 2 e 3.
- As fotos são evidência de hardware; as telas de simulação (GTKWave/Questa)
  continuam sendo a evidência das Etapas 1 e 2.

## Pendências após esta sessão
- Adicionar a professora como colaboradora do repositório privado.
- Entregar o link no Moodle (entrega em 07/08/2026).
- Confirmar com a professora se `hex_to_sseg.vhd` tem versão oficial dela.
