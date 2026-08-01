# 🔌 CONTINUIDADE — como retomar este projeto em outra máquina

Este arquivo existe porque o projeto vai rodar em **duas máquinas**: seu
notebook (casa) e o **computador da faculdade** (via pen drive). Aqui está tudo
que você precisa para não travar lá.

> ⚠️ **Segurança:** este arquivo **NÃO** guarda senhas nem tokens. Você faz
> login do GitHub e do Claude na hora, no computador da faculdade. Guardar token
> em arquivo no pen drive é risco de segurança — não faça isso.

---

## 📍 ONDE PARAMOS — atualizado em 31/07/2026 (sessão na faculdade)

**Etapas 1, 2 e 3 estão fechadas.** Falta documentação.

Último commit: `546efdd` em `main` — *"Etapa 2 corrigida (displays DE10-Lite)
+ Etapa 3 (sintese e gravacao)"*, com 22 arquivos. Árvore limpa.

### ⚠️ PRIMEIRA COISA A FAZER EM CASA

O commit **ainda não foi enviado ao GitHub** — o `gh` não estava instalado no
computador da faculdade. Antes de qualquer outra coisa:

```bash
./salvar.sh "sincronizando trabalho da faculdade"
```

Se der *"Repository not found"*, é a conta errada ativa — o `salvar.sh` já
troca sozinho, mas veja a seção sobre as duas contas mais abaixo.

### O que foi feito na sessão de 31/07

- **A Etapa 2 estava incompleta e foi corrigida.** O `disp_mux` do livro
  (multiplexação temporal de displays) não se aplica à DE10-Lite, que liga
  cada display direto ao FPGA — a saída `an` não tinha onde ser ligada.
  Removido; o circuito virou combinacional puro. Também corrigidos a largura
  dos displays (8 bits, com ponto decimal), a ordem dos bits e a polaridade
  dos `KEY`.
- **Prova de equivalência:** as duas versões do circuito de teste (livro
  congelado × adaptada) comparadas nas 4096 combinações de entrada possíveis
  — zero divergências.
- **Validado em dois simuladores:** GHDL e Questa, resultados idênticos.
- **Etapa 3 concluída:** projeto Quartus criado, pinagem importada do
  `docs/DE10_LITE.qsf`, compilação sem erros, gravação na placa OK, e os 4
  casos testados no hardware.

### 🔜 PRÓXIMOS PASSOS (em ordem)

1. **`./salvar.sh`** — subir o commit da faculdade para o GitHub (acima).
2. **Subir as fotos da placa.** Já foram tiradas na faculdade. Colocar em
   `imagens/` com estes nomes, que a tabela do README já referencia:
   ```
   placa-etapa-3-caso-1.png     soma sem carry        (SW8)
   placa-etapa-3-caso-2.png     carry-out             (SW9)
   placa-etapa-3-caso-3.png     subtração/normaliz.   (SW9 SW7)
   placa-etapa-3-caso-4.png     resultado zero        (SW9 SW7 SW5 SW4 SW2 SW0)
   placa-etapa-3-botoes.png     teste dos KEY (C → F)
   ```
   Depois, trocar os `_(a preencher)_` da tabela "Funcionamento na Placa"
   (README, Etapa 3) pelos links das imagens.
3. **Preencher os dados do grupo no README:**
   - cabeçalho: `[Nome do Aluno 1]`, `[Nome do Aluno 2]`, `[Nome do Aluno 3]`
     e `[Data da entrega]`
   - seção 6: divisão de contribuições pela taxonomia CRediT
4. **Dar acesso da professora ao repositório** — ele é **privado**, então sem
   isso o link no Moodle não abre para ela. Procedimento na seção "Dar acesso
   à professora", logo abaixo. **Não esqueçam desta.**
5. **Entregar o link no Moodle.**

### Pendência menor (não bloqueia entrega)

- Confirmar com a professora se `hex_to_sseg.vhd` tem versão oficial dela
  diferente da transcrição que fizemos do livro (pendente desde a sessão 03).

### Como rodar as coisas (referência rápida)

```bash
cd sim
./run_sim.sh                 # Etapa 1 -- 4 casos, somador direto
./run_sim_etapa2.sh          # Etapa 2 -- 5 casos, circuito da placa
./run_sim_equivalencia.sh    # equivalência livro x DE10-Lite (4096 casos)
gtkwave fp_adder_test.ghw    # ver as ondas da Etapa 2
```

No Questa (aberto pelo Quartus em `Tools → Run Simulation Tool → RTL
Simulation`), no prompt `Questa>`:
```tcl
do <caminho-do-projeto>/sim/run_questa.do
```

> ⚠️ **Não rode o `fp_adder_equiv_tb` no Questa gráfico** — ele termina com
> `finish`, que fecha o simulador. Esse teste roda no GHDL.

> 💡 Se rodar do pen drive num Linux, o bit de execução dos `.sh` se perde
> (FAT não guarda permissão). Se der *"Permission denied"*:
> `chmod +x sim/*.sh salvar.sh`

---

## 📇 Dados fixos do projeto (podem ficar salvos, não são segredo)

| Item | Valor |
|---|---|
| Usuário GitHub | `LeticiaMartins` |
| Repositório | `somador-ponto-flutuante-de10-lite` (privado) |
| URL do repo | https://github.com/LeticiaMartins/somador-ponto-flutuante-de10-lite |
| Clonar | `gh repo clone LeticiaMartins/somador-ponto-flutuante-de10-lite` |
| Identidade Git (nome) | `Leticia Martins` |
| Identidade Git (email) | `lemartins.flag@gmail.com` |
| Placa | Terasic DE10-Lite (Intel MAX 10, `10M50DAF484C7G`) |
| Software simulação | GHDL + GTKWave |
| Software síntese | Intel Quartus Prime + Questa |

---

## 👩‍🏫 Dar acesso à professora (repo é PRIVADO!)
Antes de entregar o link no Moodle, a professora precisa ser adicionada como
colaboradora, senão ela não consegue abrir o repositório:
```bash
gh repo add-collaborator LeticiaMartins/somador-ponto-flutuante-de10-lite <usuario-github-da-profa> --permission read
```
Ou pelo site: **Settings → Collaborators → Add people**.
> Descubra o usuário GitHub da professora (o do template é `victorialejandra`,
> confirme com ela se é a conta que ela usa para avaliar).

---

## 🏫 Passo a passo no computador da FACULDADE

### 1. Copiar o pen drive para o disco local
Trabalhar direto do pen drive é lento e arriscado. Copie a pasta para a Área de
Trabalho / Home antes de começar. No fim, copie de volta para o pen drive.

### 2. Verificar/instalar as ferramentas de simulação
```bash
ghdl --version      # se "command not found", instalar (ver abaixo)
gtkwave --version
```
Instalação (Ubuntu/Debian):
```bash
sudo apt update && sudo apt install -y ghdl gtkwave
```
> O **Quartus** e o **Questa** geralmente já estão instalados nos PCs do
> laboratório. Se não estiver, avise a professora.

### 3. Logar no Git/GitHub (só precisa uma vez por máquina)
```bash
gh auth login        # escolha: GitHub.com > HTTPS > login pelo navegador
```
Depois configure a identidade **só para este projeto** (não mexe na global da
máquina da faculdade):
```bash
cd caminho/para/sistemas-digitais
git config user.name  "Leticia Martins"
git config user.email "lemartins.flag@gmail.com"
```

### 4. Baixar a versão mais recente do repositório
Se você já subiu coisas de casa, puxe antes de começar:
```bash
git pull
```

### 5. Rodar a simulação (Etapa 1)
```bash
cd sim
./run_sim.sh
gtkwave fp_adder.ghw
```

### 6. Continuar com o Claude
Abra o Claude Code na pasta do projeto e faça login. Todo o histórico do que já
fizemos está no README e na pasta `ia-log/`, então dá pra retomar de onde parou.

---

## 🏠 Automatizar o Git em CASA

Para não digitar `add/commit/push` toda vez, use o script `salvar.sh` na raiz:
```bash
./salvar.sh "mensagem do que você fez"
```
Ele faz `git add -A`, `git commit` e `git push` de uma vez.

Se quiser que ele rode sem pedir senha, o `gh auth login` já configura o
credential helper do Git — depois do primeiro login não pede mais.

> ⚠️ **Cuidado com as DUAS contas do GitHub (só no PC de casa):** neste
> notebook o `gh` tem duas contas logadas — a **pessoal** (`LeticiaMartins`,
> dona deste repo) e a do **trabalho** (`leticia-pascale`). Se a conta ativa
> estiver na do trabalho, o `git push` falha com *"Repository not found"*
> (a conta do trabalho não enxerga o repo privado pessoal). O `salvar.sh` já
> troca para a conta certa automaticamente. Se precisar fazer na mão:
> ```bash
> gh auth switch --hostname github.com --user LeticiaMartins
> ```

---

## ✅ Checklist rápido ao trocar de máquina
- [ ] Copiei a pasta do pen drive para o disco local
- [ ] `git pull` antes de começar
- [ ] Configurei `git config user.name/email` (se for máquina nova)
- [ ] Ao terminar: `./salvar.sh "..."` e copiei a pasta de volta pro pen drive
