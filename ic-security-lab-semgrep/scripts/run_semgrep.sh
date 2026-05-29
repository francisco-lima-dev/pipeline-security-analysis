#!/bin/bash

set -e

REPOS_FILE="/workspace/repos.txt"

if [ ! -f "$REPOS_FILE" ]; then
    echo "Erro: Arquivo $REPOS_FILE não encontrado"
    echo "Uso: Crie o arquivo $REPOS_FILE com uma URL de repositório por linha"
    exit 1
fi

while IFS= read -r REPO_URL || [ -n "$REPO_URL" ]; do
    [ -z "$REPO_URL" ] && continue

    echo "Clonando repositório..."
    REPO_NAME=$(basename $REPO_URL)
    git clone "${REPO_URL}" $REPO_NAME

    mkdir -p /workspace/results_json


    cd $REPO_NAME

    echo "Rodando Semgrep..."
    semgrep scan --config=auto --json --output /workspace/results_json/$REPO_NAME.json

    mkdir -p /workspace/treated_results

    cat /workspace/results_json/$REPO_NAME.json | python3 -m json.tool>/workspace/treated_results/treated_$REPO_NAME.json

    echo "Removendo repositório clonado..."

    cd /workspace

    rm -rf /workspace/$REPO_NAME

    echo "Análise finalizada!"

done < "$REPOS_FILE"