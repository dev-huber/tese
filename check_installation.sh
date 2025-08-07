#!/bin/bash
# Script de verificação pós-instalação do túnel Cursor-Codespace

echo "🔍 Verificação Pós-Instalação - Cursor-Codespace Túnel"
echo "======================================================="
echo

# Detectar SO
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    IS_WINDOWS=true
    INSTALL_DIR="$USERPROFILE/cursor-codespace-bridge"
    CURSOR_EXT_DIR="$USERPROFILE/.cursor/extensions/codespace-tunnel"
else
    IS_WINDOWS=false
    INSTALL_DIR="$HOME/cursor-codespace-bridge"
    CURSOR_EXT_DIR="$HOME/.cursor/extensions/codespace-tunnel"
fi

# Função para verificar arquivos
check_file() {
    if [ -f "$1" ]; then
        echo "✅ $2"
        return 0
    else
        echo "❌ $2 - FALTANDO: $1"
        return 1
    fi
}

# Função para verificar diretórios
check_dir() {
    if [ -d "$1" ]; then
        echo "✅ $2"
        return 0
    else
        echo "❌ $2 - FALTANDO: $1"
        return 1
    fi
}

# Função para verificar comandos
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        VERSION=$($1 --version 2>/dev/null | head -n1)
        echo "✅ $2: $VERSION"
        return 0
    else
        echo "❌ $2 - NÃO ENCONTRADO"
        return 1
    fi
}

# Função para verificar conectividade
check_connectivity() {
    echo "🌐 Testando conectividade..."
    
    if command -v curl >/dev/null 2>&1; then
        if curl -s -I "$1" | grep -q "200\|302"; then
            echo "✅ Codespace acessível: $1"
            return 0
        else
            echo "❌ Codespace não acessível: $1"
            return 1
        fi
    else
        echo "⚠️ curl não disponível para teste"
        return 1
    fi
}

# Verificar pré-requisitos
echo "📋 Verificando pré-requisitos..."
PREREQ_OK=true

if ! check_command "node" "Node.js"; then
    PREREQ_OK=false
fi

if ! check_command "npm" "NPM"; then
    PREREQ_OK=false
fi

if ! check_command "curl" "cURL"; then
    PREREQ_OK=false
fi

echo

# Verificar instalação do bridge
echo "📦 Verificando instalação do bridge..."
BRIDGE_OK=true

if ! check_dir "$INSTALL_DIR" "Diretório de instalação"; then
    BRIDGE_OK=false
fi

if ! check_file "$INSTALL_DIR/cursor_bridge.js" "Bridge principal"; then
    BRIDGE_OK=false
fi

if $IS_WINDOWS; then
    if ! check_file "$INSTALL_DIR/start_bridge.bat" "Script de inicialização"; then
        BRIDGE_OK=false
    fi
    if ! check_file "$INSTALL_DIR/codespace.bat" "Script de comando"; then
        BRIDGE_OK=false
    fi
else
    if ! check_file "$INSTALL_DIR/start_bridge.sh" "Script de inicialização"; then
        BRIDGE_OK=false
    fi
    if ! check_file "$INSTALL_DIR/codespace" "Script de comando"; then
        BRIDGE_OK=false
    fi
fi

echo

# Verificar extensão Cursor
echo "🔌 Verificando extensão Cursor..."
EXTENSION_OK=true

if ! check_dir "$CURSOR_EXT_DIR" "Diretório da extensão"; then
    EXTENSION_OK=false
fi

if ! check_file "$CURSOR_EXT_DIR/package.json" "Manifesto da extensão"; then
    EXTENSION_OK=false
fi

if ! check_file "$CURSOR_EXT_DIR/extension.js" "Código da extensão"; then
    EXTENSION_OK=false
fi

echo

# Testar conectividade
CODESPACE_URL="https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev"
CONNECTIVITY_OK=true

if ! check_connectivity "$CODESPACE_URL"; then
    CONNECTIVITY_OK=false
fi

echo

# Testar bridge local
echo "🔗 Testando bridge local..."
BRIDGE_RUNNING=false

if command -v netstat >/dev/null 2>&1; then
    if netstat -an 2>/dev/null | grep -q ":3001"; then
        echo "✅ Bridge rodando na porta 3001"
        BRIDGE_RUNNING=true
    else
        echo "⚠️ Bridge não está rodando na porta 3001"
    fi
elif command -v ss >/dev/null 2>&1; then
    if ss -tuln 2>/dev/null | grep -q ":3001"; then
        echo "✅ Bridge rodando na porta 3001"
        BRIDGE_RUNNING=true
    else
        echo "⚠️ Bridge não está rodando na porta 3001"
    fi
else
    echo "⚠️ Não foi possível verificar se o bridge está rodando"
fi

echo

# Teste funcional básico
echo "🧪 Teste funcional básico..."
if $BRIDGE_OK && $CONNECTIVITY_OK; then
    echo "🚀 Executando teste remoto..."
    
    if $IS_WINDOWS; then
        TEST_RESULT=$("$INSTALL_DIR/codespace.bat" run "python -c \"print('✅ Teste OK!')\"" 2>/dev/null)
    else
        TEST_RESULT=$("$INSTALL_DIR/codespace" run "python -c \"print('✅ Teste OK!')\"" 2>/dev/null)
    fi
    
    if echo "$TEST_RESULT" | grep -q "✅ Teste OK!"; then
        echo "✅ Teste funcional passou!"
    else
        echo "❌ Teste funcional falhou"
        echo "Resultado: $TEST_RESULT"
    fi
else
    echo "⚠️ Pulando teste funcional (pré-requisitos não atendidos)"
fi

echo

# Resumo final
echo "📊 RESUMO DA VERIFICAÇÃO"
echo "========================"
echo

if $PREREQ_OK; then
    echo "✅ Pré-requisitos: OK"
else
    echo "❌ Pré-requisitos: FALHA"
fi

if $BRIDGE_OK; then
    echo "✅ Bridge instalado: OK"
else
    echo "❌ Bridge instalado: FALHA"
fi

if $EXTENSION_OK; then
    echo "✅ Extensão Cursor: OK"
else
    echo "❌ Extensão Cursor: FALHA"
fi

if $CONNECTIVITY_OK; then
    echo "✅ Conectividade: OK"
else
    echo "❌ Conectividade: FALHA"
fi

echo

# Instruções baseadas no resultado
if $PREREQ_OK && $BRIDGE_OK && $EXTENSION_OK && $CONNECTIVITY_OK; then
    echo "🎉 INSTALAÇÃO COMPLETA E FUNCIONAL!"
    echo
    echo "🚀 Próximos passos:"
    echo "1. Iniciar bridge:"
    if $IS_WINDOWS; then
        echo "   $INSTALL_DIR\\start_bridge.bat"
    else
        echo "   $INSTALL_DIR/start_bridge.sh"
    fi
    echo
    echo "2. Abrir Cursor e usar:"
    echo "   - Ctrl+Shift+R: Executar comando remoto"
    echo "   - Ctrl+Shift+S: Sincronizar arquivo"
    echo
    echo "3. Teste via terminal:"
    if $IS_WINDOWS; then
        echo "   $INSTALL_DIR\\codespace.bat run \"python -c 'print(\\\"Hello from Codespace!\\\")'\""
    else
        echo "   $INSTALL_DIR/codespace run \"python -c 'print(\\\"Hello from Codespace!\\\")'\""
    fi
    echo
    echo "📚 Documentação completa: CURSOR_SETUP.md"
    
else
    echo "⚠️ INSTALAÇÃO INCOMPLETA"
    echo
    echo "🔧 Ações necessárias:"
    
    if ! $PREREQ_OK; then
        echo "- Instalar pré-requisitos (Node.js, npm, curl)"
    fi
    
    if ! $BRIDGE_OK; then
        echo "- Reinstalar bridge (executar script de instalação)"
    fi
    
    if ! $EXTENSION_OK; then
        echo "- Reinstalar extensão Cursor"
    fi
    
    if ! $CONNECTIVITY_OK; then
        echo "- Verificar se o servidor Codespace está rodando"
        echo "- Executar: python dev_server.py no Codespace"
    fi
    
    echo
    echo "💡 Execute o script de instalação novamente ou consulte CURSOR_SETUP.md"
fi

echo
