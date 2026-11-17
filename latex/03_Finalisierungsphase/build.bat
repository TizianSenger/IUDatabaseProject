@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem ==== Persoenliche Angaben (bei Bedarf anpassen) ====
set "NACHNAME=Senger"
set "VORNAME=Tizian"
set "MATRIKEL=IU14143428"
set "KURS=DLBDSPBDM01_D"
rem Hinweis: Die Aufgabenstellung nennt die Abschlussphase im Fliesstext "Finalisierungsphase",
rem verwendet im offiziellen Dateinamensbeispiel (Kapitel 4.2) jedoch "Abschlussphase".
rem Falls dein:e Tutor:in eine andere Schreibweise wuenscht, hier anpassen.
set "PHASE=Abschlussphase"

where pdflatex >nul 2>nul
if errorlevel 1 (
    set "MIKTEX_FALLBACK=%LOCALAPPDATA%\Programs\MiKTeX\miktex\bin\x64"
    if exist "!MIKTEX_FALLBACK!\pdflatex.exe" (
        set "PATH=!MIKTEX_FALLBACK!;!PATH!"
    )
)
where pdflatex >nul 2>nul
if errorlevel 1 (
    echo [Fehler] pdflatex wurde nicht gefunden. Ist MiKTeX installiert?
    echo Falls MiKTeX gerade erst installiert wurde: Terminal/Explorer neu starten, damit der PATH aktualisiert wird.
    pause
    exit /b 1
)

rem ==== 1. Datenbank neu aufbauen + Selbsttest, erzeugt metadaten.tex ====
rem (benchmark_ergebnisse.tex ist bereits vorhanden; neu messen mit: python index_benchmark.py)
echo Baue Datenbank auf (install_db.py) ...
python install_db.py --quiet
if errorlevel 1 (
    echo [Fehler] install_db.py fehlgeschlagen - mindestens ein Test ist nicht wie erwartet ausgegangen.
    pause
    exit /b 1
)

rem ==== 2. Einzeldokumente (PebblePad-Typen) ====
call :compile main.tex BE
if errorlevel 1 goto :fehler
call :compile abstract.tex AB
if errorlevel 1 goto :fehler
call :compile sql_doku.tex SQL
if errorlevel 1 goto :fehler
call :compile github.tex GH
if errorlevel 1 goto :fehler

rem ==== 3. Gesamtdokument aller drei Phasen (bindet die PDFs oben ein) ====
call :compile gesamtdokument.tex Gesamtdokumentation
if errorlevel 1 goto :fehler

echo.
echo Fertig. Erzeugte Dateien tragen bereits den PebblePad-Abgabenamen.
echo Die Abgabe-ZIP erzeugst du mit:  powershell -ExecutionPolicy Bypass -File make_zip.ps1
pause
exit /b 0

:compile
set "TEXFILE=%~1"
set "TYP=%~2"
set "OUTNAME=%NACHNAME%-%VORNAME%_%MATRIKEL%_%KURS%_%PHASE%_%TYP%"
echo Kompiliere %TEXFILE% -^> %OUTNAME%.pdf
pdflatex -interaction=nonstopmode -halt-on-error -jobname="%OUTNAME%" "%TEXFILE%"
if errorlevel 1 exit /b 1
pdflatex -interaction=nonstopmode -halt-on-error -jobname="%OUTNAME%" "%TEXFILE%" >nul
pdflatex -interaction=nonstopmode -halt-on-error -jobname="%OUTNAME%" "%TEXFILE%" >nul
del /q "%OUTNAME%.aux" "%OUTNAME%.log" "%OUTNAME%.out" "%OUTNAME%.toc" 2>nul
exit /b 0

:fehler
echo.
echo [Fehler] Kompilierung fehlgeschlagen. Details in der zugehoerigen .log Datei.
pause
exit /b 1
