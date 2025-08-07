# 🌉 Túnel Cursor-Codespace

Sistema completo para usar o **poder computacional do GitHub Codespace** com a **interface do Cursor** rodando localmente.

## 🚀 Instalação Rápida

Na sua máquina local, execute:

```bash
curl -sSL https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.sh | bash
```

## ✨ Funcionalidades

- 🖥️ **Interface familiar**: Use o Cursor na sua máquina
- ⚡ **Poder computacional**: Execute no Codespace (7.8GB RAM, multi-core)
- 🔄 **Sincronização automática**: Arquivos sincronizados instantaneamente
- 🐍 **Ambiente completo**: Python 3.12 + numpy, pandas, matplotlib
- 🌐 **Acesso total**: Internet sem restrições no Codespace

## 🎯 Como usar

### Opção 1: Linha de comando
```bash
# Após instalação automática
codespace run "python3 meu_script.py"
codespace sync arquivo.py
```

### Opção 2: Extensão Cursor
- **Ctrl+Shift+R**: Executar comando no Codespace
- **Ctrl+Shift+S**: Sincronizar arquivo atual

### Opção 3: Bridge local
```bash
~/cursor-codespace-bridge/start_bridge.sh
# Use API em http://localhost:3001
```

## 📚 Documentação

- **[🚀 Guia Rápido](QUICK_START.md)** - Configuração em 5 minutos
- **[📖 Guia Completo](CURSOR_SETUP_GUIDE.md)** - Todas as opções detalhadas
- **[🔧 Documentação Técnica](README_TUNNEL.md)** - Arquitetura e especificações

## 🧪 Teste

```bash
# Teste rápido
curl -X POST https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev/execute \
  -H "Content-Type: application/json" \
  -d '{"command": "python3 -c \"print(\"Hello from Codespace!\")\""}'
```

## 📁 Estrutura

```
├── setup_tunnel.sh          # Configuração inicial do Codespace
├── install_cursor_tunnel.sh # Instalador para máquina local
├── cursor-extension/         # Extensão completa para Cursor
├── dev_server.py            # Servidor HTTP no Codespace
├── cursor_bridge.js         # Bridge Node.js local
├── exemplo_cursor.py        # Exemplo prático de uso
└── test_codespace.py        # Testes de integração
```

## 🎉 Pronto para usar!

**Edite no Cursor → Execute no Codespace → Veja resultados instantaneamente!**