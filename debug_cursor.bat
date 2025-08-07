@echo off
REM Script de diagnóstico rápido para Ctrl+Shift+R (Windows)

echo 🔍 DIAGNÓSTICO: Por que Ctrl+Shift+R não funciona?
echo =================================================
echo.

set CURSOR_EXT_DIR=%USERPROFILE%\.cursor\extensions\codespace-tunnel
set BRIDGE_DIR=%USERPROFILE%\cursor-codespace-bridge
set CODESPACE_URL=https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
set PROBLEMS=0

REM 1. Verificar extensão
echo 1️⃣ Verificando extensão Cursor...
if exist "%CURSOR_EXT_DIR%" (
    echo ✅ Diretório da extensão existe: %CURSOR_EXT_DIR%
    
    if exist "%CURSOR_EXT_DIR%\package.json" (
        echo ✅ package.json encontrado
    ) else (
        echo ❌ package.json NÃO encontrado
        set /a PROBLEMS+=1
    )
    
    if exist "%CURSOR_EXT_DIR%\extension.js" (
        echo ✅ extension.js encontrado
        for %%i in ("%CURSOR_EXT_DIR%\extension.js") do echo    Tamanho: %%~zi bytes
    ) else (
        echo ❌ extension.js NÃO encontrado
        set /a PROBLEMS+=1
    )
) else (
    echo ❌ Extensão NÃO instalada em: %CURSOR_EXT_DIR%
    echo 💡 Solução: Executar install_cursor_tunnel.bat
    set /a PROBLEMS+=1
)

echo.

REM 2. Verificar bridge
echo 2️⃣ Verificando bridge local...
if exist "%BRIDGE_DIR%" (
    echo ✅ Bridge instalado em: %BRIDGE_DIR%
    
    REM Verificar se está rodando
    netstat -an | findstr :3001 >nul
    if %errorlevel% equ 0 (
        echo ✅ Bridge rodando na porta 3001
    ) else (
        echo ❌ Bridge NÃO está rodando na porta 3001
        echo 💡 Solução: %BRIDGE_DIR%\start_bridge.bat
        set /a PROBLEMS+=1
    )
    
    REM Testar conectividade
    curl -s -f http://localhost:3001/health >nul 2>&1
    if %errorlevel% equ 0 (
        echo ✅ Bridge responde em http://localhost:3001
    ) else (
        echo ❌ Bridge não responde
        echo 💡 Verifique se está rodando: tasklist ^| findstr node.exe
    )
) else (
    echo ❌ Bridge NÃO instalado
    echo 💡 Solução: Executar install_cursor_tunnel.bat
    set /a PROBLEMS+=1
)

echo.

REM 3. Verificar Codespace
echo 3️⃣ Verificando conectividade Codespace...
curl -s -I "%CODESPACE_URL%" | find "200" >nul
if %errorlevel% equ 0 (
    echo ✅ Codespace acessível: %CODESPACE_URL%
) else (
    echo ❌ Codespace não acessível
    echo 💡 Verifique se o servidor está rodando no Codespace
)

echo.

REM 4. Verificar Cursor
echo 4️⃣ Verificando Cursor...
tasklist | findstr /I cursor.exe >nul
if %errorlevel% equ 0 (
    echo ✅ Cursor está rodando
    for /f %%i in ('tasklist /FI "IMAGENAME eq cursor.exe" ^| find /C "cursor.exe"') do echo    Processos: %%i
) else (
    echo ❌ Cursor não está rodando
    echo 💡 Inicie o Cursor primeiro
    set /a PROBLEMS+=1
)

echo.

REM 5. Teste funcional
echo 5️⃣ Teste funcional...
if exist "%BRIDGE_DIR%\codespace.bat" (
    echo 🧪 Testando comando remoto...
    "%BRIDGE_DIR%\codespace.bat" run "python -c \"print('✅ Teste OK!')\"" 2>nul | find "✅ Teste OK!" >nul
    if %errorlevel% equ 0 (
        echo ✅ Comando remoto funciona!
    ) else (
        echo ❌ Comando remoto falhou
    )
) else (
    echo ⚠️ Não foi possível testar comando remoto
)

echo.

REM Resumo e soluções
echo 📋 RESUMO E SOLUÇÕES
echo ====================

if not exist "%CURSOR_EXT_DIR%\package.json" (
    echo ❌ PROBLEMA: Extensão não instalada corretamente
    echo    💡 SOLUÇÃO: install_cursor_tunnel.bat
)

netstat -an | findstr :3001 >nul
if %errorlevel% neq 0 (
    echo ❌ PROBLEMA: Bridge não está rodando
    echo    💡 SOLUÇÃO: %BRIDGE_DIR%\start_bridge.bat
)

tasklist | findstr /I cursor.exe >nul
if %errorlevel% neq 0 (
    echo ❌ PROBLEMA: Cursor não está rodando
    echo    💡 SOLUÇÃO: Abrir Cursor IDE
)

echo.

if %PROBLEMS% equ 0 (
    echo 🎉 TUDO PARECE OK!
    echo.
    echo 🔧 Se Ctrl+Shift+R ainda não funciona, tente:
    echo 1. No Cursor: Ctrl+Shift+P → 'Developer: Reload Window'
    echo 2. Ou use: Ctrl+Shift+P → 'Codespace: Execute Remote Command'
    echo 3. Ou teste na web: http://localhost:3001
    echo.
    echo 📋 Comandos alternativos:
    echo    %BRIDGE_DIR%\codespace.bat run "python -c \"print('Hello!')\""
    echo    curl -X POST http://localhost:3001/execute -H "Content-Type: application/json" -d "{\"command\": \"python -c \\\"print('Hello!')\\\"\"}"
) else (
    echo ⚠️ %PROBLEMS% problema^(s^) encontrado^(s^)
    echo    Corrija os problemas acima e teste novamente
)

echo.
echo 📚 Documentação completa: TROUBLESHOOTING.md
echo.
pause
