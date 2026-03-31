
# Script de Build Automatico para Flutter (Windows)
# Atualiza a versao e gera o APK limpando o cache para evitar erros de plugins

$pubspec = "pubspec.yaml"
$content = Get-Content $pubspec -Raw

# Captura a versao e incrementa a build
if ($content -match "version: (\d+\.\d+\.\d+)\+(\d+)") {
    $vName = $Matches[1]
    $vBuild = [int]$Matches[2] + 1
    $newV = "version: $vName+$vBuild"
    
    # Faz a substituicao e salva
    $newContent = $content -replace "version: \d+\.\d+\.\d+\+\d+", $newV
    $newContent | Set-Content $pubspec -NoNewline
    
    Write-Host "Versao atualizada para: $vName+$vBuild" -ForegroundColor Cyan
}

# Limpeza e Build
Write-Host "Limpando cache (flutter clean)..." -ForegroundColor Gray
flutter clean

Write-Host "Iniciando build do APK Release..." -ForegroundColor Yellow
flutter build apk --release

if ($?) {
    Write-Host "Build concluido com sucesso!" -ForegroundColor Green
} else {
    Write-Host "Erro durante o build." -ForegroundColor Red
}
