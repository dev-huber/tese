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