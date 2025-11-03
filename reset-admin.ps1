#!/usr/bin/env pwsh
# Script para resetar usuário administrador

Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Reset Usuário Administrador                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Caminho do arquivo de usuários
$usersFile = "backend\data\users.json"

if (-not (Test-Path $usersFile)) {
    Write-Host "✗ Arquivo users.json não encontrado!" -ForegroundColor Red
    Write-Host "O backend precisa ser iniciado pelo menos uma vez.`n" -ForegroundColor Yellow
    exit 1
}

Write-Host "🔍 Lendo arquivo de usuários..." -ForegroundColor Cyan

try {
    $users = Get-Content $usersFile -Raw | ConvertFrom-Json
    $adminUser = $users | Where-Object { $_.email -eq "admin@gdav.com" }
    
    if ($adminUser) {
        Write-Host "✓ Usuário admin encontrado" -ForegroundColor Green
        Write-Host "  • Role atual: $($adminUser.role)" -ForegroundColor Gray
        
        Write-Host "`n🗑️  Removendo usuário antigo..." -ForegroundColor Cyan
        $users = $users | Where-Object { $_.email -ne "admin@gdav.com" }
        $users | ConvertTo-Json -Depth 10 | Set-Content $usersFile -Encoding UTF8
        Write-Host "✓ Usuário removido`n" -ForegroundColor Green
    } else {
        Write-Host "ℹ Nenhum usuário admin encontrado para remover`n" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "✗ Erro ao ler arquivo: $($_.Exception.Message)`n" -ForegroundColor Red
    exit 1
}

# Criar novo usuário admin
Write-Host "📝 Criando novo usuário administrador..." -ForegroundColor Cyan
Write-Host "   Email: admin@gdav.com" -ForegroundColor Gray
Write-Host "   Senha: Admin@2024!" -ForegroundColor Gray
Write-Host "   Role: administrator`n" -ForegroundColor Gray

.\create-admin.ps1

Write-Host "`n✅ Reset concluído! Use as credenciais para fazer login.`n" -ForegroundColor Green
