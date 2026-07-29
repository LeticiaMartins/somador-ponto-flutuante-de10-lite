#!/usr/bin/env bash
# =====================================================================
# salvar.sh  -- salva o progresso no GitHub em um comando só
# Uso:  ./salvar.sh "mensagem descrevendo o que voce fez"
# =====================================================================
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

MSG="${1:-progresso do projeto}"

# Garante que o push use a conta pessoal do GitHub (LeticiaMartins) e nao a
# conta do trabalho (leticia-pascale), que nao tem acesso a este repo privado.
# Em casa ha as duas contas configuradas no gh; na faculdade so tera uma, e o
# switch simplesmente nao faz nada. Por isso e best-effort (|| true).
if command -v gh >/dev/null 2>&1; then
    if gh auth status 2>&1 | grep -q "LeticiaMartins"; then
        gh auth switch --hostname github.com --user LeticiaMartins >/dev/null 2>&1 || true
    fi
fi

git add -A
if git diff --cached --quiet; then
    echo ">> Nada novo para salvar."
    exit 0
fi
git commit -m "$MSG"
git push
echo ">> Salvo e enviado para o GitHub!"
