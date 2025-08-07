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
