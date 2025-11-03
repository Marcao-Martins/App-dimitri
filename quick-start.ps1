#!/usr/bin/env pwsh
# Script de início rápido para o ambiente de desenvolvimento GDAV
# Garante a execução com pwsh (PowerShell 7+) e define a política de execução.

# Verifica se está rodando no PowerShell 7+ (pwsh.exe). Se não, relança com pwsh.
if ($PSVersionTable.PSEdition -ne 'Core') {
    Write-Host "Este script requer PowerShell 7+ (pwsh.exe)." -ForegroundColor Yellow
    Write-Host "Relancando o script com pwsh..." -ForegroundColor Cyan
    try {
        # Tenta relançar o script com pwsh, passando os mesmos argumentos
        pwsh -NoProfile -File $MyInvocation.MyCommand.Path @Args
    } catch {
        Write-Host "Falha ao executar pwsh. Verifique se o PowerShell 7+ está instalado e no seu PATH." -ForegroundColor Red
        Write-Host "Instale em: https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows"
    }
    # Sai do script atual (powershell.exe) após a tentativa de relançamento
    exit
}

# Banner
Write-Host @"
=================================================
   GDAV - Quick Start
=================================================
"@ -ForegroundColor Green

Write-Host "`nIniciando GDAV..." -ForegroundColor Cyan

# Define a política de execução como 'Bypass' apenas para esta sessão do pwsh
try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction Stop
    Write-Host "Politica de execucao definida como 'Bypass' para esta sessao." -ForegroundColor Green
} catch {
    Write-Host "Nao foi possivel definir a politica de execucao. Tentando continuar..." -ForegroundColor Yellow
}

# Obtém o diretório do script atual e executa o script principal 'start.ps1'
$scriptPath = Join-Path $PSScriptRoot "start.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Host "Erro: O script 'start.ps1' nao foi encontrado no diretorio." -ForegroundColor Red
    exit 1
}

# Executa o script de inicialização principal, passando todos os parâmetros
# O '&' é o operador de chamada, que executa o comando/script.
& $scriptPath @Args
