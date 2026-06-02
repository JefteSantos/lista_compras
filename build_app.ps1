# ═══════════════════════════════════════════════════════════════════════════════
# Build Script — Não Esquece!
# Atualiza a versão, limpa cache e gera APK + AAB (App Bundle para Play Store)
#
# USO:
#   .\build_app.ps1              → Incrementa build number (1.1.1+35 → 1.1.1+36)
#   .\build_app.ps1 -Bump patch  → Incrementa patch       (1.1.1+35 → 1.1.2+36)
#   .\build_app.ps1 -Bump minor  → Incrementa minor       (1.1.1+35 → 1.2.0+36)
#   .\build_app.ps1 -Bump major  → Incrementa major       (1.1.1+35 → 2.0.0+36)
#   .\build_app.ps1 -Version "1.3.0"  → Define versão manualmente (build auto)
#   .\build_app.ps1 -SkipClean   → Pula o flutter clean (mais rápido)
#   .\build_app.ps1 -AabOnly     → Gera apenas AAB (sem APK)
# ═══════════════════════════════════════════════════════════════════════════════

param(
    [ValidateSet("patch", "minor", "major")]
    [string]$Bump = "",
    [string]$Version = "",
    [switch]$SkipClean,
    [switch]$AabOnly
)

$pubspec = "pubspec.yaml"

if (-not (Test-Path $pubspec)) {
    Write-Host "ERRO: $pubspec nao encontrado. Execute este script na raiz do projeto." -ForegroundColor Red
    exit 1
}

$content = Get-Content $pubspec -Raw

# ─── Extrair versão atual ───────────────────────────────────────────────────
if ($content -notmatch "version:\s+(\d+)\.(\d+)\.(\d+)\+(\d+)") {
    Write-Host "ERRO: Formato de versao invalido no pubspec.yaml" -ForegroundColor Red
    exit 1
}

$major = [int]$Matches[1]
$minor = [int]$Matches[2]
$patch = [int]$Matches[3]
$build = [int]$Matches[4]

$oldVersion = "$major.$minor.$patch+$build"
Write-Host ""
Write-Host "  Versao atual: $oldVersion" -ForegroundColor DarkGray

# ─── Calcular nova versão ───────────────────────────────────────────────────
# Build number SEMPRE incrementa (é o versionCode do Android — nunca deve repetir)
$build = $build + 1

if ($Version -ne "") {
    # Versão manual definida pelo parâmetro -Version
    if ($Version -notmatch "^(\d+)\.(\d+)\.(\d+)$") {
        Write-Host "ERRO: Formato invalido. Use: -Version '1.2.0'" -ForegroundColor Red
        exit 1
    }
    $major = [int]$Matches[1]
    $minor = [int]$Matches[2]
    $patch = [int]$Matches[3]
}
elseif ($Bump -eq "major") {
    $major = $major + 1
    $minor = 0
    $patch = 0
}
elseif ($Bump -eq "minor") {
    $minor = $minor + 1
    $patch = 0
}
elseif ($Bump -eq "patch") {
    $patch = $patch + 1
}
# Se nenhum -Bump ou -Version: só incrementa build number

$newVersionName = "$major.$minor.$patch"
$newVersion = "$newVersionName+$build"

# ─── Aplicar no pubspec.yaml ────────────────────────────────────────────────
$newContent = $content -replace "version:\s+\d+\.\d+\.\d+\+\d+", "version: $newVersion"
$newContent | Set-Content $pubspec -NoNewline

Write-Host "  Nova versao:  $newVersion" -ForegroundColor Cyan
Write-Host ""

# ─── Limpeza ────────────────────────────────────────────────────────────────
if (-not $SkipClean) {
    Write-Host "[1/3] Limpando cache (flutter clean)..." -ForegroundColor Gray
    flutter clean | Out-Null
    Write-Host "      Restaurando dependencias (flutter pub get)..." -ForegroundColor Gray
    flutter pub get | Out-Null
} else {
    Write-Host "[1/3] Limpeza pulada (-SkipClean)" -ForegroundColor DarkGray
}

# ─── Build APK ──────────────────────────────────────────────────────────────
if (-not $AabOnly) {
    Write-Host "[2/3] Gerando APK Release..." -ForegroundColor Yellow
    flutter build apk --release

    if ($?) {
        $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
        if (Test-Path $apkPath) {
            $apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 1)
            Write-Host "      APK gerado ($apkSize MB): $apkPath" -ForegroundColor Green
        }
    } else {
        Write-Host "      ERRO no build do APK!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[2/3] APK pulado (-AabOnly)" -ForegroundColor DarkGray
}

# ─── Build AAB (App Bundle para Play Store) ─────────────────────────────────
Write-Host "[3/3] Gerando AAB (App Bundle para Play Store)..." -ForegroundColor Yellow
flutter build appbundle --release

if ($?) {
    $aabPath = "build\app\outputs\bundle\release\app-release.aab"
    if (Test-Path $aabPath) {
        $aabSize = [math]::Round((Get-Item $aabPath).Length / 1MB, 1)
        Write-Host "      AAB gerado ($aabSize MB): $aabPath" -ForegroundColor Green
    }
} else {
    Write-Host "      ERRO no build do AAB!" -ForegroundColor Red
    exit 1
}

# ─── Resumo ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "═══════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host "  Build concluido com sucesso!" -ForegroundColor Green
Write-Host "  Versao: $newVersion" -ForegroundColor Cyan
Write-Host "  versionName: $newVersionName (exibida ao usuario)" -ForegroundColor DarkGray
Write-Host "  versionCode: $build (interna da Play Store)" -ForegroundColor DarkGray
Write-Host "═══════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host ""
