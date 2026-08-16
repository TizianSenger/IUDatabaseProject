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

call :compile main.tex BE
if errorlevel 1 goto :fehler

call :compile abstract.tex AB
if errorlevel 1 goto :fehler

echo.
echo Fertig. Erzeugte Datei(en) tragen bereits den PebblePad-Abgabenamen.
echo Vergiss nicht: SQL-Dateien (Typ SQL) und GitHub-Link-PDF (Typ GH) sowie
echo die Ergebnisse aus Phase 1 und 2 gehoeren ebenfalls in die finale ZIP-Datei.
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
del /q "%OUTNAME%.aux" "%OUTNAME%.log" "%OUTNAME%.out" 2>nul
exit /b 0

:fehler
echo.
echo [Fehler] Kompilierung fehlgeschlagen. Details in der zugehoerigen .log Datei.
pause
exit /b 1
