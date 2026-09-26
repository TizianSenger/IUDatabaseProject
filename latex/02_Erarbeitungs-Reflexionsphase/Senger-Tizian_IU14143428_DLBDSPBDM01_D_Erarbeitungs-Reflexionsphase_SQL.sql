-- =====================================================================
-- Buchtausch-App -- Datenbankschema, Dummy-Daten und Testfaelle
-- Portfolioteil 2 (Erarbeitungs-/Reflexionsphase) -- DLBDSPBDM01_D
-- Autor: Tizian Senger, Matrikelnummer IU14143428
-- DBMS: SQLite 3 (waehlbar laut Aufgabenstellung, jedes SQL-basierte DBMS)
--
-- Aufbau dieser Datei:
--   1. PRAGMA-Einstellungen
--   2. CREATE TABLE je Entitaet aus dem ER-Modell (Phase 1), inkl. Constraints
--   3. Trigger fuer Geschaeftsregeln, die sich nicht per CHECK abbilden lassen
--   4. Dummy-Daten (>= 10 Datensaetze je Tabelle)
--   5. Testfaelle: (a) erfolgreiche Abfragen je Entitaet, (b) bewusst
--      ungueltige Datensaetze, die an Constraints/Triggern scheitern muessen
--
-- Hinweis zu SQLite: Fremdschluessel muessen pro Verbindung explizit
-- aktiviert werden (PRAGMA foreign_keys = ON), sonst werden FK-Constraints
-- syntaktisch akzeptiert, aber nicht durchgesetzt.
-- =====================================================================

PRAGMA foreign_keys = ON;

-- =====================================================================
-- 2. SCHEMA
-- =====================================================================

-- ---------------------------------------------------------------------
-- NUTZER: registrierte Personen der App (Gast wird nicht persistiert).
-- ---------------------------------------------------------------------
CREATE TABLE nutzer (
    nutzer_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    vorname         VARCHAR(50)  NOT NULL,
    nachname        VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    passwort_hash   VARCHAR(255) NOT NULL,
    telefon         VARCHAR(20),
    rolle           VARCHAR(10)  NOT NULL DEFAULT 'nutzer'
                        CHECK (rolle IN ('nutzer', 'admin')),
    registriert_am  DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ---------------------------------------------------------------------
-- ADRESSE: Wohnadresse je Nutzer:in (1,N)-(1,1) ueber WOHNT_AN.
-- ---------------------------------------------------------------------
CREATE TABLE adresse (
    adresse_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    nutzer_id    INTEGER NOT NULL REFERENCES nutzer(nutzer_id) ON DELETE CASCADE,
    strasse      VARCHAR(100) NOT NULL,
    hausnummer   VARCHAR(10)  NOT NULL,
    plz          VARCHAR(10)  NOT NULL,
    stadt        VARCHAR(50)  NOT NULL,
    land         VARCHAR(50)  NOT NULL DEFAULT 'Deutschland'
);

-- ---------------------------------------------------------------------
-- VERLAG, SPRACHE, GENRE, AUTOR: Stammdaten auf Werk-Ebene, ausgelagert
-- zur Vermeidung redundanter Text-Speicherung (3. Normalform).
-- ---------------------------------------------------------------------
CREATE TABLE verlag (
    verlag_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    name       VARCHAR(100) NOT NULL UNIQUE,
    land       VARCHAR(50)
);

CREATE TABLE sprache (
    sprache_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    bezeichnung  VARCHAR(50) NOT NULL UNIQUE,
    iso_code     CHAR(2) NOT NULL UNIQUE
);

CREATE TABLE genre (
    genre_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    bezeichnung  VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE autor (
    autor_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    vorname   VARCHAR(50) NOT NULL,
    nachname  VARCHAR(50) NOT NULL
);

-- ---------------------------------------------------------------------
-- BUCH: Werk-Ebene (Titel/Verlag/Sprache/Jahr). Enthaelt bewusst KEINEN
-- Eigentuemer und KEINEN Zustand mehr -- das ist Aufgabe von BUCHEXEMPLAR
-- (Feedback Tutor: "Buch vs. Buchexemplar", siehe Phase 1 main.tex).
-- ---------------------------------------------------------------------
CREATE TABLE buch (
    buch_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    titel            VARCHAR(150) NOT NULL,
    verlag_id        INTEGER REFERENCES verlag(verlag_id),
    sprache_id       INTEGER NOT NULL REFERENCES sprache(sprache_id),
    erscheinungsjahr INTEGER NOT NULL CHECK (erscheinungsjahr BETWEEN 1450 AND 2100)
);

-- Aufloesung der M:N-Beziehung VERFASST (Buch--Autor).
CREATE TABLE buch_autor (
    buch_id   INTEGER NOT NULL REFERENCES buch(buch_id)  ON DELETE CASCADE,
    autor_id  INTEGER NOT NULL REFERENCES autor(autor_id) ON DELETE CASCADE,
    PRIMARY KEY (buch_id, autor_id)
);

-- Aufloesung der M:N-Beziehung GEHOERT_ZU (Buch--Genre).
CREATE TABLE buch_genre (
    buch_id   INTEGER NOT NULL REFERENCES buch(buch_id)   ON DELETE CASCADE,
    genre_id  INTEGER NOT NULL REFERENCES genre(genre_id) ON DELETE CASCADE,
    PRIMARY KEY (buch_id, genre_id)
);

-- ---------------------------------------------------------------------
-- BUCHEXEMPLAR: physisches Exemplar eines Werks im Besitz einer Person.
-- Mehrere Nutzende koennen dasselbe BUCH besitzen, weil BESITZT hier und
-- nicht an BUCH haengt (siehe Hinweis in Phase 1, Abschnitt 3).
-- ---------------------------------------------------------------------
CREATE TABLE buchexemplar (
    exemplar_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    buch_id         INTEGER NOT NULL REFERENCES buch(buch_id),
    eigentuemer_id  INTEGER NOT NULL REFERENCES nutzer(nutzer_id) ON DELETE CASCADE,
    zustand         VARCHAR(20) NOT NULL
                        CHECK (zustand IN ('neu', 'gut', 'gebraucht', 'stark gebraucht')),
    erstellt_am     DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ---------------------------------------------------------------------
-- ZEITSLOT: Zeitfenster fuer Abholung/Ausleihe.
-- Constraint (Feedback Tutor Punkt 3): startzeit muss vor endzeit liegen.
-- ---------------------------------------------------------------------
CREATE TABLE zeitslot (
    zeitslot_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    datum        DATE NOT NULL,
    startzeit    TIME NOT NULL,
    endzeit      TIME NOT NULL,
    CHECK (startzeit < endzeit)
);

-- ---------------------------------------------------------------------
-- STANDORT: Abholorte mit Geokoordinaten fuer die Umkreissuche.
-- ---------------------------------------------------------------------
CREATE TABLE standort (
    standort_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    bezeichnung   VARCHAR(100) NOT NULL,
    strasse       VARCHAR(100),
    plz           VARCHAR(10),
    stadt         VARCHAR(50) NOT NULL,
    breitengrad   DECIMAL(9,6) NOT NULL CHECK (breitengrad  BETWEEN -90  AND 90),
    laengengrad   DECIMAL(9,6) NOT NULL CHECK (laengengrad BETWEEN -180 AND 180)
);

-- ---------------------------------------------------------------------
-- VERSANDOPTION: Versand-/Abholangebot je Exemplar.
-- Constraint (Feedback Tutor Punkt 3): Versandkosten duerfen nicht negativ sein.
-- ---------------------------------------------------------------------
CREATE TABLE versandoption (
    versandoption_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    exemplar_id       INTEGER NOT NULL UNIQUE REFERENCES buchexemplar(exemplar_id) ON DELETE CASCADE,
    versandart        VARCHAR(10) NOT NULL
                          CHECK (versandart IN ('abholung', 'post', 'beides')),
    kosten            DECIMAL(6,2) NOT NULL DEFAULT 0.00 CHECK (kosten >= 0)
);

-- ---------------------------------------------------------------------
-- BENACHRICHTIGUNG: Systemnachrichten an Nutzende.
-- ---------------------------------------------------------------------
CREATE TABLE benachrichtigung (
    benachrichtigung_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    nutzer_id            INTEGER NOT NULL REFERENCES nutzer(nutzer_id) ON DELETE CASCADE,
    typ                  VARCHAR(30) NOT NULL,
    inhalt                TEXT NOT NULL,
    gelesen               BOOLEAN NOT NULL DEFAULT 0 CHECK (gelesen IN (0, 1)),
    erstellt_am           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- AUSLEIHE (Dreifachbeziehung LEIHT_AUS): Nutzer (Entleiher:in) x
-- Buchexemplar x Zeitslot. Ein Datensatz entsteht erst durch die
-- Kombination aller drei Fremdschluessel.
-- ---------------------------------------------------------------------
CREATE TABLE ausleihe (
    ausleihe_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    nutzer_id        INTEGER NOT NULL REFERENCES nutzer(nutzer_id),
    exemplar_id      INTEGER NOT NULL REFERENCES buchexemplar(exemplar_id),
    zeitslot_id      INTEGER NOT NULL REFERENCES zeitslot(zeitslot_id),
    ausleihdatum     DATE NOT NULL,
    rueckgabedatum   DATE,
    status           VARCHAR(15) NOT NULL DEFAULT 'aktiv'
                         CHECK (status IN ('aktiv', 'zurueckgegeben', 'ueberfaellig')),
    CHECK (rueckgabedatum IS NULL OR rueckgabedatum >= ausleihdatum),
    UNIQUE (exemplar_id, zeitslot_id)
);

-- ---------------------------------------------------------------------
-- VERFUEGBARKEIT (Dreifachbeziehung VERFUEGBAR_AN): Buchexemplar x
-- Zeitslot x Standort.
-- ---------------------------------------------------------------------
CREATE TABLE verfuegbarkeit (
    verfuegbarkeit_id  INTEGER PRIMARY KEY AUTOINCREMENT,
    exemplar_id        INTEGER NOT NULL REFERENCES buchexemplar(exemplar_id) ON DELETE CASCADE,
    zeitslot_id        INTEGER NOT NULL REFERENCES zeitslot(zeitslot_id)     ON DELETE CASCADE,
    standort_id        INTEGER NOT NULL REFERENCES standort(standort_id),
    verfuegbar         BOOLEAN NOT NULL DEFAULT 1 CHECK (verfuegbar IN (0, 1)),
    UNIQUE (exemplar_id, zeitslot_id, standort_id)
);

-- ---------------------------------------------------------------------
-- BEWERTUNG: eigenstaendige Entitaet, per eindeutigem Fremdschluessel
-- (ausleihe_id, UNIQUE) an genau eine AUSLEIHE gekoppelt -- keine
-- Dreifachbeziehung mehr (Feedback Tutor Punkt 1). Dadurch kann eine
-- Bewertung strukturell nur zu einem tatsaechlich existierenden
-- Ausleihvorgang existieren; Bewertende:r und Eigentuemer:in ergeben
-- sich ueber ausleihe.nutzer_id bzw. buchexemplar.eigentuemer_id.
-- ---------------------------------------------------------------------
CREATE TABLE bewertung (
    bewertung_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    ausleihe_id       INTEGER NOT NULL UNIQUE REFERENCES ausleihe(ausleihe_id) ON DELETE CASCADE,
    sternebewertung   INTEGER NOT NULL CHECK (sternebewertung BETWEEN 1 AND 5),
    kommentar         TEXT,
    bewertungsdatum   DATE NOT NULL DEFAULT CURRENT_DATE
);

-- =====================================================================
-- 3. TRIGGER fuer Geschaeftsregeln, die CHECK (keine Subqueries in
--    SQLite-CHECK-Constraints) nicht abbilden kann.
-- =====================================================================

-- Regel: Man kann kein eigenes Buchexemplar von sich selbst ausleihen.
CREATE TRIGGER trg_ausleihe_kein_eigenausleih
BEFORE INSERT ON ausleihe
FOR EACH ROW
WHEN NEW.nutzer_id = (SELECT eigentuemer_id FROM buchexemplar WHERE exemplar_id = NEW.exemplar_id)
BEGIN
    SELECT RAISE(ABORT, 'Nutzer kann eigenes Buchexemplar nicht ausleihen');
END;

-- Regel (Feedback Tutor Punkt 1): Eine Bewertung darf nur zu einer
-- bereits zurueckgegebenen Ausleihe angelegt werden.
CREATE TRIGGER trg_bewertung_nur_nach_rueckgabe
BEFORE INSERT ON bewertung
FOR EACH ROW
WHEN (SELECT status FROM ausleihe WHERE ausleihe_id = NEW.ausleihe_id) != 'zurueckgegeben'
BEGIN
    SELECT RAISE(ABORT, 'Bewertung nur fuer abgeschlossene (zurueckgegebene) Ausleihen erlaubt');
END;

-- =====================================================================
-- 4. DUMMY-DATEN (>= 10 Datensaetze je Tabelle)
-- =====================================================================

-- NUTZER (12) -----------------------------------------------------------
INSERT INTO nutzer (vorname, nachname, email, passwort_hash, telefon, rolle, registriert_am) VALUES
('Anna',  'Bauer',       'anna.bauer@example.com',       '$2b$12$hashA1', '0170-1000001', 'nutzer', '2025-01-10'),
('Ben',   'Fischer',     'ben.fischer@example.com',      '$2b$12$hashA2', '0170-1000002', 'nutzer', '2025-01-15'),
('Clara', 'Hoffmann',    'clara.hoffmann@example.com',   '$2b$12$hashA3', '0170-1000003', 'nutzer', '2025-02-01'),
('David', 'Krueger',     'david.krueger@example.com',    '$2b$12$hashA4', '0170-1000004', 'nutzer', '2025-02-10'),
('Emma',  'Schulz',      'emma.schulz@example.com',      '$2b$12$hashA5', '0170-1000005', 'nutzer', '2025-02-20'),
('Felix', 'Wagner',      'felix.wagner@example.com',     '$2b$12$hashA6', '0170-1000006', 'nutzer', '2025-03-01'),
('Greta', 'Klein',       'greta.klein@example.com',      '$2b$12$hashA7', '0170-1000007', 'nutzer', '2025-03-12'),
('Hannah','Vogel',       'hannah.vogel@example.com',     '$2b$12$hashA8', '0170-1000008', 'nutzer', '2025-04-01'),
('Ivo',   'Neumann',     'ivo.neumann@example.com',      '$2b$12$hashA9', '0170-1000009', 'nutzer', '2025-04-18'),
('Julia', 'Weber',       'julia.weber@example.com',      '$2b$12$hashB1', '0170-1000010', 'nutzer', '2025-05-02'),
('Karl',  'Zimmermann',  'karl.zimmermann@example.com',  '$2b$12$hashB2', '0170-1000011', 'nutzer', '2025-05-20'),
('Lea',   'Schmid',      'lea.schmid@example.com',       '$2b$12$hashB3', '0170-1000012', 'admin',  '2024-12-01');

-- ADRESSE (12, eine je Nutzer:in) ---------------------------------------
INSERT INTO adresse (nutzer_id, strasse, hausnummer, plz, stadt, land) VALUES
(1,  'Musterstrasse',    '12',  '10115', 'Berlin',     'Deutschland'),
(2,  'Hafenweg',         '4',   '20095', 'Hamburg',    'Deutschland'),
(3,  'Marienplatz',      '7',   '80331', 'Muenchen',   'Deutschland'),
(4,  'Domstrasse',       '21',  '50667', 'Koeln',      'Deutschland'),
(5,  'Zeilweg',          '3',   '60313', 'Frankfurt',  'Deutschland'),
(6,  'Koenigstrasse',    '55',  '70173', 'Stuttgart',  'Deutschland'),
(7,  'Altstadtring',     '9',   '40213', 'Duesseldorf','Deutschland'),
(8,  'Augustusplatz',    '2',   '04109', 'Leipzig',    'Deutschland'),
(9,  'Westfalendamm',    '18',  '44135', 'Dortmund',   'Deutschland'),
(10, 'Ruettenscheider Str.', '30', '45130', 'Essen',   'Deutschland'),
(11, 'Sielwall',         '6',   '28203', 'Bremen',     'Deutschland'),
(12, 'Pragerstrasse',    '14',  '01069', 'Dresden',    'Deutschland');

-- VERLAG (10) -------------------------------------------------------------
INSERT INTO verlag (name, land) VALUES
('Suhrkamp Verlag', 'Deutschland'),
('Fischer Verlag', 'Deutschland'),
('dtv', 'Deutschland'),
('Rowohlt Verlag', 'Deutschland'),
('Diogenes Verlag', 'Schweiz'),
('Piper Verlag', 'Deutschland'),
('Hanser Verlag', 'Deutschland'),
('Reclam Verlag', 'Deutschland'),
('C.H. Beck', 'Deutschland'),
('Klett-Cotta', 'Deutschland');

-- SPRACHE (10) --------------------------------------------------------------
INSERT INTO sprache (bezeichnung, iso_code) VALUES
('Deutsch', 'DE'), ('Englisch', 'EN'), ('Franzoesisch', 'FR'), ('Spanisch', 'ES'),
('Italienisch', 'IT'), ('Russisch', 'RU'), ('Polnisch', 'PL'), ('Niederlaendisch', 'NL'),
('Schwedisch', 'SV'), ('Tuerkisch', 'TR');

-- GENRE (10) ------------------------------------------------------------------
INSERT INTO genre (bezeichnung) VALUES
('Roman'), ('Krimi'), ('Fantasy'), ('Sachbuch'), ('Biografie'),
('Lyrik'), ('Kinderbuch'), ('Science-Fiction'), ('Thriller'), ('Historischer Roman');

-- AUTOR (12) -------------------------------------------------------------------
INSERT INTO autor (vorname, nachname) VALUES
('Franz', 'Kafka'), ('Hermann', 'Hesse'), ('Johann Wolfgang', 'von Goethe'),
('Thomas', 'Mann'), ('Agatha', 'Christie'), ('Arthur Conan', 'Doyle'),
('Isabel', 'Allende'), ('George', 'Orwell'), ('Joanne K.', 'Rowling'),
('Astrid', 'Lindgren'), ('Stefan', 'Zweig'), ('Bertolt', 'Brecht');

-- BUCH (12) ---------------------------------------------------------------------
INSERT INTO buch (titel, verlag_id, sprache_id, erscheinungsjahr) VALUES
('Die Verwandlung', 2, 1, 1915),
('Der Steppenwolf', 1, 1, 1927),
('Faust', 8, 1, 1808),
('Der Zauberberg', 2, 1, 1924),
('Mord im Orientexpress', 3, 1, 1934),
('Das Geisterhaus', 1, 1, 1982),
('1984', 3, 1, 1949),
('Harry Potter und der Stein der Weisen', 4, 1, 1998),
('Pippi Langstrumpf', 4, 1, 1945),
('Schachnovelle', 2, 1, 1942),
('Mutter Courage und ihre Kinder', 1, 1, 1939),
('Ein Skandal in Boehmen', 3, 1, 1891);

-- BUCH_AUTOR (14, inkl. zwei Mehrfachzuordnungen zur Demonstration der M:N-Aufloesung)
INSERT INTO buch_autor (buch_id, autor_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 7), (7, 8), (8, 9),
(9, 10), (10, 11), (11, 12), (12, 6),
(1, 11),  -- Die Verwandlung, Nachwort von Stefan Zweig
(4, 11);  -- Der Zauberberg, Nachwort von Stefan Zweig

-- BUCH_GENRE (14, inkl. zwei Mehrfachzuordnungen) ------------------------------
INSERT INTO buch_genre (buch_id, genre_id) VALUES
(1, 1), (2, 1), (3, 10), (4, 1), (5, 2), (6, 1), (7, 8), (8, 3),
(9, 7), (10, 1), (11, 10), (12, 2),
(7, 9),  -- 1984 zusaetzlich Thriller
(8, 7);  -- Harry Potter zusaetzlich Kinderbuch

-- BUCHEXEMPLAR (15, drei Werke mit je zwei Exemplaren unterschiedlicher
-- Eigentuemer:innen -- zeigt den Mehrwert der Trennung Buch/Buchexemplar) ------
INSERT INTO buchexemplar (buch_id, eigentuemer_id, zustand, erstellt_am) VALUES
(1,  1,  'gut',             '2025-06-01'),
(1,  5,  'neu',             '2025-06-03'),
(2,  2,  'gebraucht',       '2025-06-05'),
(2,  9,  'neu',             '2025-06-06'),
(3,  3,  'gut',             '2025-06-07'),
(4,  4,  'neu',             '2025-06-08'),
(5,  6,  'gut',             '2025-06-09'),
(6,  7,  'gebraucht',       '2025-06-10'),
(7,  8,  'neu',             '2025-06-11'),
(7,  1,  'gut',             '2025-06-12'),
(8,  9,  'gut',             '2025-06-13'),
(9,  10, 'stark gebraucht', '2025-06-14'),
(10, 11, 'gut',             '2025-06-15'),
(11, 12, 'neu',             '2025-06-16'),
(12, 2,  'gebraucht',       '2025-06-17');

-- ZEITSLOT (15) -----------------------------------------------------------------
INSERT INTO zeitslot (datum, startzeit, endzeit) VALUES
('2026-10-01', '09:00', '10:00'), ('2026-10-01', '14:00', '15:00'),
('2026-10-02', '10:00', '11:00'), ('2026-10-02', '16:00', '17:00'),
('2026-10-03', '11:00', '12:00'), ('2026-10-04', '09:30', '10:30'),
('2026-10-05', '13:00', '14:00'), ('2026-10-06', '15:00', '16:00'),
('2026-10-07', '10:00', '11:30'), ('2026-10-08', '17:00', '18:00'),
('2026-10-09', '09:00', '09:45'), ('2026-10-10', '12:00', '13:00'),
('2026-10-11', '14:30', '15:30'), ('2026-10-12', '16:30', '17:30'),
('2026-10-13', '10:15', '11:15');

-- STANDORT (10) -------------------------------------------------------------------
INSERT INTO standort (bezeichnung, strasse, plz, stadt, breitengrad, laengengrad) VALUES
('Stadtbibliothek Mitte',    'Breite Strasse 30', '10178', 'Berlin',      52.518600, 13.408100),
('Cafe Buchseite',           'Hafenweg 4',        '20095', 'Hamburg',     53.550300, 10.000900),
('Buchcafe Marienplatz',     'Marienplatz 7',     '80331', 'Muenchen',    48.137200, 11.575500),
('Nachbarschaftstreff Koeln','Domstrasse 21',     '50667', 'Koeln',       50.941300, 6.958200),
('Lesecafe Frankfurt',       'Zeilweg 3',         '60313', 'Frankfurt',   50.110900, 8.682100),
('Bibliothek Stuttgart-Mitte','Koenigstrasse 55', '70173', 'Stuttgart',   48.775800, 9.182300),
('Buchtreff Duesseldorf',    'Altstadtring 9',    '40213', 'Duesseldorf', 51.225400, 6.776300),
('Leipziger Lesestube',      'Augustusplatz 2',   '04109', 'Leipzig',     51.339700, 12.375900),
('Dortmunder Bucheck',       'Westfalendamm 18',  '44135', 'Dortmund',    51.514500, 7.465600),
('Essener Buchbörse',        'Ruettenscheider Str. 30', '45130', 'Essen', 51.436900, 7.006400);

-- VERSANDOPTION (12) -------------------------------------------------------------
INSERT INTO versandoption (exemplar_id, versandart, kosten) VALUES
(1,  'abholung', 0.00), (2,  'beides',   3.50), (3,  'post',     4.20),
(4,  'abholung', 0.00), (5,  'beides',   2.90), (6,  'abholung', 0.00),
(7,  'post',     3.99), (8,  'abholung', 0.00), (9,  'beides',   3.50),
(10, 'post',     4.50), (11, 'abholung', 0.00), (12, 'beides',   2.50);

-- BENACHRICHTIGUNG (12) ------------------------------------------------------------
INSERT INTO benachrichtigung (nutzer_id, typ, inhalt, gelesen, erstellt_am) VALUES
(1,  'ausleihe_bestaetigt', 'Deine Ausleihe wurde bestaetigt.',            1, '2025-07-01 09:00'),
(2,  'rueckgabe_erinnerung','Bitte gib dein Buch bald zurueck.',           0, '2025-07-05 08:00'),
(3,  'neue_bewertung',      'Du hast eine neue Bewertung erhalten.',       0, '2025-07-06 10:00'),
(4,  'ausleihe_bestaetigt', 'Deine Ausleihe wurde bestaetigt.',            1, '2025-07-07 09:00'),
(5,  'exemplar_verfuegbar', 'Ein gewuenschtes Buch ist jetzt verfuegbar.', 0, '2025-07-08 11:00'),
(6,  'rueckgabe_erinnerung','Bitte gib dein Buch bald zurueck.',           1, '2025-07-09 08:00'),
(7,  'ausleihe_bestaetigt', 'Deine Ausleihe wurde bestaetigt.',            0, '2025-07-10 09:00'),
(8,  'neue_bewertung',      'Du hast eine neue Bewertung erhalten.',       1, '2025-07-11 10:00'),
(9,  'exemplar_verfuegbar', 'Ein gewuenschtes Buch ist jetzt verfuegbar.', 0, '2025-07-12 11:00'),
(10, 'ausleihe_bestaetigt', 'Deine Ausleihe wurde bestaetigt.',            1, '2025-07-13 09:00'),
(11, 'rueckgabe_erinnerung','Bitte gib dein Buch bald zurueck.',           0, '2025-07-14 08:00'),
(12, 'system',              'Willkommen im Buchtausch-App Adminbereich.', 1, '2025-07-15 07:00');

-- AUSLEIHE (12; 10x zurueckgegeben, 1x aktiv, 1x ueberfaellig) --------------------
-- nutzer_id (Entleiher:in) ist bewusst nie identisch mit dem eigentuemer_id des
-- jeweiligen Exemplars (siehe trg_ausleihe_kein_eigenausleih).
INSERT INTO ausleihe (nutzer_id, exemplar_id, zeitslot_id, ausleihdatum, rueckgabedatum, status) VALUES
(2,  1,  1,  '2026-10-01', '2026-10-10', 'zurueckgegeben'),
(3,  2,  2,  '2026-10-01', '2026-10-09', 'zurueckgegeben'),
(4,  3,  3,  '2026-10-02', '2026-10-12', 'zurueckgegeben'),
(5,  4,  4,  '2026-10-02', '2026-10-11', 'zurueckgegeben'),
(1,  5,  5,  '2026-10-03', '2026-10-13', 'zurueckgegeben'),
(6,  6,  6,  '2026-10-04', '2026-10-14', 'zurueckgegeben'),
(7,  7,  7,  '2026-10-05', '2026-10-15', 'zurueckgegeben'),
(2,  8,  8,  '2026-10-06', '2026-10-16', 'zurueckgegeben'),
(9,  9,  9,  '2026-10-07', '2026-10-17', 'zurueckgegeben'),
(10, 10, 10, '2026-10-08', '2026-10-18', 'zurueckgegeben'),
(11, 11, 11, '2026-10-09', NULL,          'aktiv'),
(12, 12, 12, '2026-09-01', NULL,          'ueberfaellig');

-- VERFUEGBARKEIT (15) --------------------------------------------------------------
INSERT INTO verfuegbarkeit (exemplar_id, zeitslot_id, standort_id, verfuegbar) VALUES
(1, 1, 1, 1), (2, 2, 1, 1), (3, 3, 2, 1), (4, 4, 3, 0), (5, 5, 4, 1),
(6, 6, 5, 1), (7, 7, 6, 1), (8, 8, 7, 0), (9, 9, 8, 1), (10, 10, 9, 1),
(11, 11, 10, 1), (12, 12, 1, 1), (13, 13, 2, 1), (14, 14, 3, 0), (15, 15, 4, 1);

-- BEWERTUNG (10, je eine pro zurueckgegebener Ausleihe -- ausleihe_id 1..10) ------
INSERT INTO bewertung (ausleihe_id, sternebewertung, kommentar, bewertungsdatum) VALUES
(1,  5, 'Sehr gepflegtes Exemplar, unkomplizierte Uebergabe.',   '2026-10-11'),
(2,  4, 'Gutes Buch, kleine Verzoegerung bei der Rueckgabe.',    '2026-10-10'),
(3,  5, 'Top Zustand, freundlicher Kontakt.',                    '2026-10-13'),
(4,  3, 'Buch war in Ordnung, Kommunikation etwas schleppend.',  '2026-10-12'),
(5,  5, 'Perfekt, jederzeit wieder.',                            '2026-10-14'),
(6,  4, 'Sehr nett, Buch wie beschrieben.',                      '2026-10-15'),
(7,  2, 'Exemplar war staerker abgenutzt als angegeben.',        '2026-10-16'),
(8,  5, 'Reibungslose Ausleihe.',                                '2026-10-17'),
(9,  4, 'Alles bestens.',                                        '2026-10-18'),
(10, 5, 'Klare Empfehlung.',                                     '2026-10-19');

-- =====================================================================
-- 5a. TESTFAELLE -- je Entitaet eine erfolgreiche Beispielabfrage
--     (fuer die Praesentations-Folien in Phase 2)
-- =====================================================================

-- NUTZER: alle registrierten Nutzenden mit Rolle 'nutzer'
SELECT nutzer_id, vorname, nachname, email FROM nutzer WHERE rolle = 'nutzer';

-- ADRESSE: Adresse von Nutzer:in "Anna Bauer"
SELECT a.strasse, a.hausnummer, a.plz, a.stadt
FROM adresse a JOIN nutzer n ON n.nutzer_id = a.nutzer_id
WHERE n.vorname = 'Anna' AND n.nachname = 'Bauer';

-- VERLAG: alle Verlage mit Sitz in Deutschland
SELECT name FROM verlag WHERE land = 'Deutschland';

-- SPRACHE: ISO-Code zu "Deutsch"
SELECT bezeichnung, iso_code FROM sprache WHERE bezeichnung = 'Deutsch';

-- GENRE: alle Buecher im Genre "Roman"
SELECT b.titel FROM buch b
JOIN buch_genre bg ON bg.buch_id = b.buch_id
JOIN genre g ON g.genre_id = bg.genre_id
WHERE g.bezeichnung = 'Roman';

-- AUTOR: alle Buecher von Franz Kafka
SELECT b.titel FROM buch b
JOIN buch_autor ba ON ba.buch_id = b.buch_id
JOIN autor a ON a.autor_id = ba.autor_id
WHERE a.nachname = 'Kafka';

-- BUCH: Werk-Stammdaten inkl. Verlag und Sprache
SELECT b.titel, v.name AS verlag, s.bezeichnung AS sprache, b.erscheinungsjahr
FROM buch b
JOIN verlag v ON v.verlag_id = b.verlag_id
JOIN sprache s ON s.sprache_id = b.sprache_id;

-- BUCHEXEMPLAR: alle Exemplare des Werks "1984" mit Eigentuemer:in und Zustand
SELECT e.exemplar_id, n.vorname, n.nachname, e.zustand
FROM buchexemplar e
JOIN buch b ON b.buch_id = e.buch_id
JOIN nutzer n ON n.nutzer_id = e.eigentuemer_id
WHERE b.titel = '1984';

-- ZEITSLOT: freie Zeitslots am 2026-10-02
SELECT zeitslot_id, startzeit, endzeit FROM zeitslot WHERE datum = '2026-10-02';

-- STANDORT: Standorte in Berlin
SELECT bezeichnung, strasse, stadt FROM standort WHERE stadt = 'Berlin';

-- VERSANDOPTION: alle Exemplare, die per Post verschickt werden koennen
SELECT exemplar_id, versandart, kosten FROM versandoption WHERE versandart IN ('post', 'beides');

-- BENACHRICHTIGUNG: ungelesene Benachrichtigungen von Ivo Neumann
SELECT be.typ, be.inhalt FROM benachrichtigung be
JOIN nutzer n ON n.nutzer_id = be.nutzer_id
WHERE n.nachname = 'Neumann' AND be.gelesen = 0;

-- AUSLEIHE (LEIHT_AUS): alle abgeschlossenen Ausleihen mit Entleiher:in und Buchtitel
SELECT au.ausleihe_id, n.vorname, n.nachname, b.titel, au.ausleihdatum, au.rueckgabedatum
FROM ausleihe au
JOIN nutzer n ON n.nutzer_id = au.nutzer_id
JOIN buchexemplar e ON e.exemplar_id = au.exemplar_id
JOIN buch b ON b.buch_id = e.buch_id
WHERE au.status = 'zurueckgegeben';

-- VERFUEGBARKEIT (VERFUEGBAR_AN): verfuegbare Exemplare am Standort "Stadtbibliothek Mitte"
SELECT vf.exemplar_id, z.datum, z.startzeit
FROM verfuegbarkeit vf
JOIN standort st ON st.standort_id = vf.standort_id
JOIN zeitslot z ON z.zeitslot_id = vf.zeitslot_id
WHERE st.bezeichnung = 'Stadtbibliothek Mitte' AND vf.verfuegbar = 1;

-- BEWERTUNG: Durchschnittsbewertung je Buchexemplar-Eigentuemer:in
SELECT n.vorname, n.nachname, ROUND(AVG(be.sternebewertung), 2) AS durchschnitt
FROM bewertung be
JOIN ausleihe au ON au.ausleihe_id = be.ausleihe_id
JOIN buchexemplar e ON e.exemplar_id = au.exemplar_id
JOIN nutzer n ON n.nutzer_id = e.eigentuemer_id
GROUP BY n.nutzer_id
ORDER BY durchschnitt DESC;

-- =====================================================================
-- 5b. TESTFAELLE -- bewusst UNGUELTIGE Daten (muessen alle fehlschlagen)
--     Feedback Tutor Punkt 4: nicht nur erfolgreiche Abfragen zeigen,
--     sondern auch Geschaeftsregeln/Constraints aktiv pruefen.
-- =====================================================================

-- (1) CHECK-Constraint: Sternebewertung ausserhalb 1-5 -> muss scheitern
-- INSERT INTO bewertung (ausleihe_id, sternebewertung, kommentar) VALUES (2, 7, 'Ungueltig');
-- Erwartung: "CHECK constraint failed: sternebewertung BETWEEN 1 AND 5"

-- (2) CHECK-Constraint: negative Versandkosten -> muss scheitern
-- INSERT INTO versandoption (exemplar_id, versandart, kosten) VALUES (13, 'post', -5.00);
-- Erwartung: "CHECK constraint failed: kosten >= 0"

-- (3) CHECK-Constraint: Zeitslot mit startzeit >= endzeit -> muss scheitern
-- INSERT INTO zeitslot (datum, startzeit, endzeit) VALUES ('2026-11-01', '15:00', '14:00');
-- Erwartung: "CHECK constraint failed: startzeit < endzeit"

-- (4) FK-Constraint: Ausleihe mit nicht existierender nutzer_id -> muss scheitern
-- WICHTIG: SQLite deaktiviert die Durchsetzung von FOREIGN KEY standardmaessig pro
-- Verbindung. Manche Tools (z. B. manche VS-Code-SQLite-Extensions) oeffnen fuer jede
-- Abfrage eine neue Verbindung, ohne dieses PRAGMA zu setzen -- dann wuerde der Insert
-- unten faelschlicherweise durchgehen. Vor diesem Test daher IMMER zuerst ausfuehren:
-- PRAGMA foreign_keys = ON;
-- INSERT INTO ausleihe (nutzer_id, exemplar_id, zeitslot_id, ausleihdatum, status)
-- VALUES (9999, 1, 2, '2026-10-01', 'aktiv');
-- Erwartung: "FOREIGN KEY constraint failed"

-- (5) Trigger-Geschaeftsregel: Eigentuemer:in leiht eigenes Exemplar aus -> muss scheitern
-- INSERT INTO ausleihe (nutzer_id, exemplar_id, zeitslot_id, ausleihdatum, status)
-- VALUES (1, 1, 2, '2026-10-01', 'aktiv');
-- Erwartung: "Nutzer kann eigenes Buchexemplar nicht ausleihen"

-- (6) Trigger-Geschaeftsregel: Bewertung zu einer noch aktiven Ausleihe -> muss scheitern
-- INSERT INTO bewertung (ausleihe_id, sternebewertung, kommentar) VALUES (11, 5, 'Zu frueh');
-- Erwartung: "Bewertung nur fuer abgeschlossene (zurueckgegebene) Ausleihen erlaubt"
