"""
Buchtausch-App -- Nutzennachweis der Indizes (Finalisierungsphase)
DLBDSPBDM01_D -- Tizian Senger, IU14143428

Mit nur 10-15 Datensaetzen je Tabelle ist jede Abfrage in Mikrosekunden
fertig -- ein Laufzeitunterschied durch Indizes ist dort nicht messbar.
Dieses Skript baut daher eine SEPARATE Benchmark-Datenbank
(benchmark.db, wird am Ende geloescht) mit demselben Schema, fuellt sie mit
einem grossen, reproduzierbaren synthetischen Datenbestand (fester Seed) und
misst jede typische App-Abfrage zweimal:

    1. ohne die selbst angelegten Indizes (nur PK/UNIQUE-Autoindizes)
    2. mit allen Indizes aus Abschnitt 6 des SQL-Skripts (+ ANALYZE)

Gemessen werden: Median der Laufzeit ueber viele Parameterwerte,
Ausfuehrungsplan (EXPLAIN QUERY PLAN), zusaetzlicher Speicherbedarf der
Indizes und der Mehraufwand beim Einfuegen (Indizes muessen mitgepflegt werden).

Die Original-Datenbank buchtausch_app.db wird NICHT veraendert.

Aufruf:  python index_benchmark.py
Ausgabe: Konsole + benchmark_ergebnisse.md + benchmark_ergebnisse.tex
"""
import os
import random
import re
import sqlite3
import statistics
import time

HIER = os.path.dirname(os.path.abspath(__file__))
SQL_DATEI = os.path.join(HIER, "Senger-Tizian_IU14143428_DLBDSPBDM01_D_Abschlussphase_SQL.sql")
BENCH_DB = os.path.join(HIER, "benchmark.db")

SEED = 42
N_NUTZER, N_BUCH, N_EXEMPLAR = 20_000, 10_000, 100_000
N_ZEITSLOT, N_STANDORT = 2_000, 5_000
N_AUSLEIHE, N_VERFUEGBARKEIT, N_BENACHRICHTIGUNG = 200_000, 100_000, 200_000
WIEDERHOLUNGEN = 40          # unterschiedliche Parameterwerte je Abfrage

WOERTER = ["Der", "Die", "Das", "Schatten", "Nacht", "Garten", "Reise", "Haus", "Stadt",
           "Meer", "Winter", "Sommer", "Geheimnis", "Spur", "Licht", "Stimme", "Insel",
           "Zeit", "Erbe", "Fluss", "Harry", "Pippi", "Mord", "Traum", "Wald", "Feuer"]


def schema_ohne_indizes(sql_text):
    """Nimmt aus dem finalen Skript nur Schema + Trigger + View (ohne Daten,
    ohne Indizes, ohne Abfragen), damit die Benchmark-DB identisch aufgebaut ist."""
    teile = []
    ohne_kommentare = re.sub(r"--[^\n]*", "", sql_text)
    for block in re.findall(r"(CREATE (?:TABLE|TRIGGER|VIEW).*?;\s*(?:END;)?)", ohne_kommentare, re.S):
        if block.startswith("CREATE TRIGGER") and not block.rstrip().endswith("END;"):
            continue
        teile.append(block)
    return "\n".join(teile)


def indizes(sql_text):
    return re.findall(r"^CREATE INDEX .*?;", sql_text, re.M)


def daten_erzeugen(con):
    rnd = random.Random(SEED)
    con.execute("PRAGMA foreign_keys = OFF")   # Bulk-Load; Konsistenz garantiert der Generator
    con.execute("BEGIN")
    con.executemany("INSERT INTO verlag (name, land) VALUES (?, 'Deutschland')",
                    [(f"Verlag {i}",) for i in range(1, 51)])
    con.executemany("INSERT INTO sprache (bezeichnung, iso_code) VALUES (?, ?)",
                    [("Deutsch", "DE"), ("Englisch", "EN"), ("Franzoesisch", "FR")])
    con.executemany("INSERT INTO genre (bezeichnung) VALUES (?)", [(f"Genre {i}",) for i in range(1, 31)])
    con.executemany("INSERT INTO autor (vorname, nachname) VALUES (?, ?)",
                    [(f"Vorname{i}", f"Nachname{i}") for i in range(1, 5_001)])
    con.executemany(
        "INSERT INTO nutzer (vorname, nachname, email, passwort_hash, rolle, registriert_am) "
        "VALUES (?, ?, ?, 'hash', 'nutzer', '2025-01-01')",
        [(f"V{i}", f"N{i}", f"user{i}@example.com") for i in range(1, N_NUTZER + 1)])
    con.executemany(
        "INSERT INTO adresse (nutzer_id, strasse, hausnummer, plz, stadt) VALUES (?, 'Weg', '1', '10115', 'Berlin')",
        [(i,) for i in range(1, N_NUTZER + 1)])
    con.executemany(
        "INSERT INTO buch (titel, verlag_id, sprache_id, erscheinungsjahr) VALUES (?, ?, ?, ?)",
        [(" ".join(rnd.choices(WOERTER, k=3)) + f" {i}", rnd.randint(1, 50), rnd.randint(1, 3),
          rnd.randint(1900, 2025)) for i in range(1, N_BUCH + 1)])
    con.executemany("INSERT OR IGNORE INTO buch_genre VALUES (?, ?)",
                    [(rnd.randint(1, N_BUCH), rnd.randint(1, 30)) for _ in range(15_000)])
    con.executemany("INSERT OR IGNORE INTO buch_autor VALUES (?, ?)",
                    [(b, rnd.randint(1, 5_000)) for b in range(1, N_BUCH + 1)])
    eigentuemer = [rnd.randint(1, N_NUTZER) for _ in range(N_EXEMPLAR)]
    con.executemany(
        "INSERT INTO buchexemplar (buch_id, eigentuemer_id, zustand) VALUES (?, ?, ?)",
        [(rnd.randint(1, N_BUCH), eigentuemer[i], rnd.choice(["neu", "gut", "gebraucht"]))
         for i in range(N_EXEMPLAR)])
    con.executemany("INSERT INTO zeitslot (datum, startzeit, endzeit) VALUES (?, '10:00', '11:00')",
                    [(f"2026-{1 + i % 12:02d}-{1 + i % 28:02d}",) for i in range(N_ZEITSLOT)])
    # Standorte zufaellig ueber Deutschland verteilt (Bounding Box DE)
    con.executemany(
        "INSERT INTO standort (bezeichnung, stadt, breitengrad, laengengrad) VALUES (?, 'Ort', ?, ?)",
        [(f"Standort {i}", round(rnd.uniform(47.3, 54.9), 6), round(rnd.uniform(5.9, 15.0), 6))
         for i in range(1, N_STANDORT + 1)])
    con.executemany(
        "INSERT OR IGNORE INTO verfuegbarkeit (exemplar_id, zeitslot_id, standort_id, verfuegbar) VALUES (?, ?, ?, ?)",
        [(rnd.randint(1, N_EXEMPLAR), rnd.randint(1, N_ZEITSLOT), rnd.randint(1, N_STANDORT),
          int(rnd.random() < 0.8)) for _ in range(N_VERFUEGBARKEIT)])
    con.executemany(
        "INSERT INTO versandoption (exemplar_id, versandart, kosten) VALUES (?, 'beides', 2.50)",
        [(i,) for i in range(1, N_EXEMPLAR + 1, 2)])
    con.executemany(
        "INSERT INTO benachrichtigung (nutzer_id, typ, inhalt, gelesen) VALUES (?, 'system', 'Text', ?)",
        [(rnd.randint(1, N_NUTZER), int(rnd.random() < 0.9)) for _ in range(N_BENACHRICHTIGUNG)])
    # Ausleihen: 90 % zurueckgegeben, 8 % aktiv, 2 % ueberfaellig; nie Eigenausleihe
    paare, zeilen = set(), []
    while len(zeilen) < N_AUSLEIHE:
        ex, zs = rnd.randint(1, N_EXEMPLAR), rnd.randint(1, N_ZEITSLOT)
        if (ex, zs) in paare:
            continue
        paare.add((ex, zs))
        nutzer = rnd.randint(1, N_NUTZER)
        if nutzer == eigentuemer[ex - 1]:
            continue
        r = rnd.random()
        status = "zurueckgegeben" if r < 0.90 else ("aktiv" if r < 0.98 else "ueberfaellig")
        datum = f"2025-{rnd.randint(1, 12):02d}-{rnd.randint(1, 28):02d}"
        zeilen.append((nutzer, ex, zs, datum, datum if status == "zurueckgegeben" else None, status))
    con.executemany(
        "INSERT INTO ausleihe (nutzer_id, exemplar_id, zeitslot_id, ausleihdatum, rueckgabedatum, status) "
        "VALUES (?, ?, ?, ?, ?, ?)", zeilen)
    con.execute("COMMIT")
    con.execute("PRAGMA foreign_keys = ON")


UMKREIS_SQL = """
WITH suchpunkt(lat, lon, radius_km) AS (VALUES (?, ?, 15.0)),
box AS (SELECT lat, lon, radius_km, radius_km / 111.045 AS dlat,
               radius_km / (111.045 * cos(radians(lat))) AS dlon FROM suchpunkt),
kandidaten AS (
    SELECT st.standort_id, st.breitengrad, st.laengengrad, box.lat AS p_lat, box.lon AS p_lon, box.radius_km
    FROM standort st, box
    WHERE st.breitengrad BETWEEN box.lat - box.dlat AND box.lat + box.dlat
      AND st.laengengrad BETWEEN box.lon - box.dlon AND box.lon + box.dlon),
distanz AS (
    SELECT standort_id, radius_km, 2 * 6371.0 * asin(sqrt(
        power(sin(radians(breitengrad - p_lat) / 2), 2)
      + cos(radians(p_lat)) * cos(radians(breitengrad))
      * power(sin(radians(laengengrad - p_lon) / 2), 2))) AS distanz_km
    FROM kandidaten)
SELECT a.titel, a.standort, ROUND(d.distanz_km, 1)
FROM distanz d JOIN v_verfuegbares_angebot a ON a.standort_id = d.standort_id
WHERE d.distanz_km <= d.radius_km ORDER BY d.distanz_km
"""

# (Kuerzel, Beschreibung, SQL, Parametergenerator, genutzter Index)
ABFRAGEN = [
    ("Q1", "Mein Regal (Exemplare je Eigentümer:in)",
     "SELECT e.exemplar_id, b.titel, e.zustand FROM buchexemplar e "
     "JOIN buch b ON b.buch_id = e.buch_id WHERE e.eigentuemer_id = ?",
     lambda r: (r.randint(1, N_NUTZER),), "idx_buchexemplar_eigentuemer"),
    ("Q2", "Meine Ausleihen, neueste zuerst",
     "SELECT ausleihe_id, exemplar_id, ausleihdatum, status FROM ausleihe "
     "WHERE nutzer_id = ? ORDER BY ausleihdatum DESC",
     lambda r: (r.randint(1, N_NUTZER),), "idx_ausleihe_nutzer_datum"),
    ("Q3", "Mahnlauf: überfällige Ausleihen (2 %)",
     "SELECT ausleihe_id, nutzer_id, ausleihdatum FROM ausleihe WHERE status = ?",
     lambda r: ("ueberfaellig",), "idx_ausleihe_status"),
    ("Q4", "Gegenprobe: zurückgegebene Ausleihen (90 %)",
     "SELECT ausleihe_id, nutzer_id, ausleihdatum FROM ausleihe WHERE status = ?",
     lambda r: ("zurueckgegeben",), "idx_ausleihe_status"),
    ("Q5", "Werk → alle Exemplare",
     "SELECT exemplar_id, eigentuemer_id, zustand FROM buchexemplar WHERE buch_id = ?",
     lambda r: (r.randint(1, N_BUCH),), "idx_buchexemplar_buch"),
    ("Q6", "Umkreissuche 15 km (Haversine + View)",
     UMKREIS_SQL,
     lambda r: (round(r.uniform(47.5, 54.7), 4), round(r.uniform(6.1, 14.8), 4)),
     "idx_standort_geo, idx_verfuegbarkeit_standort"),
    ("Q7", "Titelsuche Präfix (LIKE 'Wort%')",
     "SELECT buch_id, titel FROM buch WHERE titel LIKE ?",
     lambda r: (r.choice(WOERTER) + " " + r.choice(WOERTER) + "%",), "idx_buch_titel"),
    ("Q8", "Badge: ungelesene Benachrichtigungen",
     "SELECT COUNT(*) FROM benachrichtigung WHERE nutzer_id = ? AND gelesen = 0",
     lambda r: (r.randint(1, N_NUTZER),), "idx_benachrichtigung_ungelesen"),
    ("Q9", "Alle Bücher eines Genres",
     "SELECT b.titel FROM buch_genre bg JOIN buch b ON b.buch_id = bg.buch_id WHERE bg.genre_id = ?",
     lambda r: (r.randint(1, 30),), "idx_buch_genre_genre"),
]


def de(x, stellen):
    """Zahl mit deutschem Dezimalkomma (fuer die LaTeX-Tabelle)."""
    return f"{x:.{stellen}f}".replace(".", ",")


def messen(con, sql, paramgen):
    rnd = random.Random(SEED + 1)        # identische Parameterfolge in beiden Durchlaeufen
    params = [paramgen(rnd) for _ in range(WIEDERHOLUNGEN)]
    con.execute(sql, params[0]).fetchall()          # Aufwaermen (Seiten-Cache)
    zeiten = []
    for p in params:
        t0 = time.perf_counter()
        con.execute(sql, p).fetchall()
        zeiten.append((time.perf_counter() - t0) * 1000)
    return statistics.median(zeiten)


def plan(con, sql, paramgen):
    p = paramgen(random.Random(SEED + 1))
    zeilen = con.execute("EXPLAIN QUERY PLAN " + sql, p).fetchall()
    return " / ".join(z[3] for z in zeilen)


def einfuegen_messen(con, n=5_000):
    """Mehraufwand der Indizes beim Schreiben: n neue Ausleihen + n Benachrichtigungen."""
    rnd = random.Random(SEED + 2)
    eigentuemer = dict(con.execute("SELECT exemplar_id, eigentuemer_id FROM buchexemplar"))
    zeilen = []
    for ex in rnd.sample(range(1, N_EXEMPLAR + 1), n):     # verschiedene Exemplare -> kein UNIQUE-Konflikt
        nutzer = rnd.randint(1, N_NUTZER)
        if nutzer == eigentuemer[ex]:                       # Eigenausleihe vermeiden (Trigger)
            nutzer = nutzer % N_NUTZER + 1
        zeilen.append((nutzer, ex, rnd.randint(1, N_NUTZER)))
    con.execute("BEGIN")
    t0 = time.perf_counter()
    for nutzer, ex, empfaenger in zeilen:
        con.execute("INSERT INTO ausleihe (nutzer_id, exemplar_id, zeitslot_id, ausleihdatum, status) "
                    "VALUES (?, ?, ?, '2026-11-01', 'aktiv')", (nutzer, ex, N_ZEITSLOT + 1))
        con.execute("INSERT INTO benachrichtigung (nutzer_id, typ, inhalt) VALUES (?, 'system', 'x')",
                    (empfaenger,))
    dauer = (time.perf_counter() - t0) * 1000
    con.execute("ROLLBACK")
    return dauer


def main():
    with open(SQL_DATEI, encoding="utf-8") as f:
        sql_text = f.read()
    if os.path.exists(BENCH_DB):
        os.remove(BENCH_DB)
    con = sqlite3.connect(BENCH_DB)
    con.isolation_level = None
    con.executescript(schema_ohne_indizes(sql_text))
    # Zeitslot fuer die Einfuegemessung (eigener Slot -> keine UNIQUE-Konflikte)
    print("Erzeuge synthetischen Datenbestand ...")
    t0 = time.perf_counter()
    daten_erzeugen(con)
    con.execute("INSERT INTO zeitslot (datum, startzeit, endzeit) VALUES ('2026-11-01', '10:00', '11:00')")
    con.execute("ANALYZE")
    con.execute("VACUUM")
    groesse_ohne = os.path.getsize(BENCH_DB)
    gesamt = sum(con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0] for (t,) in con.execute(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite%'").fetchall())
    print(f"  {gesamt:,} Datensaetze in {time.perf_counter() - t0:.1f} s, Dateigroesse {groesse_ohne / 1e6:.1f} MB")

    ergebnisse = {}
    print("\nMessung OHNE eigene Indizes ...")
    for kz, _, sql, pg, _ in ABFRAGEN:
        ergebnisse[kz] = {"ohne": messen(con, sql, pg), "plan_ohne": plan(con, sql, pg)}
    insert_ohne = einfuegen_messen(con)

    print("Lege Indizes an (Abschnitt 6 des SQL-Skripts) + ANALYZE ...")
    for stmt in indizes(sql_text):
        con.execute(stmt)
    con.execute("ANALYZE")
    con.execute("VACUUM")
    groesse_mit = os.path.getsize(BENCH_DB)

    print("Messung MIT Indizes ...")
    for kz, _, sql, pg, _ in ABFRAGEN:
        ergebnisse[kz]["mit"] = messen(con, sql, pg)
        ergebnisse[kz]["plan_mit"] = plan(con, sql, pg)
    insert_mit = einfuegen_messen(con)
    con.close()
    os.remove(BENCH_DB)

    # ---------- Ausgabe ----------
    md = ["# Index-Benchmark Buchtausch-App", "",
          f"SQLite {sqlite3.sqlite_version}, Seed {SEED}, {gesamt:,} Datensaetze "
          f"(u. a. {N_AUSLEIHE:,} Ausleihen, {N_EXEMPLAR:,} Exemplare, {N_STANDORT:,} Standorte). "
          f"Median ueber {WIEDERHOLUNGEN} Parameterwerte je Abfrage.", "",
          "| Nr. | Abfrage | ohne Index [ms] | mit Index [ms] | Faktor | Index |",
          "|---|---|---:|---:|---:|---|"]
    tex = []
    print(f"\n{'Nr':<4}{'Abfrage':<46}{'ohne [ms]':>11}{'mit [ms]':>11}{'Faktor':>9}")
    for kz, beschr, _, _, idx in ABFRAGEN:
        e = ergebnisse[kz]
        faktor = e["ohne"] / e["mit"] if e["mit"] > 0 else float("inf")
        print(f"{kz:<4}{beschr:<46}{e['ohne']:>11.3f}{e['mit']:>11.3f}{faktor:>8.1f}x")
        md.append(f"| {kz} | {beschr} | {e['ohne']:.3f} | {e['mit']:.3f} | {faktor:.1f}x | `{idx}` |")
        beschr_tex = beschr.replace("%", r"\%").replace("→", r"$\rightarrow$")
        tex.append(f"{kz} & {beschr_tex} & {de(e['ohne'], 2)} & {de(e['mit'], 2)} & "
                   f"{de(faktor, 1)}\\,$\\times$ \\\\")
    md += ["", "## Ausfuehrungsplaene (EXPLAIN QUERY PLAN)", ""]
    for kz, *_ in ABFRAGEN:
        md += [f"- **{kz}** ohne: `{ergebnisse[kz]['plan_ohne']}`",
               f"  mit: `{ergebnisse[kz]['plan_mit']}`"]
    zusatz = (groesse_mit - groesse_ohne) / 1e6
    md += ["", "## Kosten der Indizes", "",
           f"- Dateigroesse ohne eigene Indizes: {groesse_ohne / 1e6:.1f} MB, mit: {groesse_mit / 1e6:.1f} MB "
           f"(+{zusatz:.1f} MB, +{100 * zusatz * 1e6 / groesse_ohne:.0f} %)",
           f"- 5.000 Ausleihen + 5.000 Benachrichtigungen einfuegen: ohne {insert_ohne:.0f} ms, "
           f"mit {insert_mit:.0f} ms ({100 * (insert_mit / insert_ohne - 1):+.0f} %)"]
    print("\n" + "\n".join(md[-3:]))
    print("\nPlaene:")
    for kz, *_ in ABFRAGEN:
        print(f"  {kz} ohne: {ergebnisse[kz]['plan_ohne']}\n     mit: {ergebnisse[kz]['plan_mit']}")

    with open(os.path.join(HIER, "benchmark_ergebnisse.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(md) + "\n")
    with open(os.path.join(HIER, "benchmark_ergebnisse.tex"), "w", encoding="utf-8") as f:
        f.write("% automatisch erzeugt von index_benchmark.py -- nicht von Hand bearbeiten\n")
        f.write("\\newcommand{\\benchmeta}{" + f"{gesamt:,}".replace(",", ".") + " Datensätze, Median über "
                + f"{WIEDERHOLUNGEN} Parameterwerte, SQLite {sqlite3.sqlite_version}" + "}\n")
        f.write("\\newcommand{\\benchsize}{" + f"{groesse_ohne / 1e6:.1f}".replace(".", ",") + "~MB $\\rightarrow$ "
                + f"{groesse_mit / 1e6:.1f}".replace(".", ",") + f"~MB (+{100 * zusatz * 1e6 / groesse_ohne:.0f}\\,\\%)" + "}\n")
        f.write("\\newcommand{\\benchinsert}{" + f"{insert_ohne:.0f}~ms $\\rightarrow$ {insert_mit:.0f}~ms "
                + f"({100 * (insert_mit / insert_ohne - 1):+.0f}\\,\\%)" + "}\n")
        f.write("\\newcommand{\\benchrows}{%\n" + "\n".join(tex) + "\n}\n")
    print("\nGeschrieben: benchmark_ergebnisse.md, benchmark_ergebnisse.tex")


if __name__ == "__main__":
    main()
