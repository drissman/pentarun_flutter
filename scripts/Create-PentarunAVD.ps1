# ============================================================================
# Create-PentarunAVD.ps1
# Crée un AVD Android 36 (tablette 10") avec la Logitech BRIO comme caméra
# et lance l'émulateur prêt pour flutter run
#
# Usage (PowerShell admin) :
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\scripts\Create-PentarunAVD.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

# ── Chemins ──────────────────────────────────────────────────────────────────
$SDK       = "$env:LOCALAPPDATA\Android\Sdk"
$EMULATOR  = "$SDK\emulator\emulator.exe"
$ADB       = "$SDK\platform-tools\adb.exe"
$SYSIMAGE  = "system-images\android-36\google_apis_playstore\x86_64"
$AVD_NAME  = "pentarun_tablet"
$AVD_DIR   = "$env:USERPROFILE\.android\avd\$AVD_NAME.avd"
$AVD_INI   = "$env:USERPROFILE\.android\avd\$AVD_NAME.ini"

# ── Couleurs console ──────────────────────────────────────────────────────────
function OK   { param($msg) Write-Host "  [OK] $msg" -ForegroundColor Green  }
function INFO { param($msg) Write-Host "  [..] $msg" -ForegroundColor Cyan   }
function WARN { param($msg) Write-Host "  [!!] $msg" -ForegroundColor Yellow }
function FAIL { param($msg) Write-Host "  [XX] $msg" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "  PENTARUN — Création AVD Android 36 + Logitech BRIO" -ForegroundColor Magenta
Write-Host "  ════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""

# ── 1. Vérifications préalables ───────────────────────────────────────────────
INFO "Vérification du SDK Android..."
if (-not (Test-Path $EMULATOR)) { FAIL "emulator.exe introuvable : $EMULATOR" }
OK "emulator.exe trouvé"

if (-not (Test-Path $ADB)) { FAIL "adb.exe introuvable : $ADB" }
OK "adb.exe trouvé"

$sysImagePath = "$SDK\$SYSIMAGE"
if (-not (Test-Path $sysImagePath)) {
    FAIL "System image introuvable : $sysImagePath`nInstalle-la via Android Studio > SDK Manager > Android 36 > Google Play x86_64"
}
OK "System image android-36/google_apis_playstore/x86_64 présente"

# ── 2. Vérifier si l'AVD existe déjà ─────────────────────────────────────────
if (Test-Path $AVD_DIR) {
    WARN "L'AVD '$AVD_NAME' existe déjà."
    $rep = Read-Host "  Recréer ? (o/N)"
    if ($rep -ne "o" -and $rep -ne "O") {
        INFO "AVD conservé tel quel — passage au lancement."
        goto Launch
    }
    INFO "Suppression de l'ancien AVD..."
    Remove-Item -Recurse -Force $AVD_DIR
    if (Test-Path $AVD_INI) { Remove-Item -Force $AVD_INI }
    OK "Ancien AVD supprimé"
}

# ── 3. Créer le dossier AVD ───────────────────────────────────────────────────
INFO "Création du dossier AVD..."
New-Item -ItemType Directory -Force -Path $AVD_DIR | Out-Null
OK "Dossier créé : $AVD_DIR"

# ── 4. Fichier pointeur .ini ──────────────────────────────────────────────────
INFO "Écriture du fichier pointeur ($AVD_NAME.ini)..."
$iniContent = @"
avd.ini.encoding=UTF-8
path=$AVD_DIR
path.rel=avd\$AVD_NAME.avd
target=android-36
"@
Set-Content -Path $AVD_INI -Value $iniContent -Encoding UTF8
OK "Pointeur écrit"

# ── 5. Fichier config.ini principal ──────────────────────────────────────────
INFO "Écriture de config.ini (tablette 10'', RAM 4 Go, GPU host)..."
$configContent = @"
AvdId=$AVD_NAME
PlayStore.enabled=true
abi.type=x86_64
avd.ini.displayname=Pentarun Tablet (BRIO)
avd.ini.encoding=UTF-8

# Stockage
disk.cachePartition=yes
disk.cachePartition.size=300MB
disk.dataPartition.size=6442450944
sdcard.size=512M

# Caméra — Logitech BRIO mappée sur front ET back
hw.camera.back=webcam0
hw.camera.front=webcam0

# CPU / RAM
hw.cpu.arch=x86_64
hw.cpu.ncore=4
hw.ramSize=4096
vm.heapSize=512

# Écran tablette 10'' WUXGA (1920x1200 @ 240dpi)
hw.lcd.width=1920
hw.lcd.height=1200
hw.lcd.density=240
hw.initialOrientation=landscape
skin.name=1920x1200
skin.path=_no_skin
skin.dynamic=yes

# GPU — utilise le GPU Windows directement
hw.gpu.enabled=yes
hw.gpu.mode=host

# Capteurs
hw.accelerometer=yes
hw.gps=yes
hw.gyroscope=yes
hw.sensors.orientation=yes
hw.sensors.proximity=no

# Réseau
runtime.network.latency=none
runtime.network.speed=full

# Misc
hw.audioInput=yes
hw.battery=yes
hw.dPad=no
hw.keyboard=yes
hw.mainKeys=no
hw.sdCard=yes
hw.trackBall=no
fastboot.forceColdBoot=no
showDeviceFrame=no

# System image
image.sysdir.1=$SYSIMAGE\
tag.display=Google Play
tag.id=google_apis_playstore
"@
Set-Content -Path "$AVD_DIR\config.ini" -Value $configContent -Encoding UTF8
OK "config.ini écrit"

# ── 6. Vérification webcam ────────────────────────────────────────────────────
Write-Host ""
INFO "Détection des webcams disponibles sur ce système..."
$webcams = Get-PnpDevice -Class Camera -Status OK 2>$null
if ($webcams) {
    $webcams | ForEach-Object { OK "Webcam détectée : $($_.FriendlyName)" }
} else {
    WARN "Impossible de lister les webcams via PnP — la BRIO sera détectée au démarrage de l'émulateur"
}

# ── 7. Résumé ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ════════════════════════════════════════════════════" -ForegroundColor Magenta
OK "AVD '$AVD_NAME' créé avec succès !"
Write-Host ""
Write-Host "  Configuration :" -ForegroundColor White
Write-Host "    Android 36 (API 36) · Google Play Store" -ForegroundColor Gray
Write-Host "    Tablette 10'' 1920x1200 · 4 Go RAM · GPU host" -ForegroundColor Gray
Write-Host "    Caméra front + back : webcam0 (Logitech BRIO)" -ForegroundColor Gray
Write-Host ""

# ── 8. Lancement émulateur ────────────────────────────────────────────────────
:Launch
$rep2 = Read-Host "  Lancer l'émulateur maintenant ? (O/n)"
if ($rep2 -eq "n" -or $rep2 -eq "N") {
    Write-Host ""
    INFO "Pour lancer manuellement :"
    Write-Host "  $EMULATOR -avd $AVD_NAME -gpu host -no-snapshot-load" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host ""
INFO "Démarrage de l'émulateur (30-60s la première fois)..."
INFO "La Logitech BRIO sera accessible dans l'app via l'icône caméra."
Write-Host ""

# Démarrage en arrière-plan pour ne pas bloquer le terminal
$proc = Start-Process -FilePath $EMULATOR `
    -ArgumentList "-avd $AVD_NAME -gpu host -no-snapshot-load -camera-back webcam0 -camera-front webcam0" `
    -PassThru -WindowStyle Normal

INFO "Émulateur lancé (PID $($proc.Id)) — attente device ADB..."

# Attendre que adb détecte l'émulateur (max 120s)
$timeout = 120
$elapsed = 0
do {
    Start-Sleep -Seconds 3
    $elapsed += 3
    $devices = & $ADB devices 2>$null | Select-String "emulator"
    if ($devices) { break }
    Write-Host "    ... $elapsed s" -ForegroundColor DarkGray
} while ($elapsed -lt $timeout)

if ($devices) {
    Write-Host ""
    OK "Émulateur prêt : $devices"
    Write-Host ""
    Write-Host "  ════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  Depuis WSL2, lance :" -ForegroundColor White
    Write-Host ""
    Write-Host "    export ADB_SERVER_SOCKET=tcp:`$(cat /etc/resolv.conf | grep nameserver | awk '{print `$2}'):5037" -ForegroundColor Yellow
    Write-Host "    flutter devices" -ForegroundColor Yellow
    Write-Host "    flutter run -d emulator-5554" -ForegroundColor Yellow
    Write-Host ""
} else {
    WARN "Timeout — l'émulateur démarre encore. Relance 'flutter devices' dans WSL2 dans 1 minute."
}
