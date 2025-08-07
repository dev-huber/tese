# 🌉 Túnel Codespace -> Cursor

Este projeto configura um túnel que permite usar o **poder computacional do GitHub Codespace** com a **interface do Cursor** rodando localmente.

## 🎯 O que foi criado

### ✅ Sistema Completo Configurado
- **Servidor de desenvolvimento** rodando no Codespace (porta 8000)
- **Cliente bridge** para conectar Cursor ao Codespace
- **Extensão para Cursor** com comandos integrados
- **Scripts de configuração** automatizados
- **Testes de integração** completos

### 🚀 URLs Importantes
- **Servidor Codespace**: https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
- **Bridge local**: http://localhost:3001 (quando executado)

## 🔧 Como usar

### 1. No Codespace (já configurado)
O servidor já está rodando! Você pode verificar em:
```bash
# Verificar se o servidor está ativo
curl https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
```

### 2. Na máquina local

#### Opção A: Usar o bridge Node.js
```bash
# 1. Baixar os arquivos para sua máquina local:
curl -O https://raw.githubusercontent.com/dev-huber/tese/main/cursor_bridge.js
curl -O https://raw.githubusercontent.com/dev-huber/tese/main/use_tunnel.sh

# 2. Iniciar o bridge
node cursor_bridge.js /caminho/do/seu/projeto

# 3. Usar a API
curl -X POST http://localhost:3001/execute-remote \
  -H "Content-Type: application/json" \
  -d '{"command": "python3 -c \"print(\"Hello from Codespace!\")\""}'
```

#### Opção B: Instalar extensão no Cursor
```bash
# 1. Baixar a extensão
mkdir -p ~/.cursor/extensions/codespace-tunnel
curl -o ~/.cursor/extensions/codespace-tunnel/package.json https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/package.json
curl -o ~/.cursor/extensions/codespace-tunnel/extension.js https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/extension.js

# 2. Reiniciar o Cursor

# 3. Configurar a extensão:
# - Ctrl+, para abrir configurações
# - Procurar "Codespace Tunnel"
# - URL: https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
```

### 3. Comandos disponíveis

#### No Cursor (com extensão)
- **Ctrl+Shift+R**: Executar comando no Codespace
- **Ctrl+Shift+S**: Sincronizar arquivo atual

#### Via API (curl)
```bash
# Executar Python
curl -X POST http://localhost:3001/execute-remote \
  -H "Content-Type: application/json" \
  -d '{"command": "python3 script.py"}'

# Sincronizar arquivo
curl -X POST http://localhost:3001/sync-to-remote \
  -H "Content-Type: application/json" \
  -d '{"path": "test.py", "content": "print(\"Hello!\")"}'

# Executar localmente
curl -X POST http://localhost:3001/execute-local \
  -H "Content-Type: application/json" \
  -d '{"command": "ls -la"}'
```

## 🔍 Verificar funcionamento

### Teste rápido
```bash
# Testar o servidor do Codespace
curl https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev

# Executar teste completo (no Codespace)
python3 test_codespace.py
```

## 📊 Especificações do Codespace

### 💻 Recursos disponíveis
- **CPU**: Multi-core (teste: Fibonacci(30) em 0.153s)
- **RAM**: 7.8 GB total, ~4.8 GB disponível
- **Python**: 3.12.1 com pacotes: numpy, pandas, matplotlib, requests
- **Rede**: Acesso completo à internet
- **Storage**: SSD rápido

### 🎯 Performance
- **Operações matemáticas**: ✅ Excelente
- **I/O de arquivos**: ✅ Muito rápido
- **Acesso à rede**: ✅ Sem restrições
- **Pacotes Python**: ✅ Ambiente completo

## 🛠️ Arquivos criados

| Arquivo | Descrição |
|---------|-----------|
| `setup_tunnel.sh` | Script principal de configuração |
| `dev_server.py` | Servidor HTTP no Codespace |
| `cursor_bridge.js` | Bridge Node.js para API local |
| `cursor-extension/` | Extensão completa para Cursor |
| `test_codespace.py` | Testes de integração |
| `use_tunnel.sh` | Script de uso e exemplos |

## 🔐 Segurança

- ✅ Servidor acessível apenas via HTTPS
- ✅ CORS configurado corretamente
- ✅ Timeout de 30s para comandos
- ✅ Validação de entrada nos endpoints

## 💡 Casos de uso

### 🐍 Desenvolvimento Python
```python
# No Cursor (local): edite o código
# Sincronize automaticamente para o Codespace
# Execute com todo o poder computacional

# Exemplo: Machine Learning
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split

# Processar datasets grandes no Codespace
data = pd.read_csv('large_dataset.csv')
model = train_model(data)
```

### 🔬 Análise de dados
```python
# Use bibliotecas pesadas no Codespace
import matplotlib.pyplot as plt
import seaborn as sns

# Gere gráficos complexos
plt.figure(figsize=(20, 10))
# ... código de visualização
```

### 🧠 IA e Machine Learning
```python
# Treine modelos no Codespace
from transformers import pipeline

# Use modelos pré-treinados
classifier = pipeline("sentiment-analysis")
result = classifier("I love using Codespace with Cursor!")
```

## 🎉 Pronto para usar!

O túnel está **100% funcional** e testado. Você pode:

1. **Editar código no Cursor** (interface familiar)
2. **Executar no Codespace** (poder computacional)
3. **Sincronizar automaticamente** (fluxo seamless)
4. **Usar qualquer biblioteca Python** (ambiente completo)

**Aproveite o melhor dos dois mundos! 🚀**
