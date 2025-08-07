#!/usr/bin/env python3
"""
Exemplo de processamento pesado no Codespace
Execute este arquivo no Cursor para ver a diferença de performance
"""

import time
import numpy as np

def processamento_pesado():
    """Simulação de processamento que exige recursos"""
    print("🚀 Iniciando processamento pesado no Codespace...")
    
    # Operação que consome CPU
    inicio = time.time()
    
    # Criar matriz grande
    matriz = np.random.rand(5000, 5000)
    print(f"📊 Matriz criada: {matriz.shape}")
    
    # Operações matemáticas pesadas
    resultado = np.linalg.svd(matriz[:1000, :1000])  # SVD é computacionalmente pesado
    
    fim = time.time()
    tempo = fim - inicio
    
    print(f"⚡ Processamento concluído em {tempo:.2f} segundos")
    print(f"💪 Poder computacional do Codespace utilizado!")
    
    return tempo

def analise_de_dados():
    """Simulação de análise de dados"""
    import pandas as pd
    
    print("\n📈 Análise de dados...")
    
    # Criar dataset grande
    dados = {
        'valores': np.random.randn(100000),
        'categorias': np.random.choice(['A', 'B', 'C'], 100000),
        'timestamps': pd.date_range('2024-01-01', periods=100000, freq='T')
    }
    
    df = pd.DataFrame(dados)
    print(f"📋 Dataset criado: {df.shape}")
    
    # Análises
    estatisticas = df.groupby('categorias')['valores'].agg(['mean', 'std', 'count'])
    print(f"📊 Estatísticas por categoria:")
    print(estatisticas)
    
    return df.shape[0]

def machine_learning_exemplo():
    """Exemplo de ML que precisa de poder computacional"""
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import accuracy_score
    
    print("\n🤖 Treinando modelo de Machine Learning...")
    
    # Gerar dados sintéticos
    X = np.random.randn(10000, 20)
    y = (X[:, 0] + X[:, 1] > 0).astype(int)
    
    # Split dos dados
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
    
    # Treinar modelo (computacionalmente intensivo)
    inicio = time.time()
    modelo = RandomForestClassifier(n_estimators=100, random_state=42)
    modelo.fit(X_train, y_train)
    
    # Predição
    y_pred = modelo.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    
    fim = time.time()
    tempo_treino = fim - inicio
    
    print(f"🎯 Acurácia: {accuracy:.4f}")
    print(f"⏱️ Tempo de treinamento: {tempo_treino:.2f} segundos")
    
    return accuracy

def main():
    print("🌉 Demonstração do Poder do Túnel Cursor-Codespace")
    print("=" * 60)
    print("💻 Interface: Cursor (local)")
    print("⚡ Processamento: Codespace (nuvem)")
    print("=" * 60)
    
    try:
        # Processamento pesado
        tempo1 = processamento_pesado()
        
        # Análise de dados
        linhas = analise_de_dados()
        
        # Machine Learning
        accuracy = machine_learning_exemplo()
        
        print("\n" + "=" * 60)
        print("🎉 DEMONSTRAÇÃO CONCLUÍDA!")
        print(f"⚡ Processamento matricial: {tempo1:.2f}s")
        print(f"📊 Linhas processadas: {linhas:,}")
        print(f"🤖 Acurácia ML: {accuracy:.4f}")
        print("💪 Todo o poder computacional rodou no Codespace!")
        print("🖥️ Você só usou o Cursor como interface!")
        
    except Exception as e:
        print(f"❌ Erro: {e}")
        print("💡 Certifique-se de que as bibliotecas estão instaladas")

if __name__ == "__main__":
    main()
