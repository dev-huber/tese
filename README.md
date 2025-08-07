# 🌉 Túnel Cursor-Codespace

Use o **poder computacional do GitHub Codespace** com a **interface do Cursor** localmente.

## 🚀 Instalação Rápida

### 🐧 Unix/Linux
```bash
curl -sSL https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.sh | bash
```

### 🪟 Windows

#### PowerShell (Recomendado)
```powershell
iex (iwr https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.ps1).Content
```

#### Batch Script (Simples)
```cmd
curl -o install.bat https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.bat && install.bat
```

📋 **Guia completo Windows**: [WINDOWS_GUIDE.md](WINDOWS_GUIDE.md)

### 🛠️ Instalação Manual

## ✨ Como usar

### Opção 1: Linha de comando
```bash
codespace run "python3 script.py"
codespace sync arquivo.py
```

### Opção 2: Extensão Cursor
- **Ctrl+Shift+R**: Executar no Codespace
- **Ctrl+Shift+S**: Sincronizar arquivo

### Opção 3: API direta
```bash
curl -X POST https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev/execute \
  -H "Content-Type: application/json" \
  -d '{"command": "python3 exemplo.py"}'
```

## 📁 Arquivos principais

- **`dev_server.py`** - Servidor no Codespace
- **`cursor_bridge.js`** - Bridge para máquina local  
- **`install_cursor_tunnel.sh`** - Instalador automático
- **`cursor-extension/`** - Extensão do Cursor
- **[QUICK_START.md](QUICK_START.md)** - Guia detalhado

## 🎯 Recursos

- ⚡ **Python 3.12** + numpy, pandas, matplotlib
- 💾 **7.8GB RAM** + processamento multi-core
- 🌐 **Internet completa** no Codespace
- 🔄 **Sincronização automática** de arquivos

**Edite localmente → Execute na nuvem → Resultados instantâneos! 🚀**

## 🎯 Como Habilitar o Túnel no Cursor

### ✅ Verificar instalação:
```bash
# Linux/Mac
./check_installation.sh

# Windows
check_installation.bat
```

### 🚀 Iniciar bridge local:
```bash
# Linux/Mac
~/cursor-codespace-bridge/start_bridge.sh

# Windows
%USERPROFILE%\cursor-codespace-bridge\start_bridge.bat
```

### ⚙️ Configurar Cursor:
1. Abrir Cursor IDE
2. `Ctrl+Shift+P` → "Reload Window" 
3. Usar `Ctrl+Shift+R` para executar comandos remotos
4. Usar `Ctrl+Shift+S` para sincronizar arquivos

### 🧪 Testar funcionamento:
```bash
# Via terminal
codespace run "python -c 'print(\"Hello from Codespace!\")'"

# Via Cursor (Ctrl+Shift+R)
print("Hello from Cursor!")
```

### 📱 Interface web:
Acesse: http://localhost:3001

## 🔧 Se Ctrl+Shift+R não funciona

### 🔍 Diagnóstico rápido:
```bash
# Linux/Mac
./debug_cursor.sh

# Windows  
debug_cursor.bat
```

### �️ Soluções alternativas:
1. **Command Palette**: `Ctrl+Shift+P` → "Codespace: Execute Remote Command"
2. **Terminal**: `codespace run "seu_codigo_python"`
3. **Interface web**: http://localhost:3001
4. **Reload Window**: `Ctrl+Shift+P` → "Developer: Reload Window"

�📚 **Guia completo**: [CURSOR_SETUP.md](CURSOR_SETUP.md)  
🔧 **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)