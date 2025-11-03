#!/usr/bin/env pwsh
# Fix Admin Role - Corrige o role do usuário admin diretamente

Write-Host "`n🔧 Corrigindo role do administrador..." -ForegroundColor Cyan

$usersFile = "backend\data\users.json"

if (-not (Test-Path $usersFile)) {
    Write-Host "❌ Arquivo users.json não encontrado!`n" -ForegroundColor Red
    exit 1
}

# Ler usuários
$users = Get-Content $usersFile -Raw | ConvertFrom-Json

# Encontrar e atualizar o admin
$updated = $false
foreach ($user in $users) {
    if ($user.email -eq "admin@gdav.com") {
        if ($user.role -ne "administrator") {
            $user.role = "administrator"
            $updated = $true
            Write-Host "✓ Role atualizado de '$($user.role)' para 'administrator'" -ForegroundColor Green
        } else {
            Write-Host "✓ Role já está correto: administrator" -ForegroundColor Green
        }
    }
}

if ($updated) {
    # Salvar arquivo
    $users | ConvertTo-Json -Depth 10 | Set-Content $usersFile -Encoding UTF8
    Write-Host "✓ Arquivo salvo`n" -ForegroundColor Green
    Write-Host "⚠️  REINICIE O BACKEND para aplicar as mudanças!" -ForegroundColor Yellow
    Write-Host "   Execute: .\stop.ps1 e depois .\start.ps1`n" -ForegroundColor Gray
} elseif (-not $updated -and $users.email -contains "admin@gdav.com") {
    Write-Host "`n✅ Nada para fazer - role já está correto!`n" -ForegroundColor Green
} else {
    Write-Host "`n❌ Usuário admin@gdav.com não encontrado!`n" -ForegroundColor Red
    Write-Host "Execute: .\create-admin.ps1`n" -ForegroundColor Yellow
}
