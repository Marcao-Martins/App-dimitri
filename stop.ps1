#!/usr/bin/env pwsh
# Script para parar todos os serviços

Write-Host "`n🛑 Parando serviços GDAV...`n" -ForegroundColor Yellow

# Parar todos os jobs
$jobs = Get-Job
if ($jobs) {
    Write-Host "Parando $($jobs.Count) job(s)..." -ForegroundColor Cyan
    $jobs | Stop-Job
    $jobs | Remove-Job
    Write-Host "✓ Jobs encerrados`n" -ForegroundColor Green
} else {
    Write-Host "Nenhum job em execução`n" -ForegroundColor Gray
}

# Tentar matar processos do dart_frog na porta 8080
try {
    $connections = netstat -ano | Select-String ":8080" | Select-String "LISTENING"
    if ($connections) {
        $connections | ForEach-Object {
            $line = $_.ToString()
            $pid = ($line -split '\s+')[-1]
            Write-Host "Encerrando processo PID $pid..." -ForegroundColor Cyan
            taskkill /PID $pid /F 2>$null
        }
        Write-Host "✓ Processos encerrados`n" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Não foi possível verificar processos na porta 8080`n" -ForegroundColor Yellow
}

Write-Host "✓ Serviços parados`n" -ForegroundColor Green
