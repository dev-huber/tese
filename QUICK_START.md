# ⚡ Configurar Cursor com Codespace - Guia Rápido

## 🎯 Instalação Automática (Recomendada)

Na sua **máquina local**, execute:

```bash
curl -sSL https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.sh | bash
```

## 🚀 Uso Imediato

### 1. Bridge Local (Mais fácil)
```bash
# Na sua máquina local, no diretório do projeto:
~/cursor-codespace-bridge/start_bridge.sh

# Em outro terminal ou no Cursor:
curl -X POST http://localhost:3001/execute-remote \
  -H "Content-Type: application/json" \
  -d '{"command": "python3 meu_script.py"}'
```

### 2. Linha de Comando (Após instalação)
```bash
# Executar Python no Codespace
codespace run "python3 script.py"

# Sincronizar arquivo
codespace sync arquivo.py

# Verificar status
codespace status
```

### 3. Extensão Cursor
1. **Reinicie o Cursor** (extensão já foi instalada)
2. **Configure**: Ctrl+, → procure "Codespace Tunnel" 
3. **URL**: `https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev`
4. **Use**: 
   - `Ctrl+Shift+R` → Executar comando
   - `Ctrl+Shift+S` → Sincronizar arquivo

## ✅ Teste Rápido

```bash
# Teste se funciona
curl -X POST https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev/execute \
  -H "Content-Type: application/json" \
  -d '{"command": "python3 -c \"print(\"Hello from Codespace!\")\""}'
```

**Resposta esperada:**
```json
{
    "stdout": "Hello from Codespace!\n",
    "stderr": "",
    "returncode": 0
}
```

## 🎮 Fluxo de Trabalho

1. **Edite código no Cursor** (na sua máquina)
2. **Execute no Codespace** (poder computacional)
3. **Veja resultados no Cursor** (interface familiar)

### Exemplo prático:
```python
# arquivo: meu_script.py (editado no Cursor)
import numpy as np
import pandas as pd

# Processamento pesado roda no Codespace
data = np.random.rand(1000000)
df = pd.DataFrame(data, columns=['values'])
result = df.describe()
print(result)
```

```bash
# Execute no Codespace via Cursor
codespace run "python3 meu_script.py"
```

## 💡 Dicas

- ✅ **Use o bridge local** para máxima flexibilidade
- ✅ **Configure auto-sync** na extensão para sincronização automática
- ✅ **Mantenha arquivos pequenos** no local, processe dados no Codespace
- ✅ **Use bibliotecas pesadas** sem instalar localmente

## 🆘 Problemas?

### Codespace não responde:
```bash
# No Codespace, verificar se servidor está rodando:
ps aux | grep python3
# Se não estiver: python3 dev_server.py
```

### Erro de conexão:
```bash
# Testar conectividade:
curl -I https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
```

### Bridge não funciona:
```bash
# Verificar Node.js:
node --version
# Se não estiver instalado: https://nodejs.org
```

---

**🎉 Pronto! Agora você tem o poder do Codespace com a interface do Cursor!**
