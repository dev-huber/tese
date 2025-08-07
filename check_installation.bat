@echo off
REM Script de verificação pós-instalação do túnel Cursor-Codespace (Windows)

echo 🔍 Verificação Pós-Instalação - Cursor-Codespace Túnel
echo =======================================================
echo.

set INSTALL_DIR=%USERPROFILE%\cursor-codespace-bridge
set CURSOR_EXT_DIR=%USERPROFILE%\.cursor\extensions\codespace-tunnel
set CODESPACE_URL=https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev

set PREREQ_OK=true
set BRIDGE_OK=true
set EXTENSION_OK=true
set CONNECTIVITY_OK=true

REM Verificar pré-requisitos
echo 📋 Verificando pré-requisitos...

REM Verificar Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js - NÃO ENCONTRADO
    set PREREQ_OK=false
) else (
    for /f %%i in ('node --version') do echo ✅ Node.js: %%i
)

REM Verificar NPM
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ NPM - NÃO ENCONTRADO
    set PREREQ_OK=false
) else (
    for /f %%i in ('npm --version') do echo ✅ NPM: %%i
)

REM Verificar cURL
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ cURL - NÃO ENCONTRADO
    set PREREQ_OK=false
) else (
    for /f "tokens=2" %%i in ('curl --version ^| findstr curl') do echo ✅ cURL: %%i
)

echo.

REM Verificar instalação do bridge
echo 📦 Verificando instalação do bridge...

if not exist "%INSTALL_DIR%" (
    echo ❌ Diretório de instalação - FALTANDO: %INSTALL_DIR%
    set BRIDGE_OK=false
) else (
    echo ✅ Diretório de instalação
)

if not exist "%INSTALL_DIR%\cursor_bridge.js" (
    echo ❌ Bridge principal - FALTANDO: cursor_bridge.js
    set BRIDGE_OK=false
) else (
    echo ✅ Bridge principal
)

if not exist "%INSTALL_DIR%\start_bridge.bat" (
    echo ❌ Script de inicialização - FALTANDO: start_bridge.bat
    set BRIDGE_OK=false
) else (
    echo ✅ Script de inicialização
)

if not exist "%INSTALL_DIR%\codespace.bat" (
    echo ❌ Script de comando - FALTANDO: codespace.bat
    set BRIDGE_OK=false
) else (
    echo ✅ Script de comando
)

echo.

REM Verificar extensão Cursor
echo 🔌 Verificando extensão Cursor...

if not exist "%CURSOR_EXT_DIR%" (
    echo ❌ Diretório da extensão - FALTANDO: %CURSOR_EXT_DIR%
    set EXTENSION_OK=false
) else (
    echo ✅ Diretório da extensão
)

if not exist "%CURSOR_EXT_DIR%\package.json" (
    echo ❌ Manifesto da extensão - FALTANDO: package.json
    set EXTENSION_OK=false
) else (
    echo ✅ Manifesto da extensão
)

if not exist "%CURSOR_EXT_DIR%\extension.js" (
    echo ❌ Código da extensão - FALTANDO: extension.js
    set EXTENSION_OK=false
) else (
    echo ✅ Código da extensão
)

echo.

REM Testar conectividade
echo 🌐 Testando conectividade...
curl -s -I "%CODESPACE_URL%" | find "200" >nul
if %errorlevel% equ 0 (
    echo ✅ Codespace acessível: %CODESPACE_URL%
) else (
    echo ❌ Codespace não acessível: %CODESPACE_URL%
    set CONNECTIVITY_OK=false
)

echo.

REM Testar bridge local
echo 🔗 Testando bridge local...
netstat -an | findstr :3001 >nul
if %errorlevel% equ 0 (
    echo ✅ Bridge rodando na porta 3001
) else (
    echo ⚠️ Bridge não está rodando na porta 3001
)

echo.

REM Teste funcional básico
echo 🧪 Teste funcional básico...
if "%BRIDGE_OK%"=="true" if "%CONNECTIVITY_OK%"=="true" (
    echo 🚀 Executando teste remoto...
    "%INSTALL_DIR%\codespace.bat" run "python -c \"print('✅ Teste OK!')\"" 2>nul | find "✅ Teste OK!" >nul
    if %errorlevel% equ 0 (
        echo ✅ Teste funcional passou!
    ) else (
        echo ❌ Teste funcional falhou
    )
) else (
    echo ⚠️ Pulando teste funcional (pré-requisitos não atendidos)
)

echo.

REM Resumo final
echo 📊 RESUMO DA VERIFICAÇÃO
echo ========================
echo.

if "%PREREQ_OK%"=="true" (
    echo ✅ Pré-requisitos: OK
) else (
    echo ❌ Pré-requisitos: FALHA
)

if "%BRIDGE_OK%"=="true" (
    echo ✅ Bridge instalado: OK
) else (
    echo ❌ Bridge instalado: FALHA
)

if "%EXTENSION_OK%"=="true" (
    echo ✅ Extensão Cursor: OK
) else (
    echo ❌ Extensão Cursor: FALHA
)

if "%CONNECTIVITY_OK%"=="true" (
    echo ✅ Conectividade: OK
) else (
    echo ❌ Conectividade: FALHA
)

echo.

REM Instruções finais
if "%PREREQ_OK%"=="true" if "%BRIDGE_OK%"=="true" if "%EXTENSION_OK%"=="true" if "%CONNECTIVITY_OK%"=="true" (
    echo 🎉 INSTALAÇÃO COMPLETA E FUNCIONAL!
    echo.
    echo 🚀 Próximos passos:
    echo 1. Iniciar bridge:
    echo    %INSTALL_DIR%\start_bridge.bat
    echo.
    echo 2. Abrir Cursor e usar:
    echo    - Ctrl+Shift+R: Executar comando remoto
    echo    - Ctrl+Shift+S: Sincronizar arquivo
    echo.
    echo 3. Teste via terminal:
    echo    %INSTALL_DIR%\codespace.bat run "python -c \"print('Hello from Codespace!')\""
    echo.
    echo 📚 Documentação completa: CURSOR_SETUP.md
) else (
    echo ⚠️ INSTALAÇÃO INCOMPLETA
    echo.
    echo 🔧 Ações necessárias:
    
    if "%PREREQ_OK%"=="false" (
        echo - Instalar pré-requisitos (Node.js, npm, curl)
    )
    
    if "%BRIDGE_OK%"=="false" (
        echo - Reinstalar bridge (executar script de instalação)
    )
    
    if "%EXTENSION_OK%"=="false" (
        echo - Reinstalar extensão Cursor
    )
    
    if "%CONNECTIVITY_OK%"=="false" (
        echo - Verificar se o servidor Codespace está rodando
        echo - Executar: python dev_server.py no Codespace
    )
    
    echo.
    echo 💡 Execute o script de instalação novamente ou consulte CURSOR_SETUP.md
)

echo.
pause
