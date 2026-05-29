#!/bin/bash

set -ex

REPOS_FILE="/workspace/repos.txt"

if [ ! -s "$REPOS_FILE" ]; then
    echo "Erro: $REPOS_FILE não encontrado ou está vazio"
    exit 1
fi

while IFS= read -r REPO_URL; do

    REPO_NAME=$(basename "$REPO_URL" .git)

    echo "=============================="
    echo "Clonando repositório..."
    echo "=============================="

    cd /workspace

    git clone "$REPO_URL" "$REPO_NAME"

    echo "=============================="
    echo "Criando diretórios..."
    echo "=============================="

    mkdir -p /workspace/results_sarif
    mkdir -p /workspace/results_json
    mkdir -p /workspace/treated_results
    mkdir -p /workspace/codeql_db

    cd "/workspace/$REPO_NAME"

    echo "=============================="
    echo "Criando database CodeQL..."
    echo "=============================="

    codeql database create \
        "/workspace/codeql_db/$REPO_NAME" \
        --language=javascript \
        --source-root=. \
        --build-mode=none

    echo "=============================="
    echo "Executando análise CodeQL..."
    echo "=============================="

    codeql database analyze \
        "/workspace/codeql_db/$REPO_NAME" \
        codeql/javascript-queries:codeql-suites/javascript-security-and-quality.qls \
        --ram=4096 \
        --format=sarif-latest \
        --output="/workspace/results_sarif/$REPO_NAME.sarif"

    echo "=============================="
    echo "Convertendo SARIF para JSON..."
    echo "=============================="

    python3 /scripts/convert_sarif.py \
        "/workspace/results_sarif/$REPO_NAME.sarif" \
        "/workspace/results_json/$REPO_NAME.json"

    echo "=============================="
    echo "Formatando JSON..."
    echo "=============================="

    python3 -m json.tool \
        "/workspace/results_json/$REPO_NAME.json" \
        > "/workspace/treated_results/treated_$REPO_NAME.json"


    echo "=============================="
    echo "Limpando arquivos temporários..."
    echo "=============================="

    rm -rf "/workspace/$REPO_NAME"

    rm -rf "/workspace/codeql_db/$REPO_NAME"

    echo "=============================="
    echo "Análise concluída com sucesso!"
    echo "=============================="

    echo "SARIF:"
    echo "/workspace/results_sarif/$REPO_NAME.sarif"

    echo "JSON:"
    echo "/workspace/results_json/$REPO_NAME.json"

    echo "JSON FORMATADO:"
    echo "/workspace/treated_results/treated_$REPO_NAME.json"

done < "$REPOS_FILE"