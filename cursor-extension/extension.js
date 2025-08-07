const vscode = require('vscode');
const https = require('https');
const http = require('http');

/**
 * Extensão para conectar Cursor ao GitHub Codespace
 */

class CodespaceClient {
    constructor() {
        this.config = vscode.workspace.getConfiguration('codespace-tunnel');
        this.baseUrl = this.config.get('url');
    }

    async makeRequest(endpoint, data) {
        return new Promise((resolve, reject) => {
            const url = new URL(endpoint, this.baseUrl);
            const postData = JSON.stringify(data);
            
            const options = {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': Buffer.byteLength(postData)
                }
            };

            const client = url.protocol === 'https:' ? https : http;
            
            const req = client.request(url, options, (res) => {
                let responseData = '';
                res.on('data', chunk => responseData += chunk);
                res.on('end', () => {
                    try {
                        resolve(JSON.parse(responseData));
                    } catch (e) {
                        reject(new Error('Invalid JSON response'));
                    }
                });
            });

            req.on('error', reject);
            req.write(postData);
            req.end();
        });
    }

    async executeCommand(command, cwd = '/workspaces/tese') {
        try {
            const result = await this.makeRequest('/execute', { command, cwd });
            return result;
        } catch (error) {
            throw new Error(`Erro ao executar comando: ${error.message}`);
        }
    }

    async syncFile(path, content) {
        try {
            const result = await this.makeRequest('/sync', { path, content });
            return result;
        } catch (error) {
            throw new Error(`Erro ao sincronizar arquivo: ${error.message}`);
        }
    }
}

function activate(context) {
    console.log('Codespace Tunnel ativado!');
    
    const client = new CodespaceClient();
    let outputChannel = vscode.window.createOutputChannel('Codespace Tunnel');

    // Comando: Executar no Codespace
    let executeRemoteCommand = vscode.commands.registerCommand('codespace-tunnel.executeRemote', async () => {
        const command = await vscode.window.showInputBox({
            prompt: 'Digite o comando para executar no Codespace',
            placeHolder: 'python3 script.py'
        });

        if (!command) return;

        try {
            outputChannel.show();
            outputChannel.appendLine(`🚀 Executando: ${command}`);
            
            const result = await client.executeCommand(command);
            
            outputChannel.appendLine('📤 STDOUT:');
            outputChannel.appendLine(result.stdout || '(vazio)');
            
            if (result.stderr) {
                outputChannel.appendLine('❌ STDERR:');
                outputChannel.appendLine(result.stderr);
            }
            
            outputChannel.appendLine(`✅ Código de saída: ${result.returncode}`);
            outputChannel.appendLine('─'.repeat(50));
            
        } catch (error) {
            vscode.window.showErrorMessage(`Erro: ${error.message}`);
            outputChannel.appendLine(`❌ Erro: ${error.message}`);
        }
    });

    // Comando: Sincronizar arquivo
    let syncFileCommand = vscode.commands.registerCommand('codespace-tunnel.syncFile', async () => {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage('Nenhum arquivo aberto');
            return;
        }

        const document = editor.document;
        const workspaceFolder = vscode.workspace.getWorkspaceFolder(document.uri);
        
        if (!workspaceFolder) {
            vscode.window.showWarningMessage('Arquivo não está em um workspace');
            return;
        }

        const relativePath = vscode.workspace.asRelativePath(document.uri);
        const content = document.getText();

        try {
            outputChannel.show();
            outputChannel.appendLine(`🔄 Sincronizando: ${relativePath}`);
            
            const result = await client.syncFile(relativePath, content);
            
            if (result.status === 'success') {
                vscode.window.showInformationMessage(`Arquivo ${relativePath} sincronizado!`);
                outputChannel.appendLine(`✅ ${result.message}`);
            } else {
                vscode.window.showErrorMessage(`Erro: ${result.message}`);
                outputChannel.appendLine(`❌ ${result.message}`);
            }
            
        } catch (error) {
            vscode.window.showErrorMessage(`Erro: ${error.message}`);
            outputChannel.appendLine(`❌ Erro: ${error.message}`);
        }
    });

    // Comando: Abrir terminal remoto
    let openTerminalCommand = vscode.commands.registerCommand('codespace-tunnel.openTerminal', async () => {
        const terminal = vscode.window.createTerminal({
            name: 'Codespace Remote',
            shellPath: 'node',
            shellArgs: ['/workspaces/tese/cursor_bridge.js']
        });
        
        terminal.show();
        vscode.window.showInformationMessage('Terminal remoto iniciado!');
    });

    // Auto-sincronização ao salvar
    let autoSyncDisposable = vscode.workspace.onDidSaveTextDocument(async (document) => {
        const autoSync = vscode.workspace.getConfiguration('codespace-tunnel').get('autoSync');
        
        if (!autoSync) return;

        const workspaceFolder = vscode.workspace.getWorkspaceFolder(document.uri);
        if (!workspaceFolder) return;

        const relativePath = vscode.workspace.asRelativePath(document.uri);
        const content = document.getText();

        try {
            await client.syncFile(relativePath, content);
            vscode.window.showInformationMessage(`Auto-sync: ${relativePath}`, { modal: false });
        } catch (error) {
            console.error('Erro no auto-sync:', error);
        }
    });

    context.subscriptions.push(
        executeRemoteCommand,
        syncFileCommand,
        openTerminalCommand,
        autoSyncDisposable,
        outputChannel
    );

    // Mostrar status na barra
    let statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
    statusBarItem.text = "$(cloud) Codespace";
    statusBarItem.tooltip = "Conectado ao Codespace";
    statusBarItem.command = 'codespace-tunnel.executeRemote';
    statusBarItem.show();
    
    context.subscriptions.push(statusBarItem);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
};
