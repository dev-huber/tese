#!/usr/bin/env python3
"""
Exemplo simples de uso do túnel Cursor-Codespace
Execute: python3 exemplo.py
"""

def teste_basico():
    """Teste básico do ambiente Python"""
    import sys
    print(f"🐍 Python {sys.version_info.major}.{sys.version_info.minor}")
    print(f"📍 Rodando no Codespace!")
    return "OK"

def teste_bibliotecas():
    """Teste de bibliotecas disponíveis"""
    libs = ['numpy', 'pandas', 'matplotlib']
    for lib in libs:
        try:
            __import__(lib)
            print(f"✅ {lib}")
        except ImportError:
            print(f"❌ {lib}")

def main():
    print("🚀 Teste do Túnel Cursor-Codespace")
    print("=" * 35)
    teste_basico()
    teste_bibliotecas()
    print("✅ Teste concluído!")

if __name__ == "__main__":
    main()
