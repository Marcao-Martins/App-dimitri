#!/usr/bin/env pwsh
# Script para criar usuário administrador

param(
    [string]$Email = "admin@gdav.com",
    [string]$Password = "Admin@2024!",
    [int]$Port = 8080
)

$baseUrl = "http://localhost:$Port"

Write-Host "`n╔════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Criar Usuário Administrador                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Email: $Email" -ForegroundColor Yellow
Write-Host "Senha: $('*' * $Password.Length)`n" -ForegroundColor Yellow

# Testar se backend está online
Write-Host "🔍 Verificando backend..." -ForegroundColor Cyan
try {
    $testResponse = Invoke-WebRequest -Uri "$baseUrl/api/v1/farmacos" -TimeoutSec 3 -ErrorAction Stop
    Write-Host "✓ Backend online`n" -ForegroundColor Green
} catch {
    Write-Host "✗ Backend não está rodando!" -ForegroundColor Red
    Write-Host "Execute primeiro: .\start.ps1`n" -ForegroundColor Yellow
    exit 1
}

# Criar usuário
Write-Host "📝 Criando usuário administrador..." -ForegroundColor Cyan

$body = @{
    email = $Email
    password = $Password
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest `
        -Uri "$baseUrl/api/v1/auth/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $body `
        -ErrorAction Stop
    
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "`n✓ Usuário criado com sucesso!`n" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "User ID: $($result.user.id)" -ForegroundColor White
    Write-Host "Email:   $($result.user.email)" -ForegroundColor White
    Write-Host "Role:    $($result.user.role)" -ForegroundColor White
    Write-Host "Token:   $($result.token.Substring(0, 20))..." -ForegroundColor Gray
    Write-Host "═══════════════════════════════════════════════`n" -ForegroundColor Cyan
    
    Write-Host "💡 Use estas credenciais para fazer login no app`n" -ForegroundColor Yellow
    
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    
    if ($statusCode -eq 409) {
        Write-Host "`n⚠ Usuário já existe!" -ForegroundColor Yellow
        Write-Host "Use as credenciais existentes ou escolha outro email`n" -ForegroundColor Gray
    } elseif ($statusCode -eq 400) {
        Write-Host "`n✗ Senha não atende aos requisitos:" -ForegroundColor Red
        Write-Host "  • 8-128 caracteres" -ForegroundColor Gray
        Write-Host "  • Pelo menos 1 maiúscula" -ForegroundColor Gray
        Write-Host "  • Pelo menos 1 minúscula" -ForegroundColor Gray
        Write-Host "  • Pelo menos 1 número" -ForegroundColor Gray
        Write-Host "  • Pelo menos 1 caractere especial (@$!%*?&)`n" -ForegroundColor Gray
    } else {
        Write-Host "`n✗ Erro ao criar usuário: $($_.Exception.Message)`n" -ForegroundColor Red
    }
    exit 1
}

# Testar login
Write-Host "🔐 Testando login..." -ForegroundColor Cyan

$loginBody = @{
    email = $Email
    password = $Password
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest `
        -Uri "$baseUrl/api/v1/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody `
        -ErrorAction Stop
    
    Write-Host "✓ Login bem-sucedido!`n" -ForegroundColor Green
    
} catch {
    Write-Host "✗ Erro ao testar login: $($_.Exception.Message)`n" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Tudo pronto! Você pode usar o aplicativo agora.`n" -ForegroundColor Green
