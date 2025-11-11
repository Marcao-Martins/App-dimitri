# Script para salvar o banner LBW VET no projeto
# Execute este script depois de copiar a imagem do banner

param(
    [string]$ImagePath
)

$targetPath = "assets\images\banner_lbwvet.png"

Write-Host "`n╔══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🖼️  Salvando Banner LBW VET no Projeto  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Verifica se o caminho da imagem foi fornecido
if (-not $ImagePath) {
    Write-Host "❌ Por favor, forneça o caminho da imagem do banner" -ForegroundColor Red
    Write-Host "`nUso:" -ForegroundColor Yellow
    Write-Host "  .\save-banner.ps1 -ImagePath 'C:\caminho\para\banner_lbwvet.png'`n" -ForegroundColor White
    Write-Host "Ou copie manualmente a imagem para:" -ForegroundColor Yellow
    Write-Host "  $targetPath`n" -ForegroundColor White
    exit 1
}

# Verifica se o arquivo existe
if (-not (Test-Path $ImagePath)) {
    Write-Host "❌ Arquivo não encontrado: $ImagePath`n" -ForegroundColor Red
    exit 1
}

# Verifica se é uma imagem
$validExtensions = @('.png', '.jpg', '.jpeg', '.webp')
$extension = [System.IO.Path]::GetExtension($ImagePath).ToLower()

if ($extension -notin $validExtensions) {
    Write-Host "❌ O arquivo deve ser uma imagem (PNG, JPG, JPEG, ou WEBP)`n" -ForegroundColor Red
    exit 1
}

# Cria o diretório se não existir
$targetDir = Split-Path $targetPath -Parent
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# Copia a imagem
try {
    Copy-Item -Path $ImagePath -Destination $targetPath -Force
    Write-Host "✓ Banner salvo com sucesso em: $targetPath" -ForegroundColor Green
    
    # Mostra informações sobre a imagem
    $fileInfo = Get-Item $targetPath
    Write-Host "`n📊 Informações da imagem:" -ForegroundColor Cyan
    Write-Host "  • Tamanho: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" -ForegroundColor White
    Write-Host "  • Caminho: $($fileInfo.FullName)" -ForegroundColor White
    
    Write-Host "`n✅ Configuração concluída!" -ForegroundColor Green
    Write-Host "   O banner será exibido em:" -ForegroundColor White
    Write-Host "   • Seção 'Mural' na página principal" -ForegroundColor Gray
    Write-Host "   • Clicável, abrindo https://lbwvet.com/" -ForegroundColor Gray
    Write-Host "`n💡 Execute 'flutter pub get' para atualizar os assets`n" -ForegroundColor Yellow
    
} catch {
    Write-Host "❌ Erro ao copiar a imagem: $($_.Exception.Message)`n" -ForegroundColor Red
    exit 1
}
