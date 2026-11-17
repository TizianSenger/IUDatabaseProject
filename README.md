# Buchtausch-App – Datenbankprojekt (DLBDSPBDM01_D)

Portfolio-Projekt „Data-Mart-Erstellung in SQL“ (IU Internationale Hochschule) von
Tizian Senger (Matrikelnummer IU14143428).

Relationale Datenbank für eine Buchtausch-App: Nutzende bieten eigene Bücher zum Verleihen an,
leihen Bücher anderer aus, bewerten abgeschlossene Ausleihen und finden über eine
**Umkreissuche** Bücher in ihrer Nähe.

- **DBMS:** SQLite 3 (≥ 3.35), serverlos, eine einzige Datei
- **Umfang:** 17 Tabellen (13 Entitäten, 2 Dreifachbeziehungen, 2 M:N-Tabellen), 207 Dummy-Datensätze,
  PK/FK/UNIQUE/CHECK-Constraints, 2 Trigger, 1 View, 11 Indizes
- **Normalform:** 3NF; Trennung Werk (`buch`) und physisches Exemplar (`buchexemplar`)

## Schnellstart

Voraussetzung: Python 3 (enthält `sqlite3`), kein Datenbankserver nötig.

```bash
cd latex/03_Finalisierungsphase
python install_db.py        # erzeugt buchtausch_app.db und führt alle Tests aus
python index_benchmark.py   # optional: misst den Nutzen der Indizes
```

Die fertige Datenbank `latex/03_Finalisierungsphase/buchtausch_app.db` kann auch direkt in einem
SQLite-Werkzeug (z. B. DB Browser for SQLite, VS-Code-SQLite-Extension) geöffnet werden.
Wichtig: Fremdschlüssel prüft SQLite nur nach `PRAGMA foreign_keys = ON;` in derselben Verbindung.

## Struktur

| Ordner | Phase | Inhalt |
|---|---|---|
| `latex/01_Konzeptionsphase` | 1 – Konzeption | Anforderungsspezifikation, ER-Modell (Chen-Notation), Datenwörterbuch |
| `latex/02_Erarbeitungs-Reflexionsphase` | 2 – Erarbeitung/Reflexion | SQL-Skript, Präsentation (PR), Kurzzusammenfassung (KZ), Screenshots |
| `latex/03_Finalisierungsphase` | 3 – Finalisierung | finales SQL-Skript, Installations-/Benchmark-Skript, BE, Abstract, SQL-Doku, GH-Link, Gesamtdokument |

Jede Phase enthält ein `build.bat`, das die PDFs mit den offiziellen Abgabe-Dateinamen erzeugt
(MiKTeX/pdfLaTeX; die Präsentation in Phase 2 benötigt XeLaTeX). Die Abgabe-ZIP entsteht mit
`latex/03_Finalisierungsphase/make_zip.ps1`.
