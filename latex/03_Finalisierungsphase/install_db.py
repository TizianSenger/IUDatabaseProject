"""
Buchtausch-App -- Installations- und Pruefskript (Finalisierungsphase)
DLBDSPBDM01_D -- Tizian Senger, IU14143428

Baut die SQLite-Datenbank buchtausch_app.db aus dem finalen SQL-Skript auf
und fuehrt anschliessend alle darin enthaltenen Abfragen (Testfaelle,
EXPLAIN QUERY PLAN, Umkreissuche, Metadaten) sowie die sechs Negativtests
aus. Benoetigt nur Python 3 (Modul sqlite3 ist Teil der Standardbibliothek,
SQLite-Version >= 3.35 fuer die Mathe-Funktionen der Haversine-Formel).

Aufruf:
    python install_db.py              # DB neu aufbauen + alle Tests ausgeben
    python install_db.py --quiet      # nur aufbauen + Kurzbericht
"""
import os
import sqlite3
import sys

HIER = os.path.dirname(os.path.abspath(__file__))
SQL_DATEI = os.path.join(HIER, "Senger-Tizian_IU14143428_DLBDSPBDM01_D_Abschlussphase_SQL.sql")
DB_DATEI = os.path.join(HIER, "buchtausch_app.db")

# Die sechs Negativtests aus Abschnitt 5b des SQL-Skripts. Jeder MUSS mit
# dem angegebenen Fehlertext scheitern. Sie laufen in einer Transaktion,
# die anschliessend zurueckgerollt wird, damit die DB unveraendert bleibt.
NEGATIVTESTS = [
    ("CHECK: Sternebewertung 7",
     "INSERT INTO bewertung (ausleihe_id, sternebewertung, kommentar) VALUES (2, 7, 'Ungueltig')",
     "CHECK constraint failed"),
    ("CHECK: negative Versandkosten",
     "INSERT INTO versandoption (exemplar_id, versandart, kosten) VALUES (13, 'post', -5.00)",
     "CHECK constraint failed"),
    ("CHECK: startzeit >= endzeit",
     "INSERT INTO zeitslot (datum, startzeit, endzeit) VALUES ('2026-11-01', '15:00', '14:00')",
     "CHECK constraint failed"),
    ("FK: unbekannte nutzer_id 9999",
     "INSERT INTO ausleihe (nutzer_id, exemplar_id, zeitslot_id, ausleihdatum, status) "
     "VALUES (9999, 1, 2, '2026-10-01', 'aktiv')",
     "FOREIGN KEY constraint failed"),
    ("Trigger: Eigenausleihe",
     "INSERT INTO ausleihe (nutzer_id, exemplar_id, zeitslot_id, ausleihdatum, status) "
     "VALUES (1, 1, 2, '2026-10-01', 'aktiv')",
     "Nutzer kann eigenes Buchexemplar nicht ausleihen"),
    ("Trigger: Bewertung vor Rueckgabe",
     "INSERT INTO bewertung (ausleihe_id, sternebewertung, kommentar) VALUES (11, 5, 'Zu frueh')",
     "Bewertung nur fuer abgeschlossene"),
]


def statements(sql_text):
    """Zerlegt das Skript in einzelne Statements (inkl. Trigger-Bloecke)."""
    puffer = []
    for zeile in sql_text.splitlines():
        if not puffer and (zeile.strip().startswith("--") or not zeile.strip()):
            continue
        puffer.append(zeile)
        kandidat = "\n".join(puffer)
        if sqlite3.complete_statement(kandidat):
            yield kandidat.strip()
            puffer = []


def tabelle_drucken(cursor, zeilen):
    kopf = [d[0] for d in cursor.description]
    breiten = [max(len(str(x)) for x in [k] + [z[i] for z in zeilen]) for i, k in enumerate(kopf)]
    breiten = [min(b, 45) for b in breiten]
    fmt = " | ".join("{:<%d}" % b for b in breiten)
    print("  " + fmt.format(*kopf))
    print("  " + "-+-".join("-" * b for b in breiten))
    for z in zeilen:
        print("  " + fmt.format(*[str(x)[:45] for x in z]))


def main():
    leise = "--quiet" in sys.argv
    if sqlite3.sqlite_version_info < (3, 35):
        sys.exit(f"SQLite {sqlite3.sqlite_version} ist zu alt (>= 3.35 fuer Mathe-Funktionen noetig).")

    if os.path.exists(DB_DATEI):
        os.remove(DB_DATEI)
    with open(SQL_DATEI, encoding="utf-8") as f:
        sql_text = f.read()

    con = sqlite3.connect(DB_DATEI)
    con.isolation_level = None          # Autocommit; Transaktionen explizit steuern
    con.execute("PRAGMA foreign_keys = ON")

    anzahl_abfragen = 0
    for stmt in statements(sql_text):
        cur = con.execute(stmt)
        if cur.description is None:
            continue
        zeilen = cur.fetchall()
        anzahl_abfragen += 1
        if not leise:
            erste_zeile = next(z for z in stmt.splitlines() if z.strip())
            if erste_zeile.startswith("EXPLAIN"):
                erste_zeile = " ".join(stmt.split()[3:12]) + " ..."
            print(f"\n[{anzahl_abfragen}] {erste_zeile[:90]}")
            if stmt.startswith("EXPLAIN QUERY PLAN"):
                for z in zeilen:
                    print("  ->", z[3])
            else:
                tabelle_drucken(cur, zeilen)

    print(f"\nDatenbank aufgebaut: {DB_DATEI}")
    print(f"SQLite-Version: {sqlite3.sqlite_version}, ausgefuehrte Abfragen: {anzahl_abfragen}")

    print("\nNegativtests (muessen alle scheitern):")
    fehler = 0
    for name, sql, erwartet in NEGATIVTESTS:
        con.execute("BEGIN")
        try:
            con.execute(sql)
            ergebnis, ok = "WURDE AKZEPTIERT (Fehler!)", False
        except sqlite3.DatabaseError as e:
            ergebnis, ok = str(e), erwartet in str(e)
        finally:
            con.execute("ROLLBACK")
        fehler += not ok
        print(f"  [{'OK ' if ok else 'FEHLER'}] {name:<34} -> {ergebnis}")

    # Speicher freigeben/kompaktieren, damit die Groessenangabe stabil ist
    con.execute("VACUUM")
    metadaten_schreiben(con)
    con.close()
    groesse = os.path.getsize(DB_DATEI)
    print(f"\nDateigroesse buchtausch_app.db: {groesse} Bytes ({groesse / 1024:.1f} KiB)")
    print("Metadaten geschrieben: metadaten.tex")
    sys.exit(1 if fehler else 0)


def metadaten_schreiben(con):
    """Schreibt die Kennzahlen der DB als LaTeX-Makros (fuer main.tex / sql_doku.tex),
    damit die Dokumente immer zur tatsaechlich erzeugten Datenbank passen."""
    tabellen = [t for (t,) in con.execute(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite\\_%' ESCAPE '\\' "
        "ORDER BY rowid")]
    zaehler = [(t, con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]) for t in tabellen]
    anzahl = lambda typ, eigen=True: con.execute(
        "SELECT COUNT(*) FROM sqlite_master WHERE type = ? AND (name NOT LIKE 'sqlite\\_%' ESCAPE '\\') = ?",
        (typ, int(eigen))).fetchone()[0]
    seiten = con.execute("PRAGMA page_count").fetchone()[0]
    seitengr = con.execute("PRAGMA page_size").fetchone()[0]
    groesse = seiten * seitengr
    tex = lambda s: s.replace("_", "\\_")
    zeilen = " \\\\\n".join(f"\\texttt{{{tex(t)}}} & {n}" for t, n in zaehler)
    drittel = -(-len(zaehler) // 3)             # fuer dreispaltigen Satz im Dokument
    teile = [" \\\\\n".join(f"\\texttt{{{tex(t)}}} & {n}" for t, n in zaehler[i:i + drittel])
             for i in range(0, len(zaehler), drittel)]
    with open(os.path.join(HIER, "metadaten.tex"), "w", encoding="utf-8") as f:
        f.write("% automatisch erzeugt von install_db.py -- nicht von Hand bearbeiten\n")
        f.write(f"\\newcommand{{\\mdTabellen}}{{{len(tabellen)}}}\n")
        f.write(f"\\newcommand{{\\mdDatensaetze}}{{{sum(n for _, n in zaehler)}}}\n")
        f.write(f"\\newcommand{{\\mdMinZeilen}}{{{min(n for _, n in zaehler)}}}\n")
        f.write(f"\\newcommand{{\\mdIndizes}}{{{anzahl('index')}}}\n")
        f.write(f"\\newcommand{{\\mdAutoIndizes}}{{{anzahl('index', False)}}}\n")
        f.write(f"\\newcommand{{\\mdTrigger}}{{{anzahl('trigger')}}}\n")
        f.write(f"\\newcommand{{\\mdViews}}{{{anzahl('view')}}}\n")
        f.write(f"\\newcommand{{\\mdSeiten}}{{{seiten}}}\n")
        f.write(f"\\newcommand{{\\mdSeitengroesse}}{{{seitengr}}}\n")
        f.write(f"\\newcommand{{\\mdBytes}}{{{groesse:,}}}\n".replace(",", "."))
        kib = f"{groesse / 1024:.1f}".replace(".", ",")      # deutsches Dezimalkomma
        f.write(f"\\newcommand{{\\mdKiB}}{{{kib}}}\n")
        f.write(f"\\newcommand{{\\mdSQLite}}{{{sqlite3.sqlite_version}}}\n")
        f.write(f"\\newcommand{{\\mdZeilenTabelle}}{{%\n{zeilen} \\\\\n}}\n")
        for buchstabe, teil in zip("ABC", teile):
            f.write(f"\\newcommand{{\\mdZeilenTabelle{buchstabe}}}{{%\n{teil} \\\\\n}}\n")


if __name__ == "__main__":
    main()
