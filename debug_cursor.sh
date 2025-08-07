#!/bin/bash
# Script de diagnóstico rápido para Ctrl+Shift+R

echo "🔍 DIAGNÓSTICO: Por que Ctrl+Shift+R não funciona?"
echo "================================================="
echo

# 1. Verificar se a extensão existe
echo "1️⃣ Verificando extensão Cursor..."
CURSOR_EXT_DIR="$HOME/.cursor/extensions/codespace-tunnel"
if [ -d "$CURSOR_EXT_DIR" ]; then
    echo "✅ Diretório da extensão existe: $CURSOR_EXT_DIR"
    
    if [ -f "$CURSOR_EXT_DIR/package.json" ]; then
        echo "✅ package.json encontrado"
        echo "   Versão: $(grep '"version"' "$CURSOR_EXT_DIR/package.json" 2>/dev/null || echo 'N/A')"
    else
        echo "❌ package.json NÃO encontrado"
    fi
    
    if [ -f "$CURSOR_EXT_DIR/extension.js" ]; then
        echo "✅ extension.js encontrado"
        echo "   Tamanho: $(wc -c < "$CURSOR_EXT_DIR/extension.js" 2>/dev/null || echo 'N/A') bytes"
    else
        echo "❌ extension.js NÃO encontrado"
    fi
else
    echo "❌ Extensão NÃO instalada em: $CURSOR_EXT_DIR"
    echo "💡 Solução: Executar instalador novamente"
fi

echo

# 2. Verificar bridge
echo "2️⃣ Verificando bridge local..."
BRIDGE_DIR="$HOME/cursor-codespace-bridge"
if [ -d "$BRIDGE_DIR" ]; then
    echo "✅ Bridge instalado em: $BRIDGE_DIR"
    
    # Verificar se está rodando
    if command -v netstat >/dev/null 2>&1; then
        if netstat -an 2>/dev/null | grep -q ":3001"; then
            echo "✅ Bridge rodando na porta 3001"
        else
            echo "❌ Bridge NÃO está rodando na porta 3001"
            echo "💡 Solução: $BRIDGE_DIR/start_bridge.sh"
        fi
    elif command -v ss >/dev/null 2>&1; then
        if ss -tuln 2>/dev/null | grep -q ":3001"; then
            echo "✅ Bridge rodando na porta 3001"
        else
            echo "❌ Bridge NÃO está rodando na porta 3001"
            echo "💡 Solução: $BRIDGE_DIR/start_bridge.sh"
        fi
    else
        echo "⚠️ Não foi possível verificar se bridge está rodando"
    fi
    
    # Testar conectividade
    if command -v curl >/dev/null 2>&1; then
        if curl -s -f http://localhost:3001/health >/dev/null 2>&1; then
            echo "✅ Bridge responde em http://localhost:3001"
        else
            echo "❌ Bridge não responde"
            echo "💡 Verifique se está rodando: ps aux | grep cursor_bridge"
        fi
    fi
else
    echo "❌ Bridge NÃO instalado"
    echo "💡 Solução: Executar instalador"
fi

echo

# 3. Verificar Codespace
echo "3️⃣ Verificando conectividade Codespace..."
CODESPACE_URL="https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev"
if command -v curl >/dev/null 2>&1; then
    if curl -s -I "$CODESPACE_URL" | grep -q "200\|302"; then
        echo "✅ Codespace acessível: $CODESPACE_URL"
    else
        echo "❌ Codespace não acessível"
        echo "💡 Verifique se o servidor está rodando no Codespace"
    fi
else
    echo "⚠️ curl não disponível para teste"
fi

echo

# 4. Verificar Cursor
echo "4️⃣ Verificando Cursor..."
if command -v cursor >/dev/null 2>&1; then
    echo "✅ Cursor CLI disponível"
else
    echo "⚠️ Cursor CLI não encontrado no PATH"
fi

# Verificar se há processos Cursor rodando
if pgrep -f cursor >/dev/null 2>&1; then
    echo "✅ Cursor está rodando"
    echo "   Processos: $(pgrep -c -f cursor)"
else
    echo "❌ Cursor não está rodando"
    echo "💡 Inicie o Cursor primeiro"
fi

echo

# 5. Teste funcional
echo "5️⃣ Teste funcional..."
if [ -d "$BRIDGE_DIR" ] && [ -f "$BRIDGE_DIR/codespace" ]; then
    echo "🧪 Testando comando remoto..."
    TEST_RESULT=$("$BRIDGE_DIR/codespace" run "python3 -c \"print('✅ Teste OK!')\"" 2>/dev/null)
    if echo "$TEST_RESULT" | grep -q "✅ Teste OK!"; then
        echo "✅ Comando remoto funciona!"
        echo "   Resultado: $TEST_RESULT"
    else
        echo "❌ Comando remoto falhou"
        echo "   Resultado: $TEST_RESULT"
    fi
else
    echo "⚠️ Não foi possível testar comando remoto"
fi

echo

# Resumo e soluções
echo "📋 RESUMO E SOLUÇÕES"
echo "===================="

# Contar problemas
PROBLEMS=0

if [ ! -d "$CURSOR_EXT_DIR" ] || [ ! -f "$CURSOR_EXT_DIR/package.json" ]; then
    echo "❌ PROBLEMA: Extensão não instalada corretamente"
    echo "   💡 SOLUÇÃO: curl -sSL https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.sh | bash"
    PROBLEMS=$((PROBLEMS + 1))
fi

if ! netstat -an 2>/dev/null | grep -q ":3001" && ! ss -tuln 2>/dev/null | grep -q ":3001"; then
    echo "❌ PROBLEMA: Bridge não está rodando"
    echo "   💡 SOLUÇÃO: $BRIDGE_DIR/start_bridge.sh"
    PROBLEMS=$((PROBLEMS + 1))
fi

if ! pgrep -f cursor >/dev/null 2>&1; then
    echo "❌ PROBLEMA: Cursor não está rodando"
    echo "   💡 SOLUÇÃO: Abrir Cursor IDE"
    PROBLEMS=$((PROBLEMS + 1))
fi

echo

if [ $PROBLEMS -eq 0 ]; then
    echo "🎉 TUDO PARECE OK!"
    echo
    echo "🔧 Se Ctrl+Shift+R ainda não funciona, tente:"
    echo "1. No Cursor: Ctrl+Shift+P → 'Developer: Reload Window'"
    echo "2. Ou use: Ctrl+Shift+P → 'Codespace: Execute Remote Command'"
    echo "3. Ou teste na web: http://localhost:3001"
    echo
    echo "📋 Comandos alternativos:"
    echo "   $BRIDGE_DIR/codespace run \"python3 -c 'print(\\\"Hello!\\\")'\""
    echo "   curl -X POST http://localhost:3001/execute -H 'Content-Type: application/json' -d '{\"command\": \"python3 -c \\\"print(\\\\\\\"Hello!\\\\\\\")\\\"\"}}'"
else
    echo "⚠️ $PROBLEMS problema(s) encontrado(s)"
    echo "   Corrija os problemas acima e teste novamente"
fi

echo
echo "📚 Documentação completa: TROUBLESHOOTING.md"
