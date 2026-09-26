# Screenshots für die Präsentation

Für jede Folie mit einer Entität/Beziehung fehlt noch ein echter Screenshot aus dem
Datenbankmanagementsystem (hier: SQLite, geöffnet z. B. über die VS-Code-SQLite-Extension
oder DB Browser for SQLite).

So erstellst du sie:

1. Öffne `buchtausch_app.db` (liegt im Ordner `02_Erarbeitungs-Reflexionsphase/`, wird durch
   Ausführen der `.sql`-Datei erzeugt) in deiner SQLite-Ansicht.
2. Führe je Zeile der Tabelle unten den angegebenen SQL-Befehl aus.
3. Mache einen Screenshot des Ergebnisses und speichere ihn **genau unter dem Dateinamen**
   aus der Spalte "Screenshot-Datei".
4. Danach `build.bat` erneut ausführen — die Platzhalter-Box in der Präsentation wird
   automatisch durch das Bild ersetzt.

## Auszuführende SQL-Befehle

| Screenshot-Datei | Folie | SQL-Befehl | Erwartetes Ergebnis |
|---|---|---|---|
| `nutzer.png` | NUTZER | `SELECT nutzer_id, vorname, nachname, email FROM nutzer WHERE rolle = 'nutzer';` | 11 Zeilen |
| `adresse.png` | ADRESSE | `SELECT a.strasse, a.hausnummer, a.plz, a.stadt`<br>`FROM adresse a JOIN nutzer n ON n.nutzer_id = a.nutzer_id`<br>`WHERE n.vorname = 'Anna' AND n.nachname = 'Bauer';` | 1 Zeile: Musterstrasse, 12, 10115, Berlin |
| `verlag.png` | VERLAG | `SELECT name FROM verlag WHERE land = 'Deutschland';` | 9 Zeilen (alle außer Diogenes) |
| `sprache.png` | SPRACHE | `SELECT bezeichnung, iso_code FROM sprache WHERE bezeichnung = 'Deutsch';` | 1 Zeile: Deutsch, DE |
| `genre.png` | GENRE | `SELECT b.titel FROM buch b`<br>`JOIN buch_genre bg ON bg.buch_id = b.buch_id`<br>`JOIN genre g ON g.genre_id = bg.genre_id`<br>`WHERE g.bezeichnung = 'Roman';` | 5 Zeilen |
| `autor.png` | AUTOR | `SELECT b.titel FROM buch b`<br>`JOIN buch_autor ba ON ba.buch_id = b.buch_id`<br>`JOIN autor a ON a.autor_id = ba.autor_id`<br>`WHERE a.nachname = 'Kafka';` | 1 Zeile: Die Verwandlung |
| `buch.png` | BUCH | `SELECT b.titel, v.name AS verlag, s.bezeichnung AS sprache, b.erscheinungsjahr`<br>`FROM buch b`<br>`JOIN verlag v ON v.verlag_id = b.verlag_id`<br>`JOIN sprache s ON s.sprache_id = b.sprache_id;` | 12 Zeilen |
| `buchexemplar.png` | BUCHEXEMPLAR | `SELECT e.exemplar_id, n.vorname, n.nachname, e.zustand`<br>`FROM buchexemplar e`<br>`JOIN buch b ON b.buch_id = e.buch_id`<br>`JOIN nutzer n ON n.nutzer_id = e.eigentuemer_id`<br>`WHERE b.titel = '1984';` | 2 Zeilen: Hannah Vogel (neu), Anna Bauer (gut) |
| `zeitslot.png` | ZEITSLOT | `SELECT zeitslot_id, startzeit, endzeit FROM zeitslot WHERE datum = '2026-10-02';` | 2 Zeilen: 10:00–11:00, 16:00–17:00 |
| `standort.png` | STANDORT | `SELECT bezeichnung, strasse, stadt FROM standort WHERE stadt = 'Berlin';` | 1 Zeile: Stadtbibliothek Mitte |
| `versandoption.png` | VERSANDOPTION | `SELECT exemplar_id, versandart, kosten FROM versandoption WHERE versandart IN ('post', 'beides');` | 7 Zeilen |
| `benachrichtigung.png` | BENACHRICHTIGUNG | `SELECT be.typ, be.inhalt FROM benachrichtigung be`<br>`JOIN nutzer n ON n.nutzer_id = be.nutzer_id`<br>`WHERE n.nachname = 'Neumann' AND be.gelesen = 0;` | 1 Zeile: exemplar_verfuegbar |
| `bewertung.png` | BEWERTUNG | `SELECT n.vorname, n.nachname, ROUND(AVG(be.sternebewertung), 2) AS durchschnitt`<br>`FROM bewertung be`<br>`JOIN ausleihe au ON au.ausleihe_id = be.ausleihe_id`<br>`JOIN buchexemplar e ON e.exemplar_id = au.exemplar_id`<br>`JOIN nutzer n ON n.nutzer_id = e.eigentuemer_id`<br>`GROUP BY n.nutzer_id`<br>`ORDER BY durchschnitt DESC;` | 9 Zeilen, sortiert nach Durchschnitt |
| `ausleihe.png` | AUSLEIHE (LEIHT_AUS) | `SELECT au.ausleihe_id, n.vorname, n.nachname, b.titel, au.ausleihdatum, au.rueckgabedatum`<br>`FROM ausleihe au`<br>`JOIN nutzer n ON n.nutzer_id = au.nutzer_id`<br>`JOIN buchexemplar e ON e.exemplar_id = au.exemplar_id`<br>`JOIN buch b ON b.buch_id = e.buch_id`<br>`WHERE au.status = 'zurueckgegeben';` | 10 Zeilen |
| `verfuegbarkeit.png` | VERFUEGBARKEIT (VERFUEGBAR_AN) | `SELECT vf.exemplar_id, z.datum, z.startzeit`<br>`FROM verfuegbarkeit vf`<br>`JOIN standort st ON st.standort_id = vf.standort_id`<br>`JOIN zeitslot z ON z.zeitslot_id = vf.zeitslot_id`<br>`WHERE st.bezeichnung = 'Stadtbibliothek Mitte' AND vf.verfuegbar = 1;` | 1 Zeile |
| `negativtest1.png` … `negativtest6.png` | Negativtestfälle (2 Folien) | siehe eigene Tabelle unten -- jeden Befehl einzeln ausführen und einzeln als `negativtestN.png` speichern | jeder Befehl liefert einen Fehler (siehe Spalte "Erwartete Fehlermeldung") |

## Negativtestfälle (für `negativtest1.png` … `negativtest6.png`)

Diese sechs Befehle müssen **fehlschlagen** — genau das ist der Nachweis, dass die Constraints
und Trigger funktionieren. Führe jeden einzeln aus und speichere pro Befehl einen eigenen
Screenshot unter `negativtestN.png` (N = 1–6, siehe Tabelle).

| # | Datei | SQL-Befehl | Erwartete Fehlermeldung |
|---|---|---|---|
| 1 | `negativtest1.png` | `INSERT INTO bewertung (ausleihe_id, sternebewertung, kommentar) VALUES (2, 7, 'Ungueltig');` | `CHECK constraint failed: sternebewertung BETWEEN 1 AND 5` |
| 2 | `negativtest2.png` | `INSERT INTO versandoption (exemplar_id, versandart, kosten) VALUES (13, 'post', -5.00);` | `CHECK constraint failed: kosten >= 0` |
| 3 | `negativtest3.png` | `INSERT INTO zeitslot (datum, startzeit, endzeit) VALUES ('2026-11-01', '15:00', '14:00');` | `CHECK constraint failed: startzeit < endzeit` |
| 4 | `negativtest4.png` | **Zuerst** `PRAGMA foreign_keys = ON;` ausführen, **dann getrennt**:`INSERT INTO ausleihe (nutzer_id, exemplar_id, zeitslot_id, ausleihdatum, status)`<br>`VALUES (9999, 1, 2, '2026-10-01', 'aktiv');` | `FOREIGN KEY constraint failed` |
| 5 | `negativtest5.png` | `INSERT INTO ausleihe (nutzer_id, exemplar_id, zeitslot_id, ausleihdatum, status)`<br>`VALUES (1, 1, 2, '2026-10-01', 'aktiv');` | `Nutzer kann eigenes Buchexemplar nicht ausleihen` |
| 6 | `negativtest6.png` | `INSERT INTO bewertung (ausleihe_id, sternebewertung, kommentar) VALUES (11, 5, 'Zu frueh');` | `Bewertung nur fuer abgeschlossene (zurueckgegebene) Ausleihen erlaubt` |

**Wichtig zu Fall 4:** SQLite deaktiviert `FOREIGN KEY`-Prüfungen standardmäßig **pro
Verbindung**. Viele SQL-Editoren (auch manche VS-Code-SQLite-Extensions) öffnen für jede
Abfrage eine neue Verbindung, in der dieses PRAGMA nicht automatisch gesetzt ist — dann geht
der Insert fälschlicherweise durch, obwohl das Schema korrekt ist (genau das ist in
`negativtest4.png` aktuell passiert: "Query executed successfully"). Führe daher **zuerst**
`PRAGMA foreign_keys = ON;` als eigenen Befehl aus und **danach erst** den INSERT — beides in
derselben Verbindung/demselben Tab, ohne die Verbindung dazwischen zu schließen — und
überschreibe `negativtest4.png` mit dem neuen Ergebnis.

**Hinweis:** Führe diese sechs Befehle in einer separaten Testumgebung/Kopie aus oder mache sie
danach per `ROLLBACK`/erneutem Import rückgängig, falls dein Tool sie trotz Fehler teilweise
übernimmt — sie sollen nicht dauerhaft Teil von `buchtausch_app.db` werden, da sie absichtlich
ungültige Daten sind.
