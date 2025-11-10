#!/usr/bin/env pwsh
# Script de inicialização automática do GDAV
# Inicia backend Dart Frog e frontend Flutter

param(
    [switch]$SkipBackend,
    [switch]$SkipFrontend,
    [switch]$ProductionMode,
    [int]$BackendPort = 8080
)

$ErrorActionPreference = "Stop"
$workspaceRoot = $PSScriptRoot

# Cores para output
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Step { param($msg) Write-Host "`n═══ $msg ═══" -ForegroundColor Magenta }

# Banner
Write-Host @"
╔════════════════════════════════════════════════╗
║   GDAV - Startup Script                       ║
║   Backend: Dart Frog | Frontend: Flutter      ║
╚════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# 1. Verificar dependências
Write-Step "Verificando Dependências"

# Verificar Dart
Write-Info "Verificando Dart SDK..."
try {
    $dartVersion = dart --version 2>&1 | Out-String
    Write-Success "Dart encontrado: $($dartVersion.Trim())"
} catch {
    Write-Error "Dart não encontrado. Instale: https://dart.dev/get-dart"
    exit 1
}

# Verificar Flutter
if (-not $SkipFrontend) {
    Write-Info "Verificando Flutter SDK..."
    try {
        $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
        Write-Success "Flutter encontrado: $flutterVersion"
    } catch {
        Write-Error "Flutter não encontrado. Instale: https://flutter.dev/docs/get-started/install"
        exit 1
    }
}

# Verificar Dart Frog CLI
$dartFrogPath = "C:\Users\gerso\AppData\Local\Pub\Cache\bin\dart_frog.bat"
if (-not $SkipBackend) {
    Write-Info "Verificando Dart Frog CLI..."
    try {
        $dartFrogVersion = & $dartFrogPath --version 2>&1 | Out-String
        Write-Success "Dart Frog encontrado: $($dartFrogVersion.Trim())"
    } catch {
        Write-Warning "Dart Frog não encontrado. Instalando..."
        dart pub global activate dart_frog_cli
        Write-Success "Dart Frog instalado com sucesso"
    }
}

# 2. Preparar Backend
if (-not $SkipBackend) {
    Write-Step "Preparando Backend"
    
    $backendPath = Join-Path $workspaceRoot "backend"
    
    if (-not (Test-Path $backendPath)) {
        Write-Error "Diretório backend não encontrado: $backendPath"
        exit 1
    }
    
    Set-Location $backendPath
    
    # Instalar dependências
    Write-Info "Instalando dependências do backend..."
    dart pub get
    Write-Success "Dependências instaladas"
    
    # Verificar arquivos de dados
    $dataPath = Join-Path $backendPath "data"
    $csvFile = Join-Path $dataPath "farmacos_veterinarios.csv"
    
    if (-not (Test-Path $dataPath)) {
        Write-Info "Criando diretório data..."
        New-Item -ItemType Directory -Path $dataPath | Out-Null
    }
    
    if (-not (Test-Path $csvFile)) {
        Write-Info "Copiando arquivo de dados..."
        $sourceCsv = Join-Path $workspaceRoot "farmacos_veterinarios.csv"
        if (Test-Path $sourceCsv) {
            Copy-Item $sourceCsv $csvFile
            Write-Success "Arquivo de dados copiado"
        } else {
            Write-Warning "Arquivo farmacos_veterinarios.csv não encontrado"
        }
    }
    
    # Criar arquivo de usuários se não existir
    $usersFile = Join-Path $dataPath "users.json"
    if (-not (Test-Path $usersFile)) {
        Write-Info "Criando arquivo de usuários..."
        "[]" | Out-File -FilePath $usersFile -Encoding UTF8
        Write-Success "Arquivo users.json criado"
    }
    
    # Iniciar servidor backend
    Write-Info "Iniciando servidor backend na porta $BackendPort..."
    
    $env:PORT = $BackendPort
    
    if ($ProductionMode) {
        Write-Info "Modo: PRODUÇÃO"
        $backendJob = Start-Job -ScriptBlock {
            param($path, $port)
            Set-Location $path
            $env:PORT = $port
            dart_frog build
            dart run build/bin/server.dart
        } -ArgumentList $backendPath, $BackendPort
    } else {
        Write-Info "Modo: DESENVOLVIMENTO (aceitando conexões na rede local)"
        # Usar Start-Process para iniciar em nova janela
        $backendProcess = Start-Process pwsh -ArgumentList @(
            "-NoExit",
            "-Command",
            "cd '$backendPath'; & '$dartFrogPath' dev --port $BackendPort --hostname 0.0.0.0"
        ) -PassThru -WindowStyle Minimized
        
        # Salvar o ID do processo para poder parar depois
        $global:BackendProcessId = $backendProcess.Id
        Write-Info "Backend iniciado em processo separado (PID: $($backendProcess.Id))"
    }
    
    # Aguardar backend iniciar
    Write-Info "Aguardando backend iniciar..."
    Start-Sleep -Seconds 10
    
    # Testar conexão
    $maxRetries = 15
    $retryCount = 0
    $backendReady = $false
    
    while ($retryCount -lt $maxRetries -and -not $backendReady) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$BackendPort/" -TimeoutSec 3 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $backendReady = $true
                Write-Success "Backend online em http://localhost:$BackendPort"
                Write-Success "Backend acessível na rede em http://172.20.10.4:$BackendPort"
            }
        } catch {
            $retryCount++
            Write-Info "Tentativa $retryCount/$maxRetries..."
            Start-Sleep -Seconds 3
        }
    }
    
    if (-not $backendReady) {
        Write-Error "Backend não respondeu após $maxRetries tentativas"
        if ($ProductionMode -and $backendJob) {
            Stop-Job $backendJob
            Remove-Job $backendJob
        } elseif ($global:BackendProcessId) {
            Stop-Process -Id $global:BackendProcessId -Force -ErrorAction SilentlyContinue
        }
        exit 1
    }
    
    Set-Location $workspaceRoot
}

# 3. Preparar Frontend
if (-not $SkipFrontend) {
    Write-Step "Preparando Frontend"
    
    # Instalar dependências
    Write-Info "Instalando dependências do Flutter..."
    flutter pub get
    Write-Success "Dependências instaladas"
    
    # Configurar URL do backend no código
    Write-Info "Configurando URL do backend..."
    $apiConfigPath = Join-Path $workspaceRoot "lib\core\config\api_config.dart"
    if (Test-Path $apiConfigPath) {
        # O arquivo já tem a configuração correta
        Write-Success "Configuração da API pronta"
    }
    
    # Iniciar Flutter
    Write-Info "Iniciando aplicativo Flutter..."
    
    if ($ProductionMode) {
        Write-Info "Modo: PRODUÇÃO (Release)"
        $flutterJob = Start-Job -ScriptBlock {
            param($path)
            Set-Location $path
            flutter run --release
        } -ArgumentList $workspaceRoot
    } else {
        Write-Info "Modo: DESENVOLVIMENTO (Debug)"
        # No modo dev, rodamos flutter run no terminal atual (não em job)
        # para permitir hot reload interativo
        Write-Success "Frontend pronto para iniciar"
        Write-Host "`n"
        Write-Host "════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "  BACKEND rodando em: http://localhost:$BackendPort" -ForegroundColor Green
        Write-Host "════════════════════════════════════════════════" -ForegroundColor Green
        Write-Host "`n"
        Write-Info "Iniciando Flutter (pressione 'q' para sair)..."
        Write-Host "`n"
        
        flutter run
        
        # Após flutter encerrar, parar o backend
        if (-not $SkipBackend) {
            Write-Info "`nEncerrando backend..."
            Stop-Job $backendJob
            Remove-Job $backendJob
        }
        
        exit 0
    }
}

# 4. Monitoramento (apenas em modo produção)
if ($ProductionMode) {
    Write-Step "Serviços Iniciados"
    Write-Success "Backend: http://localhost:$BackendPort"
    Write-Success "Frontend: Executando em segundo plano"
    Write-Host "`n"
    Write-Info "Jobs ativos:"
    Get-Job
    Write-Host "`n"
    Write-Warning "Para parar os serviços, execute: Get-Job | Stop-Job; Get-Job | Remove-Job"
}

# 5. Informações úteis
Write-Step "Informações Úteis"
Write-Host @"
Endpoints disponíveis:
  • GET    /api/v1/farmacos              - Lista todos os fármacos
  • GET    /api/v1/farmacos/search?q=    - Busca fármacos
  • GET    /api/v1/farmacos/species/:id  - Fármacos por espécie
  • POST   /api/v1/auth/register         - Registrar usuário
  • POST   /api/v1/auth/login            - Login
  • GET    /api/v1/auth/validate         - Validar token

Criar administrador (execute no PowerShell):
  curl -X POST http://localhost:$BackendPort/api/v1/auth/register ```
  -H "Content-Type: application/json" ```
  -d '{\"email\":\"admin@gdav.com\",\"password\":\"Admin@123\"}'

Logs:
  • Backend: Veja os logs no job em execução
  • Frontend: Logs aparecem no terminal do Flutter

Comandos úteis:
  • flutter run           - Inicia Flutter com hot reload
  • flutter run --release - Inicia em modo release
  • dart_frog dev         - Inicia backend em dev mode
  • dart test            - Executa testes do backend
"@ -ForegroundColor Yellow

Write-Host "`n"
Write-Success "Setup concluído!"
