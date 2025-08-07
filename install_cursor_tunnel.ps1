# PowerShell script para instalar túnel Cursor -> Codespace no Windows
# Execute: iwr -useb https://raw.githubusercontent.com/dev-huber/tese/main/install_cursor_tunnel.ps1 | iex

Write-Host "🎯 Instalador do Túnel Cursor -> Codespace (Windows)" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Função para verificar pré-requisitos
function Check-Prerequisites {
    Write-Host "🔍 Verificando pré-requisitos..." -ForegroundColor Yellow
    
    # Verificar Node.js
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            Write-Host "   ✅ Node.js: $nodeVersion" -ForegroundColor Green
        } else {
            throw "Node.js não encontrado"
        }
    } catch {
        Write-Host "   ❌ Node.js não encontrado" -ForegroundColor Red
        Write-Host "   💡 Instale Node.js: https://nodejs.org" -ForegroundColor Blue
        Write-Host "   💡 Ou use: winget install OpenJS.NodeJS" -ForegroundColor Blue
        return $false
    }
    
    # Verificar curl (ou usar Invoke-WebRequest como alternativa)
    try {
        $curlVersion = curl --version 2>$null
        if ($curlVersion) {
            Write-Host "   ✅ curl: disponível" -ForegroundColor Green
        } else {
            Write-Host "   ℹ️ curl não encontrado, usando PowerShell WebRequest" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ℹ️ Usando PowerShell WebRequest" -ForegroundColor Yellow
    }
    
    # Verificar conectividade com Codespace
    Write-Host "   🌐 Testando conectividade com Codespace..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev" -Method Head -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Codespace: acessível" -ForegroundColor Green
        } else {
            throw "Codespace não acessível"
        }
    } catch {
        Write-Host "   ❌ Codespace não acessível" -ForegroundColor Red
        Write-Host "   💡 Verifique se o servidor está rodando no Codespace" -ForegroundColor Blue
        return $false
    }
    
    return $true
}

# Função para instalar bridge local
function Install-Bridge {
    Write-Host "📦 Instalando bridge local..." -ForegroundColor Yellow
    
    # Criar diretório
    $installDir = "$env:USERPROFILE\cursor-codespace-bridge"
    if (!(Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }
    Set-Location $installDir
    
    # Baixar arquivos
    Write-Host "   📥 Baixando cursor_bridge.js..." -ForegroundColor Blue
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/dev-huber/tese/main/cursor_bridge.js" -OutFile "cursor_bridge.js"
        Write-Host "   ✅ cursor_bridge.js baixado" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Erro ao baixar cursor_bridge.js" -ForegroundColor Red
        return $false
    }
    
    # Criar script de inicialização para Windows
    $startScript = @"
@echo off
set BRIDGE_DIR=%USERPROFILE%\cursor-codespace-bridge
set PROJECT_DIR=%1
if "%PROJECT_DIR%"=="" set PROJECT_DIR=%cd%

echo 🚀 Iniciando Cursor-Codespace Bridge...
echo    Bridge: %BRIDGE_DIR%
echo    Projeto: %PROJECT_DIR%
echo.

cd /d "%BRIDGE_DIR%"
node cursor_bridge.js "%PROJECT_DIR%"
"@
    
    $startScript | Out-File -FilePath "start_bridge.bat" -Encoding ascii
    Write-Host "   ✅ Script de inicialização criado: start_bridge.bat" -ForegroundColor Green
    
    Write-Host "   ✅ Bridge instalado em: $installDir" -ForegroundColor Green
    return $true
}

# Função para instalar extensão Cursor
function Install-CursorExtension {
    Write-Host "🔌 Instalando extensão Cursor..." -ForegroundColor Yellow
    
    # Diretório da extensão Cursor no Windows
    $cursorExtDir = "$env:USERPROFILE\.cursor\extensions\codespace-tunnel"
    
    if (!(Test-Path $cursorExtDir)) {
        New-Item -ItemType Directory -Path $cursorExtDir -Force | Out-Null
    }
    
    # Baixar arquivos da extensão
    Write-Host "   📥 Baixando package.json..." -ForegroundColor Blue
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/package.json" -OutFile "$cursorExtDir\package.json"
        Write-Host "   ✅ package.json baixado" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Erro ao baixar package.json" -ForegroundColor Red
        return $false
    }
    
    Write-Host "   📥 Baixando extension.js..." -ForegroundColor Blue
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/dev-huber/tese/main/cursor-extension/extension.js" -OutFile "$cursorExtDir\extension.js"
        Write-Host "   ✅ extension.js baixado" -ForegroundColor Green
    } catch {
        Write-Host "   ❌ Erro ao baixar extension.js" -ForegroundColor Red
        return $false
    }
    
    Write-Host "   ✅ Extensão instalada em: $cursorExtDir" -ForegroundColor Green
    Write-Host "   💡 Reinicie o Cursor para ativar a extensão" -ForegroundColor Blue
    return $true
}

# Função para criar scripts de automação
function Create-AutomationScripts {
    Write-Host "🤖 Criando scripts de automação..." -ForegroundColor Yellow
    
    $scriptDir = "$env:USERPROFILE\cursor-codespace-bridge"
    
    # Script PowerShell para comandos remotos
    $remoteScript = @'
param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    [Parameter(Mandatory=$false)]
    [string]$Parameter
)

$CODESPACE_URL = "https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev"

function Invoke-CodespaceCommand {
    param($Command)
    
    $body = @{
        command = $Command
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$CODESPACE_URL/execute" -Method Post -Body $body -ContentType "application/json"
        return $response
    } catch {
        Write-Host "❌ Erro: $_" -ForegroundColor Red
        return $null
    }
}

function Sync-File {
    param($FilePath)
    
    if (!(Test-Path $FilePath)) {
        Write-Host "❌ Arquivo não encontrado: $FilePath" -ForegroundColor Red
        return
    }
    
    $content = Get-Content $FilePath -Raw
    $body = @{
        path = $FilePath
        content = $content
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$CODESPACE_URL/sync" -Method Post -Body $body -ContentType "application/json"
        return $response
    } catch {
        Write-Host "❌ Erro: $_" -ForegroundColor Red
        return $null
    }
}

switch ($Action.ToLower()) {
    "run" {
        if (!$Parameter) {
            Write-Host "❌ Uso: .\remote.ps1 run 'comando'" -ForegroundColor Red
            exit 1
        }
        Write-Host "🚀 Executando no Codespace: $Parameter" -ForegroundColor Yellow
        $result = Invoke-CodespaceCommand -Command $Parameter
        if ($result) {
            Write-Host "📤 STDOUT:" -ForegroundColor Green
            Write-Host $result.stdout
            if ($result.stderr) {
                Write-Host "❌ STDERR:" -ForegroundColor Red
                Write-Host $result.stderr
            }
            Write-Host "✅ Código de saída: $($result.returncode)" -ForegroundColor Green
        }
    }
    "sync" {
        if (!$Parameter) {
            Write-Host "❌ Uso: .\remote.ps1 sync <arquivo>" -ForegroundColor Red
            exit 1
        }
        Write-Host "🔄 Sincronizando: $Parameter" -ForegroundColor Yellow
        $result = Sync-File -FilePath $Parameter
        if ($result -and $result.status -eq "success") {
            Write-Host "✅ $($result.message)" -ForegroundColor Green
        }
    }
    "status" {
        Write-Host "📊 Status do Codespace:" -ForegroundColor Yellow
        try {
            $response = Invoke-WebRequest -Uri $CODESPACE_URL -Method Get -TimeoutSec 5
            Write-Host "✅ Servidor online" -ForegroundColor Green
        } catch {
            Write-Host "❌ Servidor offline" -ForegroundColor Red
        }
    }
    default {
        Write-Host "🎯 Cursor-Codespace Remote Control (Windows)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Comandos disponíveis:" -ForegroundColor Yellow
        Write-Host "  .\remote.ps1 run 'comando'    # Executar comando no Codespace" -ForegroundColor White
        Write-Host "  .\remote.ps1 sync arquivo     # Sincronizar arquivo para Codespace" -ForegroundColor White
        Write-Host "  .\remote.ps1 status           # Verificar status do Codespace" -ForegroundColor White
        Write-Host ""
        Write-Host "Exemplos:" -ForegroundColor Yellow
        Write-Host "  .\remote.ps1 run 'python exemplo.py'" -ForegroundColor White
        Write-Host "  .\remote.ps1 sync meu_script.py" -ForegroundColor White
    }
}
'@
    
    $remoteScript | Out-File -FilePath "$scriptDir\remote.ps1" -Encoding UTF8
    Write-Host "   ✅ Script PowerShell criado: remote.ps1" -ForegroundColor Green
    
    # Script batch simples
    $batchScript = @"
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0remote.ps1" %*
"@
    
    $batchScript | Out-File -FilePath "$scriptDir\codespace.bat" -Encoding ascii
    Write-Host "   ✅ Script batch criado: codespace.bat" -ForegroundColor Green
    
    return $true
}

# Função para mostrar instruções finais
function Show-FinalInstructions {
    Write-Host ""
    Write-Host "🎉 Instalação concluída com sucesso!" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 O que foi instalado:" -ForegroundColor Yellow
    Write-Host "   ✅ Bridge local em: $env:USERPROFILE\cursor-codespace-bridge" -ForegroundColor White
    Write-Host "   ✅ Extensão Cursor" -ForegroundColor White
    Write-Host "   ✅ Scripts de automação" -ForegroundColor White
    Write-Host ""
    Write-Host "🚀 Como usar:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. 🌉 Bridge Local:" -ForegroundColor Cyan
    Write-Host "   cd seu-projeto" -ForegroundColor White
    Write-Host "   $env:USERPROFILE\cursor-codespace-bridge\start_bridge.bat" -ForegroundColor White
    Write-Host ""
    Write-Host "2. 🎮 PowerShell:" -ForegroundColor Cyan
    Write-Host "   cd $env:USERPROFILE\cursor-codespace-bridge" -ForegroundColor White
    Write-Host "   .\remote.ps1 run 'python exemplo.py'" -ForegroundColor White
    Write-Host "   .\remote.ps1 sync arquivo.py" -ForegroundColor White
    Write-Host ""
    Write-Host "3. 🔌 Extensão Cursor:" -ForegroundColor Cyan
    Write-Host "   - Reinicie o Cursor" -ForegroundColor White
    Write-Host "   - Ctrl+Shift+R: Executar comando" -ForegroundColor White
    Write-Host "   - Ctrl+Shift+S: Sincronizar arquivo" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 Configuração da extensão:" -ForegroundColor Yellow
    Write-Host "   - Abra Cursor > Settings (Ctrl+,)" -ForegroundColor White
    Write-Host "   - Procure 'Codespace Tunnel'" -ForegroundColor White
    Write-Host "   - URL: https://super-trout-5gpv6wrgxgq53p6r9-8000.app.github.dev" -ForegroundColor White
    Write-Host ""
    Write-Host "✨ Teste rápido:" -ForegroundColor Yellow
    Write-Host "   .\remote.ps1 run 'python -c \"print(\"Hello from Codespace!\")\"'" -ForegroundColor White
}

# Função principal
function Main {
    if (!(Check-Prerequisites)) {
        Write-Host ""
        Write-Host "❌ Pré-requisitos não atendidos. Instale as dependências e tente novamente." -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    
    if (!(Install-Bridge)) {
        Write-Host "❌ Falha ao instalar bridge" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    
    if (!(Install-CursorExtension)) {
        Write-Host "❌ Falha ao instalar extensão Cursor" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    
    if (!(Create-AutomationScripts)) {
        Write-Host "❌ Falha ao criar scripts de automação" -ForegroundColor Red
        exit 1
    }
    
    Show-FinalInstructions
}

# Executar
Main
