# 🎯 Como Habilitar o Túnel no Cursor Após Instalação

Este guia mostra como configurar e usar o túnel Cursor-Codespace após a instalação.

## 🚀 Passo 1: Verificar Instalação

### Windows
```cmd
# Verificar se os arquivos foram instalados
dir %USERPROFILE%\cursor-codespace-bridge

# Testar comando básico
%USERPROFILE%\cursor-codespace-bridge\codespace.bat status
```

### Linux/Mac
```bash
# Verificar instalação
ls -la ~/cursor-codespace-bridge/

# Testar comando básico
~/cursor-codespace-bridge/codespace status
```

## 🔧 Passo 2: Iniciar o Bridge Local

### Opção A: Via Script
```cmd
# Windows
%USERPROFILE%\cursor-codespace-bridge\start_bridge.bat

# Linux/Mac
~/cursor-codespace-bridge/start_bridge.sh
```

### Opção B: Manual
```cmd
# Navegar para o diretório
cd %USERPROFILE%\cursor-codespace-bridge  # Windows
cd ~/cursor-codespace-bridge              # Linux/Mac

# Iniciar bridge
node cursor_bridge.js
```

O bridge iniciará na porta **3001** e ficará rodando em background.

## 🎨 Passo 3: Configurar Cursor IDE

### 3.1 Verificar Extensão
1. Abra o **Cursor**
2. `Ctrl+Shift+P` (Windows) ou `Cmd+Shift+P` (Mac)
3. Digite: **"Reload Window"**
4. Pressione **Enter**

### 3.2 Configurar URL do Codespace
1. `Ctrl+Shift+P` → **"Preferences: Open Settings (JSON)"**
2. Adicione:
```json
{
    "codespace.serverUrl": "https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev",
    "codespace.bridgePort": 3001
}
```

## ⚡ Passo 4: Usar o Túnel

### 4.1 Comandos Via Extensão

#### Executar Código Remoto
- **Atalho**: `Ctrl+Shift+R`
- **Menu**: `View` → `Command Palette` → "Execute Remote Command"

#### Sincronizar Arquivos
- **Atalho**: `Ctrl+Shift+S`
- **Menu**: `View` → `Command Palette` → "Sync File to Codespace"

### 4.2 Comandos Via Terminal Integrado

No terminal do Cursor:

```bash
# Windows
codespace run "python meu_script.py"
codespace run "pip install numpy"
codespace status

# Linux/Mac  
./codespace run "python meu_script.py"
./codespace run "pip install numpy"
./codespace status
```

### 4.3 Via Interface Bridge Local

Abra no navegador: http://localhost:3001

Interface web com:
- Campo de comando
- Botão "Execute"
- Área de resultado
- Status do servidor

## 🔥 Passo 5: Teste Completo

### Teste Básico
```python
# Execute no Cursor via Ctrl+Shift+R
print("Hello from Codespace!")
import sys
print(f"Python: {sys.version}")
print(f"Platform: {sys.platform}")
```

### Teste de Poder Computacional
```python
# Execute para testar capacidade
import numpy as np
import time

start = time.time()
matrix = np.random.rand(1000, 1000)
result = np.dot(matrix, matrix)
end = time.time()

print(f"Matriz 1000x1000 processada em {end-start:.2f}s")
print(f"Memória disponível: {np.get_include()}")
```

### Teste de Sincronização
1. Crie arquivo local: `teste.py`
2. `Ctrl+Shift+S` para sincronizar
3. `Ctrl+Shift+R` e execute: `python teste.py`

## 🛠️ Configurações Avançadas

### Personalizar Atalhos
```json
// settings.json no Cursor
{
    "keyboard.shortcuts": [
        {
            "key": "ctrl+r",
            "command": "codespace.executeRemote"
        },
        {
            "key": "ctrl+u",
            "command": "codespace.syncFile"
        }
    ]
}
```

### Configurar Auto-Start
#### Windows (Task Scheduler)
```cmd
# Criar tarefa que inicia com Windows
schtasks /create /tn "Cursor Bridge" /tr "%USERPROFILE%\cursor-codespace-bridge\start_bridge.bat" /sc onlogon
```

#### Linux/Mac (systemd/launchd)
```bash
# Criar serviço systemd
sudo tee /etc/systemd/system/cursor-bridge.service > /dev/null <<EOF
[Unit]
Description=Cursor Codespace Bridge
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/cursor-codespace-bridge
ExecStart=/usr/bin/node cursor_bridge.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable cursor-bridge
sudo systemctl start cursor-bridge
```

## 🐛 Troubleshooting

### Bridge não conecta
```bash
# Verificar se está rodando
netstat -an | grep 3001  # Linux/Mac
netstat -an | findstr 3001  # Windows

# Reiniciar bridge
pkill -f cursor_bridge.js  # Linux/Mac
taskkill /F /IM node.exe   # Windows (cuidado, mata todos os node)
```

### Extensão não funciona
1. `Ctrl+Shift+P` → "Developer: Reload Window"
2. Verificar console: `Help` → `Toggle Developer Tools`
3. Reinstalar extensão:
```bash
# Remover e reinstalar
rm -rf ~/.cursor/extensions/codespace-tunnel  # Linux/Mac
rmdir /s %USERPROFILE%\.cursor\extensions\codespace-tunnel  # Windows

# Executar instalador novamente
```

### Codespace não responde
```bash
# Testar conectividade
curl -I https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev

# Se estiver offline, iniciar servidor no Codespace:
python dev_server.py
```

## 📊 Monitoramento

### Logs do Bridge
```bash
# Ver logs em tempo real
tail -f ~/cursor-codespace-bridge/bridge.log  # Linux/Mac

# Windows (se configurado logging)
type %USERPROFILE%\cursor-codespace-bridge\bridge.log
```

### Status Completo
```bash
# Script de diagnóstico
codespace status
curl http://localhost:3001/health
curl https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev/status
```

## 🎉 Workflow Recomendado

1. **Manhã**: Iniciar bridge (`start_bridge.bat`)
2. **Desenvolvimento**: Usar `Ctrl+Shift+R` para executar código
3. **Sincronização**: `Ctrl+Shift+S` para enviar arquivos
4. **Teste**: Interface web para comandos rápidos
5. **Noite**: Bridge pode ficar rodando 24/7

## 💡 Dicas Avançadas

### Alias Úteis
```bash
# Windows (PowerShell profile)
Set-Alias cs "$env:USERPROFILE\cursor-codespace-bridge\codespace.bat"

# Linux/Mac (.bashrc)
alias cs="~/cursor-codespace-bridge/codespace"
alias bridge="~/cursor-codespace-bridge/start_bridge.sh"
```

### Integração com Git
```bash
# Executar git remoto via Cursor
cs run "git status"
cs run "git add ."
cs run "git commit -m 'Update from Cursor'"
cs run "git push"
```

### Multi-Projeto
```bash
# Cada projeto pode ter seu bridge
mkdir ~/projeto1-bridge
mkdir ~/projeto2-bridge

# Configurar portas diferentes
PROJECT1_PORT=3001 node cursor_bridge.js ~/projeto1
PROJECT2_PORT=3002 node cursor_bridge.js ~/projeto2
```

---

🚀 **Agora você tem o poder computacional do Codespace na interface do Cursor!**

Para dúvidas, verifique os logs ou execute `codespace status` para diagnóstico.
