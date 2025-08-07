#!/bin/bash

# Script de sincronização bidirecional
LOCAL_PATH="$1"
REMOTE_PATH="/workspaces/tese"

if [ -z "$LOCAL_PATH" ]; then
    echo "❌ Uso: $0 <caminho_local>"
    echo "Exemplo: $0 /home/usuario/projetos/tese"
    exit 1
fi

echo "🔄 Sincronizando arquivos..."
echo "   Local: $LOCAL_PATH"
echo "   Remote: $REMOTE_PATH"

# Sincronização do remoto para local
rsync -avz --exclude='.git' --exclude='node_modules' --exclude='*.log' \
    "$REMOTE_PATH/" "$LOCAL_PATH/"

echo "✅ Sincronização concluída!"
