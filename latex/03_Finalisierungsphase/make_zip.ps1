# Erzeugt die Abgabe-ZIP gemaess Aufgabenstellung, Kapitel 4.2 (Finalisierungsphase):
#   Senger_Tizian_IU14143428_DLBDSPBDM01_D.zip
#     01_Konzeptionsphase/
#     02_Erarbeitungs-Reflexionsphase/
#     03_Finalisierungsphase/
# Enthalten sind nur Abgabedateien (PDF, .sql) plus Quellen/Skripte/DB/Screenshots
# zur Nachvollziehbarkeit -- keine LaTeX-Hilfsdateien.
# Aufruf (im Ordner 03_Finalisierungsphase):
#   powershell -ExecutionPolicy Bypass -File make_zip.ps1

$ErrorActionPreference = 'Stop'
$hier   = Split-Path -Parent $MyInvocation.MyCommand.Path
$latex  = Split-Path -Parent $hier
$name   = 'Senger_Tizian_IU14143428_DLBDSPBDM01_D'
$staging = Join-Path $env:TEMP $name
$zip    = Join-Path $latex "$name.zip"

if (Test-Path $staging) { Remove-Item $staging -Recurse -Force -Confirm:$false }
New-Item -ItemType Directory -Force $staging | Out-Null

$muster = @('*.pdf', '*.sql', '*.tex', '*.py', '*.bat', '*.ps1', '*.md', '*.db', '*.pptx')
foreach ($phase in '01_Konzeptionsphase', '02_Erarbeitungs-Reflexionsphase', '03_Finalisierungsphase') {
    $quelle = Join-Path $latex $phase
    $ziel   = Join-Path $staging $phase
    New-Item -ItemType Directory -Force $ziel | Out-Null
    foreach ($m in $muster) {
        Get-ChildItem -Path $quelle -Filter $m -File | Copy-Item -Destination $ziel
    }
    $shots = Join-Path $quelle 'screenshots'
    if (Test-Path $shots) {
        Copy-Item $shots -Destination $ziel -Recurse
        # interne Screenshot-Anleitung gehoert nicht in die Abgabe
        $anleitung = Join-Path $ziel 'screenshots\README.md'
        if (Test-Path $anleitung) { Remove-Item $anleitung -Force -Confirm:$false }
    }
}
Copy-Item (Join-Path (Split-Path -Parent $latex) 'README.md') -Destination $staging

if (Test-Path $zip) { Remove-Item $zip -Force -Confirm:$false }
Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zip
Remove-Item $staging -Recurse -Force -Confirm:$false
Write-Host "ZIP erstellt: $zip"
