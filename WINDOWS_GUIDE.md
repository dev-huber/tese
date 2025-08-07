# 🪟 Guia de Instalação - Windows

Este guia específico para Windows mostra três opções de instalação do túnel Cursor-Codespace.

## 🎯 Escolha Sua Opção

### ⚡ Opção 1: Script Batch (Mais Simples)
Para usuários que preferem simplicidade sem PowerShell:

```cmd
# Baixar e executar
curl -o install.bat https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.bat
install.bat
```

### 🔧 Opção 2: PowerShell (Mais Poderoso)
Para configuração avançada e automática:

```powershell
# Executar como administrador (opcional)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
iex (iwr https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.ps1).Content
```

### 🛠️ Opção 3: Manual
Para controle total do processo, siga o guia principal.

## 🔧 Pré-requisitos Windows

### Node.js
Instale via:
- **Site oficial**: https://nodejs.org
- **Winget**: `winget install OpenJS.NodeJS`
- **Chocolatey**: `choco install nodejs`

### Cursor IDE
- **Site oficial**: https://cursor.sh
- **Winget**: `winget install Cursor.Cursor`

## 🚀 Verificação da Instalação

### 1. Testar Bridge Local
```cmd
cd %USERPROFILE%\cursor-codespace-bridge
start_bridge.bat
```

### 2. Testar Comando Remoto
```cmd
codespace.bat run "python -c \"print('Windows OK!')\""
```

### 3. Testar Status
```cmd
codespace.bat status
```

## 🎯 Usando no Cursor

### Via Extensão
1. Abra Cursor
2. `Ctrl+Shift+P` → "Reload Window"
3. `Ctrl+Shift+R` → Executar comando remoto
4. `Ctrl+Shift+S` → Sincronizar arquivos

### Via Terminal Integrado
```cmd
# No terminal do Cursor
codespace run "pip install numpy pandas"
codespace run "python meu_script.py"
```

## 🔧 Configuração Avançada Windows

### Adicionar ao PATH
Para usar `codespace` de qualquer lugar:

```cmd
# Temporário (sessão atual)
set PATH=%PATH%;%USERPROFILE%\cursor-codespace-bridge

# Permanente (requer admin)
setx PATH "%PATH%;%USERPROFILE%\cursor-codespace-bridge" /M
```

### Configurar Variáveis
```cmd
# Configurar URL do Codespace
setx CODESPACE_URL "https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev"

# Configurar bridge port
setx BRIDGE_PORT "3001"
```

### Desktop Shortcut
Criar atalho na área de trabalho:

```cmd
# Script para criar atalho
echo @echo off > "%USERPROFILE%\Desktop\Codespace Bridge.bat"
echo cd /d "%USERPROFILE%\cursor-codespace-bridge" >> "%USERPROFILE%\Desktop\Codespace Bridge.bat"
echo start_bridge.bat >> "%USERPROFILE%\Desktop\Codespace Bridge.bat"
```

## 🐛 Troubleshooting Windows

### Erro: "Node.js não encontrado"
```cmd
# Verificar instalação
node --version
npm --version

# Reinstalar se necessário
winget install OpenJS.NodeJS
```

### Erro: "Política de execução"
```powershell
# Para PowerShell scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Erro: "Codespace não acessível"
```cmd
# Testar conectividade
ping super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
curl -I https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
```

### Erro: "Porta em uso"
```cmd
# Verificar portas
netstat -ano | findstr :3001
netstat -ano | findstr :8000

# Parar processo se necessário
taskkill /PID <PID> /F
```

## 🎨 Interface Windows Específica

### Batch Script Avançado
```cmd
@echo off
title Cursor-Codespace Bridge Controller

:menu
cls
echo 🎯 Cursor-Codespace Bridge
echo ========================
echo.
echo 1. Iniciar Bridge
echo 2. Status do Codespace
echo 3. Executar Comando
echo 4. Sair
echo.
set /p choice="Escolha uma opção (1-4): "

if "%choice%"=="1" goto start_bridge
if "%choice%"=="2" goto check_status
if "%choice%"=="3" goto run_command
if "%choice%"=="4" goto exit
goto menu

:start_bridge
echo 🚀 Iniciando bridge...
start "Bridge" "%USERPROFILE%\cursor-codespace-bridge\start_bridge.bat"
pause
goto menu

:check_status
echo 📊 Verificando status...
codespace.bat status
pause
goto menu

:run_command
echo 💻 Digite o comando para executar no Codespace:
set /p cmd="Comando: "
codespace.bat run "%cmd%"
pause
goto menu

:exit
echo 👋 Até logo!
exit
```

## 📈 Performance no Windows

### Monitoramento
```cmd
# CPU e memória
wmic cpu get loadpercentage /value
wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /value

# Processos Node.js
tasklist | findstr node.exe
```

### Otimização
```cmd
# Prioridade alta para bridge
wmic process where name="node.exe" CALL setpriority "high priority"

# Limpeza de cache
npm cache clean --force
```

## 🎉 Próximos Passos

1. **Testar instalação**: Execute os comandos de verificação
2. **Configurar Cursor**: Instale a extensão e teste comandos
3. **Automatizar**: Configure atalhos e variáveis de ambiente
4. **Desenvolver**: Comece a usar o poder do Codespace!

---

💡 **Dica**: Use o **Windows Terminal** para melhor experiência com cores e múltiplas abas.

🔗 **Links úteis**:
- Cursor: https://cursor.sh
- Node.js: https://nodejs.org
- Windows Terminal: https://aka.ms/terminal
