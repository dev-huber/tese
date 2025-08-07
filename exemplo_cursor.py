"""
Exemplo prático: Como usar o Cursor com Codespace
Execute este arquivo no Cursor para testar a integração
"""

def teste_basico():
    """Teste básico de Python"""
    print("🐍 Python rodando no Codespace!")
    print(f"Versão: {__import__('sys').version}")
    return "sucesso"

def teste_matematico():
    """Teste de operações matemáticas pesadas"""
    import math
    import time
    
    print("🧮 Executando cálculos pesados...")
    start = time.time()
    
    # Cálculo intensivo
    result = sum(math.sqrt(i) * math.sin(i) for i in range(100000))
    
    end = time.time()
    print(f"Resultado: {result:.2f}")
    print(f"Tempo: {end - start:.3f} segundos")
    return result

def teste_bibliotecas():
    """Teste de bibliotecas disponíveis"""
    bibliotecas = ['numpy', 'pandas', 'matplotlib', 'requests', 'json', 'os']
    disponivel = []
    
    for lib in bibliotecas:
        try:
            __import__(lib)
            disponivel.append(lib)
            print(f"✅ {lib}")
        except ImportError:
            print(f"❌ {lib}")
    
    print(f"\n📊 {len(disponivel)}/{len(bibliotecas)} bibliotecas disponíveis")
    return disponivel

def teste_arquivo():
    """Teste de criação e manipulação de arquivos"""
    import os
    from datetime import datetime
    
    filename = f"teste_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
    
    # Criar arquivo
    with open(filename, 'w') as f:
        f.write(f"Arquivo criado no Codespace\n")
        f.write(f"Timestamp: {datetime.now()}\n")
        f.write(f"Diretório: {os.getcwd()}\n")
    
    # Ler arquivo
    with open(filename, 'r') as f:
        content = f.read()
    
    print(f"📁 Arquivo criado: {filename}")
    print(f"📄 Conteúdo:\n{content}")
    
    # Limpar
    os.remove(filename)
    print(f"🗑️ Arquivo removido: {filename}")
    
    return filename

def main():
    """Função principal de teste"""
    print("🚀 Teste de Integração Cursor -> Codespace")
    print("=" * 50)
    
    testes = [
        ("Teste Básico", teste_basico),
        ("Teste Matemático", teste_matematico), 
        ("Teste Bibliotecas", teste_bibliotecas),
        ("Teste Arquivo", teste_arquivo)
    ]
    
    resultados = {}
    
    for nome, funcao in testes:
        print(f"\n🔬 {nome}")
        print("-" * 30)
        try:
            resultado = funcao()
            resultados[nome] = {"status": "sucesso", "resultado": resultado}
            print(f"✅ {nome}: OK")
        except Exception as e:
            resultados[nome] = {"status": "erro", "erro": str(e)}
            print(f"❌ {nome}: {e}")
    
    print("\n📊 Resumo Final:")
    print("=" * 50)
    sucessos = sum(1 for r in resultados.values() if r["status"] == "sucesso")
    print(f"✅ Sucessos: {sucessos}/{len(testes)}")
    
    if sucessos == len(testes):
        print("🎉 Todos os testes passaram! Integração funcionando perfeitamente!")
    else:
        print("⚠️ Alguns testes falharam. Verifique a configuração.")
    
    return resultados

if __name__ == "__main__":
    # Para usar no Cursor:
    # 1. Salve este arquivo (Ctrl+S)
    # 2. Execute via bridge: 
    #    curl -X POST http://localhost:3001/execute-remote \
    #      -H "Content-Type: application/json" \
    #      -d '{"command": "python3 exemplo_cursor.py"}'
    # 
    # 3. Ou use a extensão: Ctrl+Shift+R
    
    resultados = main()
    print(f"\n🎯 Execução concluída. Resultados: {len(resultados)} testes")
