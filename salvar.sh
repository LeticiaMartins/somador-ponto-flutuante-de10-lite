#!/usr/bin/env bash
# =====================================================================
# salvar.sh  -- salva o progresso no GitHub em um comando só
# Uso:  ./salvar.sh "mensagem descrevendo o que voce fez"
# =====================================================================
set -e
cd "$(dirname "${BASH_SOURCE[0]}")"

MSG="${1:-progresso do projeto}"

git add -A
if git diff --cached --quiet; then
    echo ">> Nada novo para salvar."
    exit 0
fi
git commit -m "$MSG"
git push
echo ">> Salvo e enviado para o GitHub!"
