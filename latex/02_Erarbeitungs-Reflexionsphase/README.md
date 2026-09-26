# Portfolioteil 2 – Erarbeitungs-/Reflexionsphase

**DBMS: SQLite 3** (serverlos, eine einzelne Datei, frei wählbar laut Aufgabenstellung).

## Inhalt dieses Ordners

- `Senger-Tizian_IU14143428_DLBDSPBDM01_D_Erarbeitungs-Reflexionsphase_SQL.sql` -- vollständiges
  Schema (17 Tabellen: 13 Entitäten + 2 Dreifachbeziehungstabellen + 2 M:N-Verknüpfungstabellen)
  mit NOT NULL/UNIQUE/CHECK/FOREIGN-KEY-Constraints, zwei Triggern für Geschäftsregeln,
  Dummy-Daten (≥ 10 Zeilen je Tabelle) sowie Testfällen (positiv je Entität, plus 6 bewusst
  ungültige Fälle, die an Constraints/Triggern scheitern müssen).
- `buchtausch_app.db` -- aus der `.sql`-Datei generierte SQLite-Datenbank, zur Bequemlichkeit
  bereits mitgeliefert. Damit lassen sich die Testfälle direkt öffnen (z. B. über eine
  VS-Code-SQLite-Extension), ohne das Skript selbst ausführen zu müssen.
- `main.tex` -- Kurze Zusammenfassung der Implementierung (Portfolioteil 2, Typ `KZ`).
- `presentation.tex` -- Präsentation mit 30 Folien (Typ `PR`, offizielle Abgabe als PDF):
  Überblick, je eine Folie pro Entität (CREATE-Statement links, großer Screenshot rechts im
  Zwei-Spalten-Layout), Dreifachbeziehungen, Trigger/Geschäftsregeln, Negativtestfälle,
  Zusammenfassung und Reflexion. Theme: metropolis (modern, flach), kompiliert mit **XeLaTeX**.
- `Senger-..._PR.pptx` -- **inoffizielle, editierbare PowerPoint-Version** desselben Inhalts
  (25 Folien, gleiche Screenshots eingebettet). Laut Aufgabenstellung sind für Phase 2 nur
  **PDF und .sql** als Abgabeformat zugelassen -- die PPTX ist ausschließlich eine bequeme
  Arbeitskopie zum manuellen Nachjustieren/Präsentieren (z. B. auch in Google Slides
  importierbar). Erzeugt/aktualisiert über `python build_pptx.py` (benötigt `python-pptx`
  und `Pillow`, siehe `build_pptx.py`).
- `screenshots/` -- hier fehlen noch die echten Screenshots aus dem DBMS (siehe
  `screenshots/README.md` für die genaue Anleitung und erwarteten Dateinamen). Ohne sie
  zeigt die Präsentation automatisch eine Platzhalterbox mit Erklärung statt eines Bildes.

## So regenerierst du die PDFs

`build.bat` ausführen (kompiliert `main.tex` -> `..._KZ.pdf` und `presentation.tex` ->
`..._PR.pdf`, bereits mit PebblePad-Abgabenamen).

## Formale Vorgaben laut Aufgabenstellung

- `.sql`-Datei(en): Tabellen und Beziehungen gemäß ER-Modell aus Phase 1, mit Dokumentation jedes SQL-Statements. Jede Tabelle benötigt mindestens 10 Einträge (Dummy-Daten) sowie mindestens einen Testfall (Abfrage).
- Präsentations-PDF mit mindestens 15 Folien:
  - Für jede Entität eine Folie mit dem SQL-Statement, einem Testfall und einem Screenshot aus dem Datenbankmanagementsystem.
  - Kurze Zusammenfassung der Implementierung (mindestens 0,5 Seiten).

Dateibenennung (PebblePad): `Nachname-Vorname_Matrikelnummer_DLBDSPBDM01_D_Erarbeitungs-Reflexionsphase_<Typ>`
Typen: `PR` (Präsentation), `KZ` (Kurzzusammenfassung), `SQL` (.sql-Datei(en))
