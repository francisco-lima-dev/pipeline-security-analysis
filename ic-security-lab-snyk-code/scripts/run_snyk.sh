#!/bin/bash

set -e

REPOS_FILE="/workspace/repos.txt"

if [ ! -s "$REPOS_FILE" ]; then
    echo "Erro: $REPOS_FILE não encontrado ou está vazio"
    exit 1
fi

if [ -z "$SNYK_TOKEN" ]; then
    echo "Erro: SNYK_TOKEN não definido. Passe via 'docker run -e SNYK_TOKEN=...'"
    exit 1
fi

mkdir -p /workspace/results_sarif
mkdir -p /workspace/results_json
mkdir -p /workspace/treated_results

while IFS= read -r REPO_URL || [ -n "$REPO_URL" ]; do
    [ -z "$REPO_URL" ] && continue

    REPO_NAME=$(basename "$REPO_URL" .git)

    echo "=============================="
    echo "Clonando repositório: $REPO_NAME"
    echo "=============================="

    cd /workspace

    if ! git clone "$REPO_URL" "$REPO_NAME"; then
        echo "Erro ao clonar $REPO_URL — pulando para o próximo"
        continue
    fi

    cd "/workspace/$REPO_NAME"

    echo "=============================="
    echo "Executando Snyk Code..."
    echo "=============================="

    snyk code test \
        --sarif-file-output="/workspace/results_sarif/$REPO_NAME.sarif" \
        --json-file-output="/workspace/results_json/$REPO_NAME.json" \
        || true

    if [ ! -s "/workspace/results_json/$REPO_NAME.json" ]; then
        echo "Aviso: JSON não gerado para $REPO_NAME — pulando tratamento"
        cd /workspace
        rm -rf "/workspace/$REPO_NAME"
        continue
    fi

    echo "=============================="
    echo "Formatando JSON..."
    echo "=============================="

    python3 -m json.tool \
        "/workspace/results_json/$REPO_NAME.json" \
        > "/workspace/treated_results/treated_$REPO_NAME.json"

    echo "=============================="
    echo "Limpando arquivos temporários..."
    echo "=============================="

    cd /workspace
    rm -rf "/workspace/$REPO_NAME"

    echo "=============================="
    echo "Análise concluída: $REPO_NAME"
    echo "=============================="

    echo "SARIF:           /workspace/results_sarif/$REPO_NAME.sarif"
    echo "JSON:            /workspace/results_json/$REPO_NAME.json"
    echo "JSON FORMATADO:  /workspace/treated_results/treated_$REPO_NAME.json"

done < "$REPOS_FILE"
