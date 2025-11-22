# start-backend.ps1
# Script para validar configuração, testar conexão com o banco e iniciar o backend
# Uso: execute no PowerShell: .\start-backend.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "== Iniciando verificação do ambiente e backend ==`n"

function Fail($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

# 1) Verificar Dart
if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
    Fail "Dart SDK não encontrado. Instale o Dart SDK e tente novamente."
}
Write-Host "Dart encontrado:" (dart --version 2>$null)

 # 2) If AWS CLI is available and not disabled, attempt to obtain credentials from Secrets Manager
 #    - If a valid secret is found, set DB_* environment variables automatically
 #    - To opt out, set `DISABLE_AWS_SECRETS=true`
 $disableAws = $env:DISABLE_AWS_SECRETS -eq 'true'

 function Get-SecretProp($obj, $propName) {
     if ($null -eq $obj) { return $null }
     $props = $obj.PSObject.Properties | ForEach-Object { $_.Name }
     if ($props -contains $propName) { return $obj.$propName }
     return $null
 }

 if (-not $disableAws -and (Get-Command aws -ErrorAction SilentlyContinue)) {
     $secretId = $env:AWS_SECRET_ID
     if (-not $secretId) { $secretId = 'prod' }
     $region = $env:AWS_REGION
     if (-not $region) { $region = 'us-east-1' }

     Write-Host "aws CLI encontrado — tentando obter secret '$secretId' na região '$region'..."
     $awsOutput = & aws secretsmanager get-secret-value --secret-id $secretId --region $region --query SecretString --output text 2>&1
        if ($LASTEXITCODE -eq 0 -and $awsOutput) {
            # Try ConvertFrom-Json first; if it fails (some secrets may contain keys that collide),
            # fall back to a simple regex extractor for known fields.
            $parsed = $null
            try {
                $parsed = $awsOutput | ConvertFrom-Json -ErrorAction Stop
            } catch {
                Write-Host "Warning: ConvertFrom-Json failed, falling back to regex extraction." -ForegroundColor Yellow
            }

            if ($parsed) {
                $secretJson = $parsed
                $secretHost = Get-SecretProp $secretJson 'host'
                if (-not $secretHost) { $secretHost = Get-SecretProp $secretJson 'hostname' }
                if ($secretHost) { $env:DB_HOST = $secretHost }

                $secretPort = Get-SecretProp $secretJson 'port'
                if ($secretPort) { $env:DB_PORT = $secretPort }

                $secretUser = Get-SecretProp $secretJson 'username'
                if (-not $secretUser) { $secretUser = Get-SecretProp $secretJson 'user' }
                if ($secretUser) { $env:DB_USER = $secretUser }

                $secretPw = Get-SecretProp $secretJson 'password'
                if ($secretPw) { $env:DB_PASSWORD = $secretPw }

                $secretDbName = Get-SecretProp $secretJson 'db'
                if (-not $secretDbName) { $secretDbName = Get-SecretProp $secretJson 'database' }
                if ($secretDbName) { $env:DB_NAME = $secretDbName }

                $secretDbInstance = Get-SecretProp $secretJson 'dbInstanceIdentifier'
                if ($secretDbInstance) { $env:DB_INSTANCE = $secretDbInstance }

                Write-Host "Secret recuperado com sucesso — variáveis DB_* definidas automaticamente (senha ocultada)." -ForegroundColor Green
            } else {
                # Regex fallback (case-insensitive) for common keys
                $txt = $awsOutput
                function Get-FromTxt($k) {
                    $m = [regex]::Match($txt, '"' + [regex]::Escape($k) + '"\s*:\s*"([^"]+)"', 'IgnoreCase')
                    if ($m.Success) { return $m.Groups[1].Value }
                    return $null
                }

                $host = Get-FromTxt 'host'
                if (-not $host) { $host = Get-FromTxt 'hostname' }
                if ($host) { $env:DB_HOST = $host }

                $port = Get-FromTxt 'port'
                if ($port) { $env:DB_PORT = $port }

                $user = Get-FromTxt 'username'
                if (-not $user) { $user = Get-FromTxt 'user' }
                if ($user) { $env:DB_USER = $user }

                $pw = Get-FromTxt 'password'
                if ($pw) { $env:DB_PASSWORD = $pw }

                $dbName = Get-FromTxt 'db'
                if (-not $dbName) { $dbName = Get-FromTxt 'database' }
                if ($dbName) { $env:DB_NAME = $dbName }

                $dbInstance = Get-FromTxt 'dbInstanceIdentifier'
                if ($dbInstance) { $env:DB_INSTANCE = $dbInstance }

                if ($env:DB_HOST -or $env:DB_USER -or $env:DB_PASSWORD) {
                    Write-Host "Secret parsed via regex — variables set (password hidden)." -ForegroundColor Green
                } else {
                    Write-Host "Falha ao parsear o secret JSON: nenhum campo conhecido encontrado." -ForegroundColor Yellow
                }
            }
     } else {
         Write-Host "Não foi possível obter secret '$secretId' (aws CLI retornou erro). Usando variáveis de ambiente DB_*." -ForegroundColor DarkGray
     }
 } else {
     if ($disableAws) {
         Write-Host "Leitura de Secrets Manager desabilitada por DISABLE_AWS_SECRETS=true." -ForegroundColor DarkGray
     } else {
         Write-Host "AWS CLI não encontrado. Usando variáveis de ambiente DB_*." -ForegroundColor DarkGray
     }
 }

# Ensure DB_NAME default
if (-not $env:DB_NAME -or $env:DB_NAME -eq '') { $env:DB_NAME = 'gdav' }

# 3) Entrar na pasta backend
Push-Location -Path "$PSScriptRoot\backend"
try {
    Write-Host "[backend] executando 'dart pub get'..."
    dart pub get

    Write-Host "[backend] executando 'dart analyze'..."
    dart analyze
    if ($LASTEXITCODE -ne 0) { Write-Host "Aviso: 'dart analyze' retornou não-zero (continue)" -ForegroundColor Yellow }

    # 4) Testar conexão com o banco usando o script já presente
    Write-Host "[backend] executando teste de conexão: scripts/test_connection.dart"
    dart run scripts/test_connection.dart
    if ($LASTEXITCODE -ne 0) {
        Fail "Teste de conexão com o banco falhou. Corrija a configuração e tente novamente."
    }

    Write-Host "Conexão com banco OK. Iniciando backend..." -ForegroundColor Green

    # 5) Iniciar servidor Dart Frog (se disponível)
    if (Get-Command dart_frog -ErrorAction SilentlyContinue) {
        Write-Host "Iniciando server com 'dart_frog dev'..."
        dart_frog dev
    } else {
        Write-Host "'dart_frog' não encontrado. Tentando iniciar com 'dart run' (fallback)..." -ForegroundColor Yellow
        Write-Host "Obs: para uma experiência de desenvolvimento, instale e use o CLI 'dart_frog'." -ForegroundColor DarkGray
        dart run
    }
} finally {
    Pop-Location
}
