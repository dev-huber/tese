#!/bin/bash

# Script para configurar e usar o túnel Codespace -> Cursor

echo "🎯 Configuração do Túnel Codespace -> Cursor"
echo "============================================"
echo ""

# Informações do ambiente
CODESPACE_URL="https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev"
BRIDGE_PORT="3001"

echo "📋 Informações do túnel:"
echo "   Codespace: $CODESPACE_URL"
echo "   Bridge local: http://localhost:$BRIDGE_PORT"
echo ""

# Função para testar conectividade
test_connection() {
    echo "🔍 Testando conectividade..."
    
    # Testar servidor do Codespace
    if curl -s "$CODESPACE_URL" > /dev/null; then
        echo "   ✅ Servidor Codespace: OK"
    else
        echo "   ❌ Servidor Codespace: FALHA"
        echo "   💡 Execute: python3 dev_server.py no Codespace"
        return 1
    fi
    
    # Testar se o Node.js está disponível
    if command -v node &> /dev/null; then
        echo "   ✅ Node.js: $(node --version)"
    else
        echo "   ❌ Node.js não encontrado"
        echo "   💡 Instale Node.js: https://nodejs.org"
        return 1
    fi
    
    return 0
}

# Função para iniciar o bridge
start_bridge() {
    local local_path="${1:-$(pwd)}"
    
    echo "🚀 Iniciando bridge..."
    echo "   Diretório local: $local_path"
    
    if [ ! -f "cursor_bridge.js" ]; then
        echo "   ❌ Arquivo cursor_bridge.js não encontrado"
        echo "   💡 Execute este script do diretório /workspaces/tese"
        return 1
    fi
    
    node cursor_bridge.js "$local_path"
}

# Função para instalar extensão no Cursor
install_cursor_extension() {
    echo "📦 Instalando extensão no Cursor..."
    
    local extension_dir="$HOME/.cursor/extensions/codespace-tunnel"
    
    # Criar diretório da extensão
    mkdir -p "$extension_dir"
    
    # Copiar arquivos
    cp cursor-extension/package.json "$extension_dir/"
    cp cursor-extension/extension.js "$extension_dir/"
    
    echo "   ✅ Extensão copiada para: $extension_dir"
    echo "   💡 Reinicie o Cursor para ativar a extensão"
}

# Função para mostrar exemplos de uso
show_examples() {
    echo "📚 Exemplos de uso:"
    echo ""
    
    echo "1. 🐍 Executar Python no Codespace:"
    echo "   curl -X POST http://localhost:$BRIDGE_PORT/execute-remote \\"
    echo "     -H 'Content-Type: application/json' \\"
    echo "     -d '{\"command\": \"python3 -c \\\"import sys; print(sys.version)\\\"\"}'"
    echo ""
    
    echo "2. 📁 Sincronizar arquivo para Codespace:"
    echo "   curl -X POST http://localhost:$BRIDGE_PORT/sync-to-remote \\"
    echo "     -H 'Content-Type: application/json' \\"
    echo "     -d '{\"path\": \"test.py\", \"content\": \"print(\\\"Hello World!\\\")\"}'"
    echo ""
    
    echo "3. 🔄 Sincronizar arquivo local para Codespace:"
    echo "   curl -X POST http://localhost:$BRIDGE_PORT/sync-from-local \\"
    echo "     -H 'Content-Type: application/json' \\"
    echo "     -d '{\"path\": \"meu_arquivo.py\"}'"
    echo ""
    
    echo "4. 💻 Executar comando local:"
    echo "   curl -X POST http://localhost:$BRIDGE_PORT/execute-local \\"
    echo "     -H 'Content-Type: application/json' \\"
    echo "     -d '{\"command\": \"ls -la\"}'"
    echo ""
}

# Função para mostrar configuração do Cursor
show_cursor_config() {
    echo "⚙️  Configuração do Cursor:"
    echo ""
    
    echo "1. Abra o Cursor"
    echo "2. Vá em File > Preferences > Settings"
    echo "3. Procure por 'Codespace Tunnel'"
    echo "4. Configure:"
    echo "   - URL: $CODESPACE_URL"
    echo "   - Auto Sync: true (opcional)"
    echo ""
    
    echo "5. Atalhos de teclado:"
    echo "   - Ctrl+Shift+R: Executar comando no Codespace"
    echo "   - Ctrl+Shift+S: Sincronizar arquivo atual"
    echo ""
}

# Menu principal
case "${1:-menu}" in
    "test")
        test_connection
        ;;
    "bridge")
        test_connection && start_bridge "$2"
        ;;
    "install")
        install_cursor_extension
        ;;
    "examples")
        show_examples
        ;;
    "config")
        show_cursor_config
        ;;
    "menu"|*)
        echo "📋 Opções disponíveis:"
        echo ""
        echo "   $0 test      - Testar conectividade"
        echo "   $0 bridge    - Iniciar bridge (opcional: caminho local)"
        echo "   $0 install   - Instalar extensão no Cursor"
        echo "   $0 examples  - Mostrar exemplos de uso"
        echo "   $0 config    - Mostrar configuração do Cursor"
        echo ""
        echo "💡 Fluxo recomendado:"
        echo "   1. $0 test"
        echo "   2. $0 install"
        echo "   3. $0 bridge /caminho/do/projeto/local"
        echo "   4. Configurar Cursor conforme: $0 config"
        ;;
esac
