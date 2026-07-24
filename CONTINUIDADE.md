# 🔌 CONTINUIDADE — como retomar este projeto em outra máquina

Este arquivo existe porque o projeto vai rodar em **duas máquinas**: seu
notebook (casa) e o **computador da faculdade** (via pen drive). Aqui está tudo
que você precisa para não travar lá.

> ⚠️ **Segurança:** este arquivo **NÃO** guarda senhas nem tokens. Você faz
> login do GitHub e do Claude na hora, no computador da faculdade. Guardar token
> em arquivo no pen drive é risco de segurança — não faça isso.

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

---

## ✅ Checklist rápido ao trocar de máquina
- [ ] Copiei a pasta do pen drive para o disco local
- [ ] `git pull` antes de começar
- [ ] Configurei `git config user.name/email` (se for máquina nova)
- [ ] Ao terminar: `./salvar.sh "..."` e copiei a pasta de volta pro pen drive
