# Index-Benchmark Buchtausch-App

SQLite 3.50.4, Seed 42, 736,711 Datensaetze (u. a. 200,000 Ausleihen, 100,000 Exemplare, 5,000 Standorte). Median ueber 40 Parameterwerte je Abfrage.

| Nr. | Abfrage | ohne Index [ms] | mit Index [ms] | Faktor | Index |
|---|---|---:|---:|---:|---|
| Q1 | Mein Regal (Exemplare je Eigentümer:in) | 3.222 | 0.050 | 64.6x | `idx_buchexemplar_eigentuemer` |
| Q2 | Meine Ausleihen, neueste zuerst | 8.590 | 0.073 | 118.4x | `idx_ausleihe_nutzer_datum` |
| Q3 | Mahnlauf: überfällige Ausleihen (2 %) | 12.637 | 6.705 | 1.9x | `idx_ausleihe_status` |
| Q4 | Gegenprobe: zurückgegebene Ausleihen (90 %) | 85.806 | 96.547 | 0.9x | `idx_ausleihe_status` |
| Q5 | Werk → alle Exemplare | 3.107 | 0.060 | 51.8x | `idx_buchexemplar_buch` |
| Q6 | Umkreissuche 15 km (Haversine + View) | 918.045 | 1.634 | 561.7x | `idx_standort_geo, idx_verfuegbarkeit_standort` |
| Q7 | Titelsuche Präfix (LIKE 'Wort%') | 0.283 | 0.048 | 5.9x | `idx_buch_titel` |
| Q8 | Badge: ungelesene Benachrichtigungen | 7.907 | 0.029 | 275.5x | `idx_benachrichtigung_ungelesen` |
| Q9 | Alle Bücher eines Genres | 0.487 | 0.256 | 1.9x | `idx_buch_genre_genre` |

## Ausfuehrungsplaene (EXPLAIN QUERY PLAN)

- **Q1** ohne: `SCAN e / SEARCH b USING INTEGER PRIMARY KEY (rowid=?)`
  mit: `SEARCH e USING INDEX idx_buchexemplar_eigentuemer (eigentuemer_id=?) / SEARCH b USING INTEGER PRIMARY KEY (rowid=?)`
- **Q2** ohne: `SCAN ausleihe / USE TEMP B-TREE FOR ORDER BY`
  mit: `SEARCH ausleihe USING INDEX idx_ausleihe_nutzer_datum (nutzer_id=?)`
- **Q3** ohne: `SCAN ausleihe`
  mit: `SEARCH ausleihe USING INDEX idx_ausleihe_status (status=?)`
- **Q4** ohne: `SCAN ausleihe`
  mit: `SEARCH ausleihe USING INDEX idx_ausleihe_status (status=?)`
- **Q5** ohne: `SCAN buchexemplar`
  mit: `SEARCH buchexemplar USING INDEX idx_buchexemplar_buch (buch_id=?)`
- **Q6** ohne: `CO-ROUTINE suchpunkt / SCAN CONSTANT ROW / SCAN suchpunkt / SCAN vf / SEARCH e USING INTEGER PRIMARY KEY (rowid=?) / CORRELATED SCALAR SUBQUERY 7 / SEARCH au USING INDEX sqlite_autoindex_ausleihe_1 (exemplar_id=?) / SEARCH st USING INTEGER PRIMARY KEY (rowid=?) / SEARCH st USING INTEGER PRIMARY KEY (rowid=?) / SEARCH b USING INTEGER PRIMARY KEY (rowid=?) / SEARCH n USING INTEGER PRIMARY KEY (rowid=?) / SEARCH z USING INTEGER PRIMARY KEY (rowid=?) / USE TEMP B-TREE FOR ORDER BY`
  mit: `CO-ROUTINE suchpunkt / SCAN CONSTANT ROW / SCAN suchpunkt / SEARCH st USING COVERING INDEX idx_standort_geo (breitengrad>? AND breitengrad<?) / SEARCH st USING INTEGER PRIMARY KEY (rowid=?) / SEARCH vf USING INDEX idx_verfuegbarkeit_standort (standort_id=? AND verfuegbar=?) / SEARCH e USING INTEGER PRIMARY KEY (rowid=?) / CORRELATED SCALAR SUBQUERY 7 / SEARCH au USING INDEX sqlite_autoindex_ausleihe_1 (exemplar_id=?) / SEARCH z USING INTEGER PRIMARY KEY (rowid=?) / SEARCH b USING INTEGER PRIMARY KEY (rowid=?) / SEARCH n USING INTEGER PRIMARY KEY (rowid=?) / USE TEMP B-TREE FOR ORDER BY`
- **Q7** ohne: `SCAN buch`
  mit: `SEARCH buch USING COVERING INDEX idx_buch_titel (titel>? AND titel<?)`
- **Q8** ohne: `SCAN benachrichtigung`
  mit: `SEARCH benachrichtigung USING COVERING INDEX idx_benachrichtigung_ungelesen (nutzer_id=?)`
- **Q9** ohne: `SCAN bg / SEARCH b USING INTEGER PRIMARY KEY (rowid=?)`
  mit: `SEARCH bg USING INDEX idx_buch_genre_genre (genre_id=?) / SEARCH b USING INTEGER PRIMARY KEY (rowid=?)`

## Kosten der Indizes

- Dateigroesse ohne eigene Indizes: 35.4 MB, mit: 48.7 MB (+13.3 MB, +38 %)
- 5.000 Ausleihen + 5.000 Benachrichtigungen einfuegen: ohne 114 ms, mit 195 ms (+70 %)
