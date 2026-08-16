@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem ==== Persoenliche Angaben (bei Bedarf anpassen) ====
set "NACHNAME=Senger"
set "VORNAME=Tizian"
set "MATRIKEL=IU14143428"
set "KURS=DLBDSPBDM01_D"
set "PHASE=Erarbeitungs-Reflexionsphase"

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

call :compile main.tex KZ
if errorlevel 1 goto :fehler

call :compile presentation.tex PR
if errorlevel 1 goto :fehler

echo.
echo Fertig. Erzeugte Datei(en) tragen bereits den PebblePad-Abgabenamen.
echo Vergiss nicht, die .sql-Datei(en) separat zu benennen (Typ SQL).
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
del /q "%OUTNAME%.aux" "%OUTNAME%.log" "%OUTNAME%.out" "%OUTNAME%.nav" "%OUTNAME%.snm" "%OUTNAME%.toc" "%OUTNAME%.vrb" 2>nul
exit /b 0

:fehler
echo.
echo [Fehler] Kompilierung fehlgeschlagen. Details in der zugehoerigen .log Datei.
pause
exit /b 1
