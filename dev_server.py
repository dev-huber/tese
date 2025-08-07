#!/usr/bin/env python3

import http.server
import socketserver
import json
import os
import subprocess
import threading
import time
from pathlib import Path

class DevelopmentHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == '/execute':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
            except json.JSONDecodeError as e:
                print(f"Erro JSON: {e}")
                print(f"Dados recebidos: {post_data}")
                self.send_response(400)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'Invalid JSON'}).encode())
                return
            
            command = data.get('command', '')
            cwd = data.get('cwd', '/workspaces/tese')
            
            print(f"🔧 Executando comando: {command}")
            print(f"📁 Diretório: {cwd}")
            
            try:
                result = subprocess.run(
                    command, 
                    shell=True, 
                    capture_output=True, 
                    text=True, 
                    cwd=cwd,
                    timeout=30
                )
                
                response = {
                    'stdout': result.stdout,
                    'stderr': result.stderr,
                    'returncode': result.returncode
                }
                print(f"✅ Comando executado. Código: {result.returncode}")
                
            except subprocess.TimeoutExpired:
                response = {
                    'stdout': '',
                    'stderr': 'Command timed out',
                    'returncode': 124
                }
                print("⏰ Comando expirou por timeout")
            except Exception as e:
                response = {
                    'stdout': '',
                    'stderr': str(e),
                    'returncode': 1
                }
                print(f"❌ Erro na execução: {e}")
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/sync':
            # Endpoint para sincronização de arquivos
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
            except json.JSONDecodeError as e:
                print(f"Erro JSON no sync: {e}")
                self.send_response(400)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'Invalid JSON'}).encode())
                return
            
            file_path = data.get('path', '')
            file_content = data.get('content', '')
            
            print(f"📁 Sincronizando arquivo: {file_path}")
            
            try:
                full_path = os.path.join('/workspaces/tese', file_path)
                os.makedirs(os.path.dirname(full_path), exist_ok=True)
                
                with open(full_path, 'w') as f:
                    f.write(file_content)
                
                response = {'status': 'success', 'message': 'File saved'}
                print(f"✅ Arquivo salvo: {full_path}")
            except Exception as e:
                response = {'status': 'error', 'message': str(e)}
                print(f"❌ Erro ao salvar: {e}")
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

PORT = 8000
Handler = DevelopmentHandler

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"🌐 Servidor rodando na porta {PORT}")
    print(f"📡 Acesso público: https://{os.environ.get('CODESPACE_NAME', 'localhost')}-{PORT}.{os.environ.get('GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN', 'localhost')}")
    httpd.serve_forever()
