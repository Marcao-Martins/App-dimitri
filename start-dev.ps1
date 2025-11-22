<#
start-dev.ps1

Single script to:
 - fetch DB credentials from AWS Secrets Manager
 - start backend (in new PowerShell window) with DB_* env vars
 - start Flutter frontend (in new PowerShell window) configured to talk to backend

Usage:
  Open PowerShell as needed and run:
    .\start-dev.ps1

Environment variables used/optional:
  $env:AWS_SECRET_ID     (default: prod)
  $env:AWS_REGION        (default: us-east-1)
  $env:BACKEND_PORT      (default: 8080)
  $env:DISABLE_AWS_SECRETS (if 'true' disables secret lookup)

Notes:
 - Requires `aws` CLI configured and `dart` + `flutter` SDKs installed.
 - This script opens two new PowerShell windows (backend and frontend).
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Fail($msg) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    exit 1
}

Write-Host "== start-dev: starting full dev environment ==`n"

# Defaults
$secretId = $env:AWS_SECRET_ID
if (-not $secretId) { $secretId = 'prod' }
$region = $env:AWS_REGION
if (-not $region) { $region = 'us-east-1' }
$backendPort = if ($env:BACKEND_PORT) { $env:BACKEND_PORT } else { '8080' }
$disableAws = $env:DISABLE_AWS_SECRETS -eq 'true'

# 1) Ensure required CLIs
if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
    Fail "Dart SDK not found. Install Dart SDK before running this script."
}
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "Warning: Flutter SDK not found. Frontend won't start." -ForegroundColor Yellow
}

# 2) Fetch secret (if possible)
$secretJson = $null
if (-not $disableAws -and (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "Fetching secret '$secretId' from AWS Secrets Manager in region '$region'..."
    $awsOutput = & aws secretsmanager get-secret-value --secret-id $secretId --region $region --query SecretString --output text 2>&1
    if ($LASTEXITCODE -eq 0 -and $awsOutput) {
        try {
            $secretJson = $awsOutput | ConvertFrom-Json -ErrorAction Stop
            Write-Host "Secret parsed successfully." -ForegroundColor Green
        } catch {
            Write-Host "Failed to parse secret JSON: $_" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Could not retrieve secret (aws returned non-zero). Falling back to existing DB_* env vars." -ForegroundColor DarkGray
    }
} else {
    Write-Host "Skipping AWS Secrets retrieval (DISABLE_AWS_SECRETS=true or aws CLI not found)." -ForegroundColor DarkGray
}

# Prepare env values (string escape)
function Get-SecretProp($obj, $propName) {
    if ($null -eq $obj) { return $null }
    $props = $obj.PSObject.Properties | ForEach-Object { $_.Name }
    if ($props -contains $propName) { return $obj.$propName }
    return $null
}

$envDbHost = $null
$envDbPort = $null
$envDbUser = $null
$envDbPass = $null
$envDbName = $null

if ($secretJson) {
    $envDbHost = Get-SecretProp $secretJson 'host'
    if (-not $envDbHost) { $envDbHost = Get-SecretProp $secretJson 'hostname' }

    $envDbPort = Get-SecretProp $secretJson 'port'
    if ($envDbPort) { $envDbPort = $envDbPort.ToString() }

    $envDbUser = Get-SecretProp $secretJson 'username'
    if (-not $envDbUser) { $envDbUser = Get-SecretProp $secretJson 'user' }

    $envDbPass = Get-SecretProp $secretJson 'password'

    $envDbName = Get-SecretProp $secretJson 'db'
    if (-not $envDbName) { $envDbName = Get-SecretProp $secretJson 'database' }
}

if (-not $envDbHost) { $envDbHost = $env:DB_HOST }
if (-not $envDbPort) { $envDbPort = $env:DB_PORT }
if (-not $envDbUser) { $envDbUser = $env:DB_USER }
if (-not $envDbPass) { $envDbPass = $env:DB_PASSWORD }
if (-not $envDbName) { $envDbName = $env:DB_NAME }
if (-not $envDbName) { $envDbName = 'gdav' }

# Show masked info
Write-Host "Backend port: $backendPort"
if ($envDbHost) { Write-Host "DB host: $envDbHost" } else { Write-Host "DB host: <not set>" -ForegroundColor Yellow }
if ($envDbUser) { Write-Host "DB user: $envDbUser" } else { Write-Host "DB user: <not set>" -ForegroundColor Yellow }
if ($envDbPass) { Write-Host "DB password: **** (hidden)" } else { Write-Host "DB password: <not set>" -ForegroundColor Yellow }
if ($envDbName) { Write-Host "DB name: $envDbName" } else { Write-Host "DB name: <not set>" -ForegroundColor Yellow }

# 3) Build backend start command
$backendCmd = @"
`$env:DB_HOST = '${envDbHost}'; `$env:DB_PORT = '${envDbPort}'; `$env:DB_USER = '${envDbUser}'; `$env:DB_PASSWORD = '${envDbPass}'; if ('${envDbName}' -ne '') { `$env:DB_NAME='${envDbName}'; }
Write-Host "[backend] running in $(Get-Location) with DB_HOST=$env:DB_HOST..."
cd `"$PSScriptRoot\backend`"
dart pub get
# run quick analyze (non-fatal)
dart analyze
if ($LASTEXITCODE -ne 0) { Write-Host "[backend] dart analyze returned non-zero" -ForegroundColor Yellow }
# run connection test
Write-Host "[backend] running connection test..."
dart run scripts/test_connection.dart
if (`$LASTEXITCODE -ne 0) { Write-Host "[backend] connection test failed" -ForegroundColor Red; exit 1 }
# start server
if (Get-Command dart_frog -ErrorAction SilentlyContinue) { Write-Host "[backend] starting dart_frog dev..."; dart_frog dev } else { Write-Host "[backend] starting with dart run..."; dart run }
"@

# 4) Build frontend start command
$backendUrl = "http://localhost:$backendPort"
$frontendCmd = @"
Write-Host "[frontend] starting with BACKEND_URL=$backendUrl"
`$env:BACKEND_URL = '$backendUrl'
cd `"$PSScriptRoot`"
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    # Try web on chrome first; fallback to flutter run
    try {
        Write-Host "[frontend] launching Flutter (web) using chrome..."
        flutter run -d chrome
    } catch {
        Write-Host "[frontend] flutter run failed, try generic run..." -ForegroundColor Yellow
        flutter run
    }
} else {
    Write-Host "Flutter not installed; skipping frontend start." -ForegroundColor Yellow
}
"@

# 5) Start backend in new PowerShell window
Write-Host "Opening backend window..."
Start-Process -FilePath powershell -ArgumentList ('-NoExit','-Command', $backendCmd)

# 6) Start frontend in new PowerShell window (delay slightly to allow backend to start)
Start-Sleep -Seconds 2
Write-Host "Opening frontend window..."
Start-Process -FilePath powershell -ArgumentList ('-NoExit','-Command', $frontendCmd)

Write-Host "Done. Two windows opened: backend and frontend (if Flutter available)." -ForegroundColor Green
Write-Host "If you prefer single-window mode, run backend and frontend commands manually."