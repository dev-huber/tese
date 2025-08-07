# 🔧 Troubleshooting: Ctrl+Shift+R não funciona

## 🔍 Diagnóstico Passo a Passo

### 1. **Verificar se a extensão está instalada**

#### Opção A: Via Command Palette
1. No Cursor: `Ctrl+Shift+P`
2. Digite: `Extensions: Show Installed Extensions`
3. Procure por: **"Codespace Tunnel"**

#### Opção B: Via arquivo
**Windows:**
```cmd
dir %USERPROFILE%\.cursor\extensions\codespace-tunnel
```

**Linux/Mac:**
```bash
ls -la ~/.cursor/extensions/codespace-tunnel
```

### 2. **Verificar se a extensão está ativada**

1. `Ctrl+Shift+P`
2. Digite: `Developer: Reload Window`
3. Aguarde o Cursor reiniciar

### 3. **Verificar se os comandos estão disponíveis**

1. `Ctrl+Shift+P`
2. Digite: **"execute remote"** ou **"codespace"**
3. Deve aparecer:
   - `Codespace: Execute Remote Command`
   - `Codespace: Sync File to Codespace`

### 4. **Testar comando manualmente**

Se `Ctrl+Shift+R` não funciona, tente:
1. `Ctrl+Shift+P`
2. Digite: `Codespace: Execute Remote Command`
3. Digite seu código Python

### 5. **Verificar bridge local**

```bash
# Verificar se está rodando
netstat -an | grep 3001    # Linux/Mac
netstat -an | findstr 3001 # Windows

# Se não estiver, iniciar:
~/cursor-codespace-bridge/start_bridge.sh      # Linux/Mac
%USERPROFILE%\cursor-codespace-bridge\start_bridge.bat  # Windows
```

## 🛠️ Soluções por Problema

### **Problema 1: Extensão não instalada**

#### Reinstalar extensão:
```bash
# Remover extensão existente
rm -rf ~/.cursor/extensions/codespace-tunnel  # Linux/Mac
rmdir /s %USERPROFILE%\.cursor\extensions\codespace-tunnel  # Windows

# Reinstalar
curl -sSL https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.sh | bash  # Linux/Mac
# ou executar install_cursor_tunnel.bat novamente no Windows
```

### **Problema 2: Conflito de atalhos**

#### Verificar conflitos:
1. `Ctrl+Shift+P`
2. `Preferences: Open Keyboard Shortcuts`
3. Procurar por `Ctrl+Shift+R`
4. Se houver conflito, remover ou alterar

#### Criar atalho customizado:
1. `Ctrl+Shift+P`
2. `Preferences: Open Keyboard Shortcuts (JSON)`
3. Adicionar:
```json
[
    {
        "key": "ctrl+shift+r",
        "command": "codespace.executeRemote",
        "when": "editorTextFocus"
    },
    {
        "key": "ctrl+shift+s",
        "command": "codespace.syncFile",
        "when": "editorTextFocus"
    }
]
```

### **Problema 3: Extensão com erro**

#### Verificar logs de erro:
1. `Ctrl+Shift+P`
2. `Developer: Toggle Developer Tools`
3. Aba **Console**
4. Procurar erros relacionados a "codespace"

#### Recriar extensão manualmente:
```bash
# Criar diretório
mkdir -p ~/.cursor/extensions/codespace-tunnel  # Linux/Mac
mkdir %USERPROFILE%\.cursor\extensions\codespace-tunnel  # Windows

# Baixar arquivos
curl -o ~/.cursor/extensions/codespace-tunnel/package.json \
  https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/package.json

curl -o ~/.cursor/extensions/codespace-tunnel/extension.js \
  https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/extension.js
```

### **Problema 4: Bridge não conecta**

#### Testar conectividade:
```bash
# Testar bridge local
curl http://localhost:3001/health

# Testar Codespace
curl https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev/status
```

#### Reiniciar bridge:
```bash
# Parar bridge atual
pkill -f cursor_bridge  # Linux/Mac
taskkill /F /IM node.exe  # Windows (cuidado, mata todos node)

# Iniciar novamente
cd ~/cursor-codespace-bridge && node cursor_bridge.js  # Linux/Mac
cd %USERPROFILE%\cursor-codespace-bridge && node cursor_bridge.js  # Windows
```

## 🧪 Teste Completo

### **Script de Teste Automático:**

**Windows:**
```cmd
@echo off
echo 🔍 Testando Cursor-Codespace...

echo 1. Verificando extensão...
if exist "%USERPROFILE%\.cursor\extensions\codespace-tunnel\package.json" (
    echo ✅ Extensão instalada
) else (
    echo ❌ Extensão NÃO instalada
    echo Execute: install_cursor_tunnel.bat
    goto end
)

echo 2. Testando bridge...
netstat -an | findstr :3001 >nul
if %errorlevel% equ 0 (
    echo ✅ Bridge rodando
) else (
    echo ❌ Bridge NÃO rodando
    echo Execute: %USERPROFILE%\cursor-codespace-bridge\start_bridge.bat
    goto end
)

echo 3. Testando conectividade...
curl -s http://localhost:3001/health >nul
if %errorlevel% equ 0 (
    echo ✅ Bridge acessível
) else (
    echo ❌ Bridge não responde
)

:end
pause
```

**Linux/Mac:**
```bash
#!/bin/bash
echo "🔍 Testando Cursor-Codespace..."

echo "1. Verificando extensão..."
if [ -f ~/.cursor/extensions/codespace-tunnel/package.json ]; then
    echo "✅ Extensão instalada"
else
    echo "❌ Extensão NÃO instalada"
    echo "Execute: curl -sSL https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.sh | bash"
    exit 1
fi

echo "2. Testando bridge..."
if netstat -an | grep -q :3001; then
    echo "✅ Bridge rodando"
else
    echo "❌ Bridge NÃO rodando"
    echo "Execute: ~/cursor-codespace-bridge/start_bridge.sh"
    exit 1
fi

echo "3. Testando conectividade..."
if curl -s http://localhost:3001/health > /dev/null; then
    echo "✅ Bridge acessível"
else
    echo "❌ Bridge não responde"
fi
```

## 🎯 Soluções Alternativas

### **Se Ctrl+Shift+R não funcionar, use:**

#### **1. Command Palette:**
1. `Ctrl+Shift+P`
2. Digite: `Codespace: Execute Remote Command`
3. Cole seu código

#### **2. Terminal integrado:**
```bash
codespace run "python -c 'print(\"Hello!\")'"
```

#### **3. Interface web:**
1. Abrir: http://localhost:3001
2. Colar código no campo
3. Clicar "Execute"

#### **4. API direta:**
```bash
curl -X POST http://localhost:3001/execute \
  -H "Content-Type: application/json" \
  -d '{"command": "python -c \"print(\\\"Hello!\\\")\""}'
```

## 🔄 Reset Completo

### **Se nada funcionar, reset total:**

```bash
# 1. Remover tudo
rm -rf ~/.cursor/extensions/codespace-tunnel  # Linux/Mac
rmdir /s %USERPROFILE%\.cursor\extensions\codespace-tunnel  # Windows

rm -rf ~/cursor-codespace-bridge  # Linux/Mac
rmdir /s %USERPROFILE%\cursor-codespace-bridge  # Windows

# 2. Reinstalar do zero
curl -sSL https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.sh | bash  # Linux/Mac
# ou executar install_cursor_tunnel.bat no Windows

# 3. Reiniciar Cursor completamente
```

## 📞 Debug Avançado

### **Verificar logs detalhados:**

1. No bridge (terminal onde rodou start_bridge):
   - Verificar mensagens de erro
   - Verificar se porta 3001 está livre

2. No Cursor (Developer Tools):
   ```javascript
   // No console do Cursor
   console.log("Testando extensão...");
   ```

3. Testar comando direto:
   ```bash
   node ~/cursor-codespace-bridge/cursor_bridge.js
   ```

---

**Execute este diagnóstico e me diga qual passo falhou!** 🔍
