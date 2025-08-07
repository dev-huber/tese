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
            data = json.loads(post_data.decode('utf-8'))
            
            command = data.get('command', '')
            cwd = data.get('cwd', '/workspaces/tese')
            
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
            except subprocess.TimeoutExpired:
                response = {
                    'stdout': '',
                    'stderr': 'Command timed out',
                    'returncode': 124
                }
            except Exception as e:
                response = {
                    'stdout': '',
                    'stderr': str(e),
                    'returncode': 1
                }
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/sync':
            # Endpoint para sincronização de arquivos
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            data = json.loads(post_data.decode('utf-8'))
            
            file_path = data.get('path', '')
            file_content = data.get('content', '')
            
            try:
                full_path = os.path.join('/workspaces/tese', file_path)
                os.makedirs(os.path.dirname(full_path), exist_ok=True)
                
                with open(full_path, 'w') as f:
                    f.write(file_content)
                
                response = {'status': 'success', 'message': 'File saved'}
            except Exception as e:
                response = {'status': 'error', 'message': str(e)}
            
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
