#!/bin/bash

# Script para instalar e configurar o túnel Cursor -> Codespace na máquina local
# Execute: curl -sSL https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.sh | bash

echo "🎯 Instalador do Túnel Cursor -> Codespace"
echo "=========================================="
echo ""

# Verificar pré-requisitos
check_prerequisites() {
    echo "🔍 Verificando pré-requisitos..."
    
    # Verificar Node.js
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        echo "   ✅ Node.js: $NODE_VERSION"
    else
        echo "   ❌ Node.js não encontrado"
        echo "   💡 Instale Node.js: https://nodejs.org"
        echo "   💡 Ou use o gerenciador de pacotes:"
        echo "      - macOS: brew install node"
        echo "      - Ubuntu/Debian: sudo apt install nodejs npm"
        echo "      - CentOS/RHEL: sudo yum install nodejs npm"
        return 1
    fi
    
    # Verificar curl
    if command -v curl &> /dev/null; then
        echo "   ✅ curl: disponível"
    else
        echo "   ❌ curl não encontrado"
        echo "   💡 Instale curl primeiro"
        return 1
    fi
    
    # Verificar conectividade com Codespace
    echo "   🌐 Testando conectividade com Codespace..."
    if curl -s -I "https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev" | grep -q "HTTP/[12]"; then
        echo "   ✅ Codespace: acessível"
    else
        echo "   ❌ Codespace não acessível"
        echo "   💡 Verifique se o servidor está rodando no Codespace"
        return 1
    fi
    
    return 0
}

# Instalar bridge local
install_bridge() {
    echo "📦 Instalando bridge local..."
    
    # Criar diretório
    INSTALL_DIR="$HOME/cursor-codespace-bridge"
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Baixar arquivos
    echo "   📥 Baixando cursor_bridge.js..."
    curl -sSL -o cursor_bridge.js "https://raw.githubusercontent.com/dev-huber/tese/main/cursor_bridge.js"
    
    echo "   📥 Baixando scripts auxiliares..."
    curl -sSL -o use_tunnel.sh "https://raw.githubusercontent.com/dev-huber/tese/main/use_tunnel.sh"
    chmod +x use_tunnel.sh
    
    # Criar script de inicialização
    cat > start_bridge.sh << 'EOF'
#!/bin/bash

BRIDGE_DIR="$HOME/cursor-codespace-bridge"
PROJECT_DIR="${1:-$(pwd)}"

echo "🚀 Iniciando Cursor-Codespace Bridge..."
echo "   Bridge: $BRIDGE_DIR"
echo "   Projeto: $PROJECT_DIR"
echo ""

cd "$BRIDGE_DIR"
node cursor_bridge.js "$PROJECT_DIR"
EOF

    chmod +x start_bridge.sh
    
    echo "   ✅ Bridge instalado em: $INSTALL_DIR"
    return 0
}

# Instalar extensão Cursor
install_cursor_extension() {
    echo "🔌 Instalando extensão Cursor..."
    
    # Detectar diretório do Cursor
    CURSOR_EXTENSIONS_DIR=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        CURSOR_EXTENSIONS_DIR="$HOME/.cursor/extensions"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        CURSOR_EXTENSIONS_DIR="$HOME/.cursor/extensions"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        # Windows (Git Bash)
        CURSOR_EXTENSIONS_DIR="$APPDATA/.cursor/extensions"
    else
        echo "   ⚠️ Sistema operacional não detectado, usando padrão Linux"
        CURSOR_EXTENSIONS_DIR="$HOME/.cursor/extensions"
    fi
    
    # Criar diretório da extensão
    EXT_DIR="$CURSOR_EXTENSIONS_DIR/codespace-tunnel"
    mkdir -p "$EXT_DIR"
    
    # Baixar arquivos da extensão
    echo "   📥 Baixando package.json..."
    curl -sSL -o "$EXT_DIR/package.json" "https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/package.json"
    
    echo "   📥 Baixando extension.js..."
    curl -sSL -o "$EXT_DIR/extension.js" "https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/extension.js"
    
    echo "   ✅ Extensão instalada em: $EXT_DIR"
    echo "   💡 Reinicie o Cursor para ativar a extensão"
    return 0
}

# Criar scripts de automação
create_automation_scripts() {
    echo "🤖 Criando scripts de automação..."
    
    SCRIPT_DIR="$HOME/cursor-codespace-bridge"
    
    # Script para executar comandos remotos
    cat > "$SCRIPT_DIR/remote.sh" << 'EOF'
#!/bin/bash

CODESPACE_URL="https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev"

case "$1" in
    "run"|"exec")
        if [ -z "$2" ]; then
            echo "❌ Uso: $0 run 'comando'"
            echo "Exemplo: $0 run 'python3 script.py'"
            exit 1
        fi
        
        echo "🚀 Executando no Codespace: $2"
        curl -X POST "$CODESPACE_URL/execute" \
            -H "Content-Type: application/json" \
            -d "{\"command\": \"$2\"}" | jq .
        ;;
        
    "sync")
        if [ -z "$2" ] || [ ! -f "$2" ]; then
            echo "❌ Uso: $0 sync <arquivo>"
            echo "Exemplo: $0 sync script.py"
            exit 1
        fi
        
        echo "🔄 Sincronizando: $2"
        CONTENT=$(cat "$2" | jq -Rs .)
        curl -X POST "$CODESPACE_URL/sync" \
            -H "Content-Type: application/json" \
            -d "{\"path\": \"$2\", \"content\": $CONTENT}" | jq .
        ;;
        
    "status")
        echo "📊 Status do Codespace:"
        curl -s "$CODESPACE_URL" && echo "✅ Servidor online" || echo "❌ Servidor offline"
        ;;
        
    *)
        echo "🎯 Cursor-Codespace Remote Control"
        echo ""
        echo "Comandos disponíveis:"
        echo "  $0 run 'comando'    # Executar comando no Codespace"
        echo "  $0 sync arquivo     # Sincronizar arquivo para Codespace"
        echo "  $0 status           # Verificar status do Codespace"
        echo ""
        echo "Exemplos:"
        echo "  $0 run 'python3 -c \"print(\\\"Hello!\\\")\"'"
        echo "  $0 run 'pip install requests'"
        echo "  $0 sync meu_script.py"
        ;;
esac
EOF

    chmod +x "$SCRIPT_DIR/remote.sh"
    
    # Criar alias para facilitar uso
    echo "📝 Configurando aliases..."
    
    SHELL_RC=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_RC="$HOME/.bashrc"
    fi
    
    if [ -n "$SHELL_RC" ] && [ -f "$SHELL_RC" ]; then
        if ! grep -q "cursor-codespace-bridge" "$SHELL_RC"; then
            echo "" >> "$SHELL_RC"
            echo "# Cursor-Codespace Bridge aliases" >> "$SHELL_RC"
            echo "alias codespace='$SCRIPT_DIR/remote.sh'" >> "$SHELL_RC"
            echo "alias csr='$SCRIPT_DIR/remote.sh run'" >> "$SHELL_RC"
            echo "alias css='$SCRIPT_DIR/remote.sh sync'" >> "$SHELL_RC"
            echo "   ✅ Aliases adicionados a $SHELL_RC"
            echo "   💡 Execute: source $SHELL_RC (ou abra novo terminal)"
        else
            echo "   ℹ️ Aliases já existem em $SHELL_RC"
        fi
    fi
    
    return 0
}

# Mostrar instruções finais
show_final_instructions() {
    echo ""
    echo "🎉 Instalação concluída com sucesso!"
    echo "=================================="
    echo ""
    echo "📋 O que foi instalado:"
    echo "   ✅ Bridge local em: $HOME/cursor-codespace-bridge"
    echo "   ✅ Extensão Cursor"
    echo "   ✅ Scripts de automação"
    echo "   ✅ Aliases de linha de comando"
    echo ""
    echo "🚀 Como usar:"
    echo ""
    echo "1. 🌉 Bridge Local (Recomendado):"
    echo "   cd seu-projeto"
    echo "   ~/cursor-codespace-bridge/start_bridge.sh"
    echo ""
    echo "2. 🎮 Linha de comando (após reiniciar terminal):"
    echo "   codespace run 'python3 script.py'"
    echo "   codespace sync arquivo.py"
    echo "   codespace status"
    echo ""
    echo "3. 🔌 Extensão Cursor:"
    echo "   - Reinicie o Cursor"
    echo "   - Ctrl+Shift+R: Executar comando"
    echo "   - Ctrl+Shift+S: Sincronizar arquivo"
    echo ""
    echo "🔧 Configuração da extensão:"
    echo "   - Abra Cursor > Settings"
    echo "   - Procure 'Codespace Tunnel'"
    echo "   - URL: https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev"
    echo ""
    echo "📚 Documentação completa em:"
    echo "   ~/cursor-codespace-bridge/use_tunnel.sh help"
    echo ""
    echo "✨ Teste rápido:"
    echo "   ~/cursor-codespace-bridge/remote.sh run 'python3 -c \"print(\\\"Hello from Codespace!\\\")\"'"
}

# Função principal
main() {
    if ! check_prerequisites; then
        echo ""
        echo "❌ Pré-requisitos não atendidos. Instale as dependências e tente novamente."
        exit 1
    fi
    
    echo ""
    
    if ! install_bridge; then
        echo "❌ Falha ao instalar bridge"
        exit 1
    fi
    
    echo ""
    
    if ! install_cursor_extension; then
        echo "❌ Falha ao instalar extensão Cursor"
        exit 1
    fi
    
    echo ""
    
    if ! create_automation_scripts; then
        echo "❌ Falha ao criar scripts de automação"
        exit 1
    fi
    
    show_final_instructions
}

# Executar
main "$@"
