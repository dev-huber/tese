# 🎯 Guia Completo: Configurar Cursor com Túnel Codespace

## 📋 Pré-requisitos na sua máquina local

1. **Node.js** instalado ([Download aqui](https://nodejs.org))
2. **Cursor** instalado ([Download aqui](https://cursor.sh))
3. **curl** ou **wget** (já vem no Windows/Mac/Linux)

## 🚀 Método 1: Bridge Local (Mais Simples)

### Passo 1: Baixar o cliente bridge

Na sua máquina local, execute:

```bash
# Criar diretório para o projeto
mkdir ~/cursor-codespace-bridge
cd ~/cursor-codespace-bridge

# Baixar o cliente bridge
curl -o cursor_bridge.js https://raw.githubusercontent.com/dev-huber/tese/main/cursor_bridge.js

# Ou se preferir wget:
# wget https://raw.githubusercontent.com/dev-huber/tese/main/cursor_bridge.js
```

### Passo 2: Executar o bridge

```bash
# Executar o bridge (substitua pelo caminho do seu projeto)
node cursor_bridge.js /caminho/para/seu/projeto/local

# Exemplo:
# node cursor_bridge.js ~/Documents/meu-projeto
# node cursor_bridge.js C:\Users\SeuUsuario\Projetos\MeuProjeto
```

Você verá algo como:
```
🌉 Cursor-Codespace Bridge
   Codespace: https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
   Local: /caminho/para/seu/projeto

🚀 Bridge server rodando na porta 3001
📡 Acesse: http://localhost:3001/status
```

### Passo 3: Usar no Cursor

Agora você pode usar o Cursor normalmente e executar comandos remotos via:

1. **Terminal integrado do Cursor**:
```bash
# Executar Python no Codespace
curl -X POST http://localhost:3001/execute-remote \
  -H "Content-Type: application/json" \
  -d '{"command": "python3 meu_script.py"}'

# Sincronizar arquivo atual para Codespace
curl -X POST http://localhost:3001/sync-from-local \
  -H "Content-Type: application/json" \
  -d '{"path": "meu_arquivo.py"}'
```

2. **Script personalizado** (crie um arquivo `run_remote.js`):
```javascript
const http = require('http');

function executeRemote(command) {
    const postData = JSON.stringify({ command });
    
    const options = {
        hostname: 'localhost',
        port: 3001,
        path: '/execute-remote',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(postData)
        }
    };

    const req = http.request(options, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
            const result = JSON.parse(data);
            console.log('STDOUT:', result.stdout);
            if (result.stderr) console.log('STDERR:', result.stderr);
            console.log('Exit code:', result.returncode);
        });
    });

    req.write(postData);
    req.end();
}

// Uso: node run_remote.js
// Depois chame: executeRemote('python3 test.py')
```

## 🔧 Método 2: Extensão Cursor Personalizada

### Passo 1: Instalar a extensão

```bash
# Criar diretório da extensão
mkdir -p ~/.cursor/extensions/codespace-tunnel

# Baixar arquivos da extensão
curl -o ~/.cursor/extensions/codespace-tunnel/package.json \
  https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/package.json

curl -o ~/.cursor/extensions/codespace-tunnel/extension.js \
  https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/extension.js
```

### Passo 2: Reiniciar o Cursor

Feche e abra o Cursor novamente.

### Passo 3: Configurar a extensão

1. Pressione `Ctrl+,` (ou `Cmd+,` no Mac) para abrir configurações
2. Procure por "**Codespace Tunnel**"
3. Configure:
   - **URL**: `https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev`
   - **Auto Sync**: `true` (opcional)

### Passo 4: Usar os atalhos

- **Ctrl+Shift+R** (ou Cmd+Shift+R): Executar comando no Codespace
- **Ctrl+Shift+S** (ou Cmd+Shift+S): Sincronizar arquivo atual

## 🎮 Método 3: Comandos Personalizados no Cursor

### Criar tasks.json no seu projeto

No Cursor, crie `.vscode/tasks.json`:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Execute no Codespace",
            "type": "shell",
            "command": "curl",
            "args": [
                "-X", "POST",
                "https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev/execute",
                "-H", "Content-Type: application/json",
                "-d", "{\"command\": \"${input:command}\"}"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Sync Arquivo para Codespace",
            "type": "shell",
            "command": "curl",
            "args": [
                "-X", "POST",
                "https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev/sync",
                "-H", "Content-Type: application/json",
                "-d", "{\"path\": \"${relativeFile}\", \"content\": \"$(cat ${file} | sed 's/\"/\\\\\"/g' | tr '\n' '\\n')\"}"
            ],
            "group": "build"
        }
    ],
    "inputs": [
        {
            "id": "command",
            "description": "Comando para executar no Codespace",
            "default": "python3 ${relativeFile}",
            "type": "promptString"
        }
    ]
}
```

### Usar as tasks

1. Pressione `Ctrl+Shift+P` (ou Cmd+Shift+P)
2. Digite "**Tasks: Run Task**"
3. Escolha "**Execute no Codespace**" ou "**Sync Arquivo para Codespace**"

## 🔥 Método 4: Script de Automação

Crie um script `codespace.sh` (Linux/Mac) ou `codespace.bat` (Windows):

### Linux/Mac (`codespace.sh`):
```bash
#!/bin/bash

CODESPACE_URL="https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev"

case "$1" in
    "run")
        curl -X POST "$CODESPACE_URL/execute" \
            -H "Content-Type: application/json" \
            -d "{\"command\": \"$2\"}"
        ;;
    "sync")
        if [ -f "$2" ]; then
            content=$(cat "$2" | jq -Rs .)
            curl -X POST "$CODESPACE_URL/sync" \
                -H "Content-Type: application/json" \
                -d "{\"path\": \"$2\", \"content\": $content}"
        else
            echo "Arquivo não encontrado: $2"
        fi
        ;;
    *)
        echo "Uso:"
        echo "  $0 run 'python3 script.py'  # Executar comando"
        echo "  $0 sync arquivo.py           # Sincronizar arquivo"
        ;;
esac
```

### Windows (`codespace.bat`):
```batch
@echo off
set CODESPACE_URL=https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev

if "%1"=="run" (
    curl -X POST "%CODESPACE_URL%/execute" -H "Content-Type: application/json" -d "{\"command\": \"%2\"}"
) else if "%1"=="sync" (
    curl -X POST "%CODESPACE_URL%/sync" -H "Content-Type: application/json" -d "{\"path\": \"%2\", \"content\": \"$(type %2)\"}"
) else (
    echo Uso:
    echo   %0 run "python3 script.py"  # Executar comando
    echo   %0 sync arquivo.py          # Sincronizar arquivo
)
```

### Usar os scripts:
```bash
# Executar Python
./codespace.sh run "python3 meu_script.py"

# Sincronizar arquivo
./codespace.sh sync meu_arquivo.py

# No Windows:
# codespace.bat run "python3 meu_script.py"
# codespace.bat sync meu_arquivo.py
```

## ✅ Teste Rápido

Para testar se está funcionando:

```bash
# Teste direto (funciona em qualquer sistema)
curl -X POST https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev/execute \
  -H "Content-Type: application/json" \
  -d '{"command": "python3 -c \"print(\"Hello from Codespace!\")\""}'
```

Você deve ver:
```json
{
    "stdout": "Hello from Codespace!\n",
    "stderr": "",
    "returncode": 0
}
```

## 🎯 Recomendação

Para começar, use o **Método 1 (Bridge Local)** pois é:
- ✅ Mais simples de configurar
- ✅ Funciona imediatamente
- ✅ Mais flexível
- ✅ Permite automação fácil

Depois que estiver confortável, pode experimentar os outros métodos!

## 🆘 Solução de Problemas

### Se o comando curl não funcionar:
```bash
# Testar conectividade
curl -I https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev

# Deve retornar: HTTP/2 405 (Method Not Allowed) - isso é normal para GET
```

### Se Node.js não estiver instalado:
- **Windows**: Baixe de https://nodejs.org
- **Mac**: `brew install node`
- **Linux**: `sudo apt install nodejs npm` ou `sudo yum install nodejs npm`

### Verificar se o servidor está rodando:
No Codespace, execute:
```bash
ps aux | grep python3
# Deve mostrar: python3 dev_server.py
```
