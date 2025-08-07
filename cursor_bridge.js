#!/usr/bin/env node

/**
 * Cliente Node.js para conectar Cursor ao Codespace
 * Execute: node cursor_bridge.js
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

class CursorCodespaceBridge {
    constructor(codespaceUrl, localPath = './') {
        this.codespaceUrl = codespaceUrl;
        this.localPath = path.resolve(localPath);
        this.port = 3001;
        
        console.log('🌉 Cursor-Codespace Bridge');
        console.log(`   Codespace: ${this.codespaceUrl}`);
        console.log(`   Local: ${this.localPath}`);
    }

    async executeRemote(command, cwd = '/workspaces/tese') {
        const url = `${this.codespaceUrl}/execute`;
        const postData = JSON.stringify({ command, cwd });

        return new Promise((resolve, reject) => {
            const options = {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': Buffer.byteLength(postData)
                }
            };

            const req = http.request(url, options, (res) => {
                let data = '';
                res.on('data', chunk => data += chunk);
                res.on('end', () => {
                    try {
                        resolve(JSON.parse(data));
                    } catch (e) {
                        reject(e);
                    }
                });
            });

            req.on('error', reject);
            req.write(postData);
            req.end();
        });
    }

    async syncToRemote(filePath, content) {
        const url = `${this.codespaceUrl}/sync`;
        const postData = JSON.stringify({ path: filePath, content });

        return new Promise((resolve, reject) => {
            const options = {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': Buffer.byteLength(postData)
                }
            };

            const req = http.request(url, options, (res) => {
                let data = '';
                res.on('data', chunk => data += chunk);
                res.on('end', () => {
                    try {
                        resolve(JSON.parse(data));
                    } catch (e) {
                        reject(e);
                    }
                });
            });

            req.on('error', reject);
            req.write(postData);
            req.end();
        });
    }

    startLocalServer() {
        const server = http.createServer(async (req, res) => {
            // CORS headers
            res.setHeader('Access-Control-Allow-Origin', '*');
            res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
            res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

            if (req.method === 'OPTIONS') {
                res.writeHead(200);
                res.end();
                return;
            }

            if (req.method === 'POST') {
                let body = '';
                req.on('data', chunk => body += chunk);
                req.on('end', async () => {
                    try {
                        const data = JSON.parse(body);
                        
                        if (req.url === '/execute-remote') {
                            // Executar comando no Codespace
                            const result = await this.executeRemote(data.command, data.cwd);
                            res.writeHead(200, { 'Content-Type': 'application/json' });
                            res.end(JSON.stringify(result));
                            
                        } else if (req.url === '/sync-to-remote') {
                            // Sincronizar arquivo para o Codespace
                            const result = await this.syncToRemote(data.path, data.content);
                            res.writeHead(200, { 'Content-Type': 'application/json' });
                            res.end(JSON.stringify(result));
                            
                        } else if (req.url === '/sync-from-local') {
                            // Ler arquivo local e enviar para Codespace
                            const filePath = path.join(this.localPath, data.path);
                            try {
                                const content = fs.readFileSync(filePath, 'utf8');
                                const result = await this.syncToRemote(data.path, content);
                                res.writeHead(200, { 'Content-Type': 'application/json' });
                                res.end(JSON.stringify(result));
                            } catch (error) {
                                res.writeHead(500, { 'Content-Type': 'application/json' });
                                res.end(JSON.stringify({ error: error.message }));
                            }
                            
                        } else if (req.url === '/execute-local') {
                            // Executar comando localmente
                            exec(data.command, { cwd: this.localPath }, (error, stdout, stderr) => {
                                const result = {
                                    stdout,
                                    stderr,
                                    returncode: error ? error.code : 0
                                };
                                res.writeHead(200, { 'Content-Type': 'application/json' });
                                res.end(JSON.stringify(result));
                            });
                        }
                    } catch (error) {
                        res.writeHead(500, { 'Content-Type': 'application/json' });
                        res.end(JSON.stringify({ error: error.message }));
                    }
                });
            } else if (req.method === 'GET' && req.url === '/status') {
                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    status: 'running',
                    codespace: this.codespaceUrl,
                    local: this.localPath
                }));
            } else {
                res.writeHead(404);
                res.end('Not Found');
            }
        });

        server.listen(this.port, () => {
            console.log(`🚀 Bridge server rodando na porta ${this.port}`);
            console.log(`📡 Acesse: http://localhost:${this.port}/status`);
            console.log('');
            console.log('📋 Endpoints disponíveis:');
            console.log('   POST /execute-remote - Executar comando no Codespace');
            console.log('   POST /sync-to-remote - Sincronizar conteúdo para Codespace');
            console.log('   POST /sync-from-local - Sincronizar arquivo local para Codespace');
            console.log('   POST /execute-local - Executar comando localmente');
            console.log('   GET  /status - Status do bridge');
        });
    }
}

// Configuração
const CODESPACE_URL = 'https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev';
const LOCAL_PATH = process.argv[2] || './';

const bridge = new CursorCodespaceBridge(CODESPACE_URL, LOCAL_PATH);
bridge.startLocalServer();

// Exemplo de uso via curl:
console.log('\n🔧 Exemplos de uso:');
console.log('\n# Executar Python no Codespace:');
console.log('curl -X POST http://localhost:3001/execute-remote \\');
console.log('  -H "Content-Type: application/json" \\');
console.log('  -d \'{"command": "python3 -c \\"print(\\'Hello from Codespace!\\')\\""}\'');

console.log('\n# Sincronizar arquivo local para Codespace:');
console.log('curl -X POST http://localhost:3001/sync-from-local \\');
console.log('  -H "Content-Type: application/json" \\');
console.log('  -d \'{"path": "test.py"}\'');
