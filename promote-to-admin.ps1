#!/usr/bin/env pwsh
# Script para promover usuario a administrador

Write-Host "`n====================================`n" -ForegroundColor Cyan
Write-Host "  Promover Usuario para Admin" -ForegroundColor Cyan
Write-Host "`n====================================`n" -ForegroundColor Cyan

$usersFile = "backend\data\users.json"

if (-not (Test-Path $usersFile)) {
    Write-Host "ERRO: Arquivo users.json nao encontrado!" -ForegroundColor Red
    Write-Host "O backend precisa ser iniciado pelo menos uma vez.`n" -ForegroundColor Yellow
    exit 1
}

# Pedir o email do usuario
Write-Host "Digite o email do usuario que deseja promover a admin:" -ForegroundColor Yellow
Write-Host "(Exemplo: seu@email.com)`n" -ForegroundColor Gray
$targetEmail = Read-Host "Email"

if ([string]::IsNullOrWhiteSpace($targetEmail)) {
    Write-Host "`nERRO: Email nao pode estar vazio!`n" -ForegroundColor Red
    exit 1
}

# Ler usuarios
try {
    $users = Get-Content $usersFile -Raw | ConvertFrom-Json
    Write-Host "OK: Arquivo carregado`n" -ForegroundColor Green
} catch {
    Write-Host "ERRO ao ler arquivo: $($_.Exception.Message)`n" -ForegroundColor Red
    exit 1
}

# Encontrar e atualizar o usuario
$found = $false
$wasAdmin = $false

foreach ($user in $users) {
    if ($user.email -eq $targetEmail) {
        $found = $true
        $wasAdmin = $user.role -eq "administrator"
        
        if (-not $wasAdmin) {
            Write-Host "Usuario encontrado:" -ForegroundColor Green
            Write-Host "   Nome: $($user.name)" -ForegroundColor Gray
            Write-Host "   Email: $($user.email)" -ForegroundColor Gray
            Write-Host "   Role atual: $($user.role)" -ForegroundColor Gray
            Write-Host ""
            
            $confirm = Read-Host "Deseja promover este usuario a ADMIN? (S/N)"
            
            if ($confirm -eq "S" -or $confirm -eq "s") {
                $user.role = "administrator"
                Write-Host "`nOK: Usuario promovido para ADMIN!`n" -ForegroundColor Green
            } else {
                Write-Host "`nOperacao cancelada.`n" -ForegroundColor Yellow
                exit 0
            }
        } else {
            Write-Host "AVISO: Este usuario ja e administrador!`n" -ForegroundColor Yellow
        }
        break
    }
}

if (-not $found) {
    Write-Host "ERRO: Usuario com email '$targetEmail' nao encontrado!`n" -ForegroundColor Red
    Write-Host "Usuarios cadastrados:`n" -ForegroundColor Yellow
    foreach ($user in $users) {
        Write-Host "   - $($user.email) ($($user.name))" -ForegroundColor Gray
    }
    Write-Host ""
    exit 1
}

# Salvar arquivo
try {
    $users | ConvertTo-Json | Set-Content $usersFile -Encoding UTF8
    Write-Host "OK: Arquivo atualizado!`n" -ForegroundColor Green
} catch {
    Write-Host "ERRO ao salvar arquivo: $($_.Exception.Message)`n" -ForegroundColor Red
    exit 1
}

# Oferecer para reiniciar o backend
Write-Host "O backend precisa ser reiniciado para aplicar as mudancas.`n" -ForegroundColor Yellow
$restart = Read-Host "Deseja reiniciar o backend agora? (S/N)"

if ($restart -eq "S" -or $restart -eq "s") {
    Write-Host "`nReiniciando backend...`n" -ForegroundColor Cyan
    
    # Parar processos Dart Frog em execucao
    $processes = Get-Process | Where-Object { $_.ProcessName -like "*dart*" -or $_.ProcessName -like "*frog*" }
    if ($processes) {
        $processes | Stop-Process -Force
        Write-Host "OK: Processos encerrados`n" -ForegroundColor Green
        Start-Sleep -Seconds 2
    }
    
    Write-Host "Iniciando backend em nova janela...`n" -ForegroundColor Cyan
    Start-Process pwsh -ArgumentList "-Command", "cd '$PSScriptRoot' && dart_frog dev" -NoNewWindow:$false
    
    Write-Host "OK: Backend iniciado!`n" -ForegroundColor Green
} else {
    Write-Host "Lembre-se de reiniciar o backend manualmente.`n" -ForegroundColor Yellow
}

Write-Host "====================================`n" -ForegroundColor Cyan
Write-Host "Setup concluido!" -ForegroundColor Green
Write-Host "Faca login com $targetEmail para ter acesso ao painel de admin`n" -ForegroundColor Green
Write-Host "====================================`n" -ForegroundColor Cyan
