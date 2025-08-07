@echo off
REM Script batch para instalar túnel Cursor -> Codespace no Windows
REM Execute como administrador se necessário

echo 🎯 Instalador do Túnel Cursor-Codespace (Windows Batch)
echo =======================================================
echo.

REM Verificar se Node.js está instalado
echo 🔍 Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js não encontrado
    echo 💡 Instale Node.js em: https://nodejs.org
    echo 💡 Ou use: winget install OpenJS.NodeJS
    pause
    exit /b 1
) else (
    for /f %%i in ('node --version') do echo ✅ Node.js: %%i
)

REM Verificar conectividade com Codespace
echo 🌐 Testando conectividade...
curl -s -I "https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev" >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Codespace não acessível
    echo 💡 Verifique se o servidor está rodando
    pause
    exit /b 1
) else (
    echo ✅ Codespace acessível
)

echo.
echo 📦 Instalando bridge local...

REM Criar diretório
set INSTALL_DIR=%USERPROFILE%\cursor-codespace-bridge
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
cd /d "%INSTALL_DIR%"

REM Baixar arquivos usando curl (disponível no Windows 10+)
echo 📥 Baixando cursor_bridge.js...
curl -sSL -o cursor_bridge.js "https://raw.githubusercontent.com/dev-huber/tese/main/cursor_bridge.js"
if %errorlevel% neq 0 (
    echo ❌ Erro ao baixar cursor_bridge.js
    pause
    exit /b 1
)
echo ✅ cursor_bridge.js baixado

REM Criar script de inicialização
echo 📝 Criando scripts...
(
echo @echo off
echo set BRIDGE_DIR=%%USERPROFILE%%\cursor-codespace-bridge
echo set PROJECT_DIR=%%1
echo if "%%PROJECT_DIR%%"=="" set PROJECT_DIR=%%cd%%
echo.
echo echo 🚀 Iniciando Cursor-Codespace Bridge...
echo echo    Bridge: %%BRIDGE_DIR%%
echo echo    Projeto: %%PROJECT_DIR%%
echo echo.
echo.
echo cd /d "%%BRIDGE_DIR%%"
echo node cursor_bridge.js "%%PROJECT_DIR%%"
) > start_bridge.bat

echo ✅ start_bridge.bat criado

REM Criar script de comando remoto
(
echo @echo off
echo set CODESPACE_URL=https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
echo.
echo if "%%1"=="run" goto run
echo if "%%1"=="status" goto status
echo if "%%1"=="" goto help
echo goto help
echo.
echo :run
echo if "%%2"=="" goto help
echo echo 🚀 Executando no Codespace: %%2
echo curl -X POST "%%CODESPACE_URL%%/execute" -H "Content-Type: application/json" -d "{\"command\": \"%%2\"}"
echo goto end
echo.
echo :status
echo echo 📊 Testando status do Codespace...
echo curl -s -I "%%CODESPACE_URL%%" ^| find "200" >nul
echo if %%errorlevel%% equ 0 (
echo     echo ✅ Servidor online
echo ^) else (
echo     echo ❌ Servidor offline
echo ^)
echo goto end
echo.
echo :help
echo echo 🎯 Cursor-Codespace Remote Control
echo echo.
echo echo Comandos disponíveis:
echo echo   codespace.bat run "comando"     # Executar no Codespace
echo echo   codespace.bat status            # Verificar status
echo echo.
echo echo Exemplos:
echo echo   codespace.bat run "python exemplo.py"
echo echo   codespace.bat run "pip install requests"
echo.
echo :end
) > codespace.bat

echo ✅ codespace.bat criado

REM Instalar extensão Cursor
echo.
echo 🔌 Instalando extensão Cursor...
set CURSOR_EXT_DIR=%USERPROFILE%\.cursor\extensions\codespace-tunnel
if not exist "%CURSOR_EXT_DIR%" mkdir "%CURSOR_EXT_DIR%"

echo 📥 Baixando extensão...
curl -sSL -o "%CURSOR_EXT_DIR%\package.json" "https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/package.json"
curl -sSL -o "%CURSOR_EXT_DIR%\extension.js" "https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/extension.js"

if %errorlevel% equ 0 (
    echo ✅ Extensão instalada
) else (
    echo ⚠️ Erro ao instalar extensão
)

echo.
echo 🎉 Instalação concluída!
echo =========================
echo.
echo 📋 O que foi instalado:
echo    ✅ Bridge local em: %INSTALL_DIR%
echo    ✅ Scripts de automação
echo    ✅ Extensão Cursor
echo.
echo 🚀 Como usar:
echo.
echo 1. Bridge Local:
echo    %INSTALL_DIR%\start_bridge.bat
echo.
echo 2. Linha de comando:
echo    %INSTALL_DIR%\codespace.bat run "python script.py"
echo    %INSTALL_DIR%\codespace.bat status
echo.
echo 3. Extensão Cursor:
echo    - Reinicie o Cursor
echo    - Ctrl+Shift+R: Executar comando
echo    - Configure URL: https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev
echo.
echo ✨ Teste rápido:
echo    %INSTALL_DIR%\codespace.bat run "python -c \"print('Hello from Codespace!')\""
echo.
echo 💡 Adicione %INSTALL_DIR% ao PATH para usar 'codespace' de qualquer lugar
echo.
pause
