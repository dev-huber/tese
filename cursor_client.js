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
