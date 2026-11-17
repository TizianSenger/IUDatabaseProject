# Portfolioteil 3 – Finalisierungsphase

**DBMS: SQLite 3** (≥ 3.35, wegen der Mathe-Funktionen für die Haversine-Umkreissuche).

Umgesetzt wurde das Tutor-Feedback zu Phase 2:
1. **Indizes** für häufige Abfragen angelegt (11 Stück, Abschnitt 6 des SQL-Skripts) und ihr
   **Nutzen überprüft** – per `EXPLAIN QUERY PLAN` und per Laufzeit-Benchmark (`index_benchmark.py`).
2. **Umkreissuche** auf Basis von `standort.breitengrad/laengengrad` mit der **Haversine-Formel**
   (Bounding-Box-Vorfilter + exakte Distanz + View `v_verfuegbares_angebot`, Abschnitt 7).

## Installation

```bash
python install_db.py            # baut buchtausch_app.db, führt alle Tests + 6 Negativtests aus
python index_benchmark.py       # optional: Index-Benchmark (~1 min, separate Benchmark-DB)
```
Alternativ: `sqlite3 buchtausch_app.db < Senger-Tizian_IU14143428_DLBDSPBDM01_D_Abschlussphase_SQL.sql`

## Dateien

| Datei | Inhalt |
|---|---|
| `..._Abschlussphase_SQL.sql` | Finales, eigenständiges SQL-Skript (Phase-2-Inhalt + Abschnitte 6–9) |
| `install_db.py` | Aufbau der DB + Selbsttest, erzeugt `metadaten.tex` |
| `index_benchmark.py` | Nutzennachweis der Indizes, erzeugt `benchmark_ergebnisse.md/.tex` |
| `buchtausch_app.db` | erzeugte Datenbank |
| `main.tex` → `..._BE.pdf` | 3-seitiges Dokument: Funktionalität + Metadaten |
| `abstract.tex` → `..._AB.pdf` | Abstract (1–1,5 Seiten, Arial/Helvetica 11 pt, 1,5-zeilig) |
| `sql_doku.tex` → `..._SQL.pdf` | SQL-Dokumentation mit Installationsanleitung, Ergebnissen, Skript im Anhang |
| `github.tex` → `..._GH.pdf` | Link zum GitHub-Repository |
| `gesamtdokument.tex` → `..._Gesamtdokumentation.pdf` | alle Ergebnisse aus Phase 1–3 in einem PDF |
| `screenshots/` | DBMS-Screenshots für die SQL-Doku (Umkreissuche, EXPLAIN QUERY PLAN, Metadaten) |
| `make_zip.ps1` | erzeugt die Abgabe-ZIP mit den Ordnern 01_/02_/03_ |

## Bauen und Abgeben

1. `build.bat` – baut die DB neu und kompiliert alle PDFs (mit PebblePad-Dateinamen).
2. `powershell -ExecutionPolicy Bypass -File make_zip.ps1` – erzeugt
   `latex/Senger_Tizian_IU14143428_DLBDSPBDM01_D.zip`.

Dateibenennung (PebblePad): `Nachname-Vorname_Matrikelnummer_DLBDSPBDM01_D_Abschlussphase_<Typ>`
mit den Typen `SQL`, `BE`, `AB`, `GH`.
