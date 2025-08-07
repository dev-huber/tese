#!/usr/bin/env python3

"""
Script de teste para verificar a integração Cursor -> Codespace
Execute este script no Codespace para testar as funcionalidades
"""

import json
import time
import sys
import os
from datetime import datetime

def test_computational_power():
    """Testa o poder computacional do Codespace"""
    print("🧮 Testando poder computacional...")
    
    # Test CPU
    import math
    start_time = time.time()
    result = sum(math.sqrt(i) for i in range(1000000))
    cpu_time = time.time() - start_time
    
    print(f"   ✅ CPU Test: {cpu_time:.3f}s (resultado: {result:.2f})")
    
    # Test memory
    try:
        import psutil
        memory = psutil.virtual_memory()
        print(f"   ✅ Memória total: {memory.total / (1024**3):.1f} GB")
        print(f"   ✅ Memória disponível: {memory.available / (1024**3):.1f} GB")
    except ImportError:
        print("   ⚠️ psutil não instalado (pip install psutil)")
    
    return True

def test_python_environment():
    """Testa o ambiente Python"""
    print("🐍 Testando ambiente Python...")
    
    print(f"   ✅ Python: {sys.version}")
    print(f"   ✅ Plataforma: {sys.platform}")
    print(f"   ✅ Diretório atual: {os.getcwd()}")
    
    # Teste de pacotes comuns
    packages = ['numpy', 'pandas', 'matplotlib', 'requests', 'scikit-learn']
    available = []
    
    for package in packages:
        try:
            __import__(package)
            available.append(package)
        except ImportError:
            pass
    
    if available:
        print(f"   ✅ Pacotes disponíveis: {', '.join(available)}")
    else:
        print("   ⚠️ Nenhum pacote científico encontrado")
    
    return True

def test_file_operations():
    """Testa operações de arquivo"""
    print("📁 Testando operações de arquivo...")
    
    test_file = "test_codespace.txt"
    test_content = f"Teste executado em {datetime.now()}\n"
    
    try:
        # Escrever arquivo
        with open(test_file, 'w') as f:
            f.write(test_content)
        print(f"   ✅ Arquivo criado: {test_file}")
        
        # Ler arquivo
        with open(test_file, 'r') as f:
            content = f.read()
        print(f"   ✅ Arquivo lido: {len(content)} caracteres")
        
        # Deletar arquivo
        os.remove(test_file)
        print(f"   ✅ Arquivo removido: {test_file}")
        
    except Exception as e:
        print(f"   ❌ Erro: {e}")
        return False
    
    return True

def test_network_access():
    """Testa acesso à rede"""
    print("🌐 Testando acesso à rede...")
    
    try:
        import urllib.request
        import json
        
        # Teste de API pública
        with urllib.request.urlopen('https://api.github.com/zen', timeout=5) as response:
            zen = response.read().decode()
        
        print(f"   ✅ GitHub API: {zen.strip()}")
        
        # Teste de resolução DNS
        import socket
        ip = socket.gethostbyname('github.com')
        print(f"   ✅ DNS: github.com -> {ip}")
        
    except Exception as e:
        print(f"   ❌ Erro de rede: {e}")
        return False
    
    return True

def run_performance_benchmark():
    """Executa benchmark de performance"""
    print("⚡ Executando benchmark de performance...")
    
    # Fibonacci recursivo para testar CPU
    def fibonacci(n):
        if n <= 1:
            return n
        return fibonacci(n-1) + fibonacci(n-2)
    
    start_time = time.time()
    fib_result = fibonacci(30)
    fib_time = time.time() - start_time
    
    print(f"   ✅ Fibonacci(30): {fib_result} em {fib_time:.3f}s")
    
    # Teste de I/O
    start_time = time.time()
    data = [i**2 for i in range(100000)]
    io_time = time.time() - start_time
    
    print(f"   ✅ Lista comprehension (100k): {io_time:.3f}s")
    
    return True

def main():
    """Função principal"""
    print("🚀 Teste de Integração Cursor -> Codespace")
    print("=" * 45)
    print()
    
    tests = [
        ("Ambiente Python", test_python_environment),
        ("Poder Computacional", test_computational_power),
        ("Operações de Arquivo", test_file_operations),
        ("Acesso à Rede", test_network_access),
        ("Benchmark Performance", run_performance_benchmark)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        print(f"🔬 {test_name}")
        try:
            success = test_func()
            results.append((test_name, success))
        except Exception as e:
            print(f"   ❌ Erro inesperado: {e}")
            results.append((test_name, False))
        print()
    
    # Resumo
    print("📊 Resumo dos testes:")
    passed = 0
    for test_name, success in results:
        status = "✅ PASSOU" if success else "❌ FALHOU"
        print(f"   {status}: {test_name}")
        if success:
            passed += 1
    
    print()
    print(f"🎯 Resultado: {passed}/{len(results)} testes passaram")
    
    if passed == len(results):
        print("🎉 Todos os testes passaram! O Codespace está pronto para uso.")
    else:
        print("⚠️ Alguns testes falharam. Verifique a configuração.")
    
    return passed == len(results)

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
