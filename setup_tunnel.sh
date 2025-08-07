#!/bin/bash

# Script para configurar túnel entre Codespace e máquina local
# Permite usar Cursor localmente com poder computacional do Codespace

echo "🚀 Configurando túnel Codespace -> Local"
echo "========================================="

# Informações do ambiente
CODESPACE_NAME="$CODESPACE_NAME"
DOMAIN="$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"

echo "📋 Informações do ambiente:"
echo "   Codespace: $CODESPACE_NAME"
echo "   Domínio: $DOMAIN"
echo ""

# Instalar dependências necessárias
echo "📦 Instalando dependências..."
sudo apt-get update -qq
sudo apt-get install -y openssh-server rsync socat netcat-openbsd

# Configurar SSH server
echo "🔧 Configurando SSH server..."
sudo systemctl enable ssh
sudo systemctl start ssh

# Gerar chave SSH se não existir
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "🔑 Gerando chave SSH..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

# Criar script de sincronização
cat > /workspaces/tese/sync_with_local.sh << 'EOF'
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
EOF

chmod +x /workspaces/tese/sync_with_local.sh

# Criar servidor de desenvolvimento com hot reload
cat > /workspaces/tese/dev_server.py << 'EOF'
#!/usr/bin/env python3

import http.server
import socketserver
import json
import os
import subprocess
import threading
import time
from pathlib import Path

class DevelopmentHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/execute':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            command = data.get('command', '')
            cwd = data.get('cwd', '/workspaces/tese')
            
            try:
                result = subprocess.run(
                    command, 
                    shell=True, 
                    capture_output=True, 
                    text=True, 
                    cwd=cwd,
                    timeout=30
                )
                
                response = {
                    'stdout': result.stdout,
                    'stderr': result.stderr,
                    'returncode': result.returncode
                }
            except subprocess.TimeoutExpired:
                response = {
                    'stdout': '',
                    'stderr': 'Command timed out',
                    'returncode': 124
                }
            except Exception as e:
                response = {
                    'stdout': '',
                    'stderr': str(e),
                    'returncode': 1
                }
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/sync':
            # Endpoint para sincronização de arquivos
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            file_path = data.get('path', '')
            file_content = data.get('content', '')
            
            try:
                full_path = os.path.join('/workspaces/tese', file_path)
                os.makedirs(os.path.dirname(full_path), exist_ok=True)
                
                with open(full_path, 'w') as f:
                    f.write(file_content)
                
                response = {'status': 'success', 'message': 'File saved'}
            except Exception as e:
                response = {'status': 'error', 'message': str(e)}
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

PORT = 8000
Handler = DevelopmentHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"🌐 Servidor rodando na porta {PORT}")
    print(f"📡 Acesso público: https://{os.environ.get('CODESPACE_NAME', 'localhost')}-{PORT}.{os.environ.get('GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN', 'localhost')}")
    httpd.serve_forever()
EOF

chmod +x /workspaces/tese/dev_server.py

# Criar cliente para Cursor
cat > /workspaces/tese/cursor_client.js << 'EOF'
// Cliente JavaScript para integração com Cursor
// Adicione este código como extensão no Cursor ou execute em um ambiente Node.js

class CodespaceClient {
    constructor(baseUrl) {
        this.baseUrl = baseUrl;
    }
    
    async executeCommand(command, cwd = '/workspaces/tese') {
        try {
            const response = await fetch(`${this.baseUrl}/execute`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ command, cwd })
            });
            
            return await response.json();
        } catch (error) {
            console.error('Erro ao executar comando:', error);
            return { stdout: '', stderr: error.message, returncode: 1 };
        }
    }
    
    async syncFile(path, content) {
        try {
            const response = await fetch(`${this.baseUrl}/sync`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ path, content })
            });
            
            return await response.json();
        } catch (error) {
            console.error('Erro ao sincronizar arquivo:', error);
            return { status: 'error', message: error.message };
        }
    }
}

// Exemplo de uso:
// const client = new CodespaceClient('https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev');
// client.executeCommand('python my_script.py').then(console.log);

if (typeof module !== 'undefined' && module.exports) {
    module.exports = CodespaceClient;
}
EOF

# Criar script de configuração para Cursor
cat > /workspaces/tese/cursor_setup.md << 'EOF'
# Configuração do Cursor para usar Codespace

## 1. Extensão para Cursor

Crie uma extensão no Cursor ou use o terminal integrado para executar comandos remotamente.

### Configuração da extensão:

```json
{
    "name": "codespace-tunnel",
    "version": "1.0.0",
    "description": "Túnel para Codespace",
    "main": "cursor_client.js",
    "scripts": {
        "start": "node cursor_client.js"
    }
}
```

## 2. Comandos úteis

### Executar comando no Codespace:
```javascript
const client = new CodespaceClient('https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev');

// Executar Python
await client.executeCommand('python meu_script.py');

// Instalar pacotes
await client.executeCommand('pip install numpy pandas');

// Executar testes
await client.executeCommand('pytest tests/');
```

### Sincronizar arquivo:
```javascript
await client.syncFile('meu_arquivo.py', `
def hello():
    print("Hello from Cursor!")
    
hello()
`);
```

## 3. Configuração no Cursor

1. Abra o Cursor
2. Vá em Extensions
3. Instale a extensão "Remote Development"
4. Configure o túnel usando a URL do servidor

## 4. Uso via SSH (alternativo)

Você também pode usar SSH direto:

```bash
ssh -R 22:localhost:22 codespace@super-trout-5gpv6wrgxgq53p6r9.app.github.dev
```
EOF

echo ""
echo "✅ Configuração concluída!"
echo ""
echo "🌐 URLs importantes:"
echo "   Servidor DEV: https://$CODESPACE_NAME-8000.$DOMAIN"
echo "   SSH: $CODESPACE_NAME.app.github.dev"
echo ""
echo "📋 Próximos passos:"
echo "   1. Execute: python3 dev_server.py (para iniciar o servidor)"
echo "   2. Configure o Cursor usando as instruções em cursor_setup.md"
echo "   3. Use o cliente JavaScript para executar comandos remotos"
echo ""
echo "🔑 Chave pública SSH (para configurar acesso):"
cat ~/.ssh/id_rsa.pub
