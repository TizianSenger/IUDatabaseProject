**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0001-01.png)


# **<mark>PORTFOLIO</mark>** 

Aufgabenstellung zum Projekt:  Data-Mart-Erstellung in SQL (DLBDSPBDM01_D) 

## **INHALTSVERZEICHNIS** 

|**1.**<br>**AU**|**FGABENSTELLUNG ................................................................................................................... 2**|
|---|---|
|**1.1.**|**Konzeptionsphase**..................................................................................................................................... 3|
|**1.2.**|**Erarbeitungs-/ Reflexionsphase**.............................................................................................................. 4|
|**1.3.**|**Finalisierungsphase**.................................................................................................................................. 4|
|**2.**<br>**BET**|**REUUNGSPROZESS ................................................................................................................ 5**|
|**3.**<br>**ZU**|**SATZINFORMATIONEN ZUR BEWERTUNG ................................................................................... 6**|
|**4.1.**|**Bestandteile der Prüfungsleistung**......................................................................................................... 8|
|**4.2.**|**Formalia zur Abgabe digitaler Dateien**................................................................................................... 9|
|**4.3.**|**Formalia für das Abstract**....................................................................................................................... 11|



Seite 1 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0002-01.png)


## **1. AUFGABENSTELLUNG** 

Es ist im Rahmen dieses Portfoliokurses die folgende Aufgabenstellung zu entwickeln. 

### **Hinweis zum Urheberrecht und zur Plagiatsprüfung:** 

Es wird darauf hingewiesen, dass der IU Internationale Hochschule GmbH das Urheberrecht der Prüfungsaufgaben/Aufgabenstellungen obliegt. Einer Veröffentlichung der Aufgabenstellungen auf Drittplattformen wird ausdrücklich widersprochen. Im Falle einer Zuwiderhandlung stehen der Hochschule u.a. Unterlassungsansprüche zu. Zudem weisen wir darauf hin, dass jede eingereichte schriftliche Ausarbeitung mittels einer Plagiatssoftware überprüft wird. Wir empfehlen daher auch, keinesfalls ausgearbeitete Lösungen zu teilen, da dies den Verdacht eines Plagiates begründen kann. 

### **Aufgabe: Ein Anwendungsfall für Buchvermietung: Buchtausch-App** 

Du hast zu Hause Bücher, die Du derzeit nicht liest, aber auch nicht loswerden möchtest. Gleichzeitig haben Deine Nachbar:innen Bücher, die Du wirklich gerne lesen würdest, aber sie wollen sie nicht für immer hergeben. Du möchtest eine Datenbank für eine Buchtausch-App erstellen, die den Austausch dieser Bücher auf der Basis von Ausleihen ermöglicht. 

In diesem Abschnitt findest Du eine Beschreibung Deiner Aufgaben zur Definition und Erstellung einer Datenbank für eine Buchtausch-App. Benutzende können auf dieser Plattform ihre Bücher zum Ausleihen anbieten und Bücher ausgeliehen bekommen. Die Datenbank soll von den Studierenden entwickelt werden. 

Das Ziel dieser Anwendung ist es, ein System für die lokale Gemeinschaft bereitzustellen, das auf der gemeinsamen Nutzung von Büchern basiert. Die Benutzenden können Bücher, die sie gerade nicht benötigen, in die Datenbank einstellen und anderen Benutzenden zur Verfügung stellen. Im Gegenzug können sie Bücher ausleihen, die sie gerne lesen möchten und die in der Datenbank verfügbar sind. Das Ausleihen und Zurückgeben der Bücher werden über die App koordiniert, so dass die Benutzenden die Transaktionen einfach verwalten können. 

Die Datenbank für diese App soll alle relevanten Informationen über die Bücher enthalten, wie Autor:in, Titel, Verlag, Genre, Jahr der Veröffentlichung, Sprache und Zustand des Buches. Zusätzlich werden Informationen über die Benutzenden, die die Bücher einstellen und ausleihen, gespeichert, wie zum Beispiel Name, Adresse und Kontaktinformationen. 

Alle Benutzenden sollen die Bücher speichern können, die sie besitzen und ausleihen würden, einschließlich Titel, Autor:in, Sprache, Zustand, wie lange sie verliehen werden können, wo sie abgeholt werden können, Zeitslots und der Möglichkeit, sie per Post zu senden, etc. Die Datenbank muss Informationen liefern, die in Tabellen aufgenommen werden können, aber auch für eine räumliche Suche nützlich sind. Zum Beispiel sollten die Benutzenden der App die App öffnen und auf der Karte sehen können, welche Bücher in ihrer Nähe verfügbar sind, um diese auszuleihen. 

Innerhalb dieses Projekts musst Du eine geeignete Datenbank aufbauen und dokumentieren, die Datenmodelle erstellen und die Datenbank mit einem modernen Datenbank-Management-System aufbauen. 

**Aufgabe** : Erstelle eine Datenbank für die Speicherung und Verarbeitung von Informationen im Zusammenhang mit dem Ausleihen von Büchern. Du kannst jedes Datenbank-Management-System wählen, das SQL als Basissprache verwendet. Definiere eine Datenbankstruktur und bestimmte sinnvolle Dummy-Daten selbst, um eine angemessene Nutzung der Datenbank und einige realisierbare Abfragen zu gewährleisten und, um die Ergebnisse in einem Dokument darzustellen. Stell sicher, dass jeder Schritt und jedes geschriebene SQL-Statement wie in der 

Seite 2 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0003-01.png)


Konzeptionsphase dokumentiert wird. Darüber hinaus muss die Datenbank in angemessener Weise normalisiert werden, um nur notwendige Daten zu speichern. 

Stelle sicher, dass Du deine Datenbank mit angemessenen Dummy-Daten gefüllt hast, um zu gewährleisten, dass Tests und Ergebnisse angezeigt werden. Verwende sinnvolle Daten deiner Wahl. 

Das Datenbankschema wird relational sein und aus mehreren Tabellen bestehen. Die Tabelle "Bücher" kann z.B. alle relevanten Informationen über jedes Buch enthalten, während die Tabelle "Benutzende" Informationen über alle Benutzenden enthält. Eine weitere Tabelle kann die Ausleihvorgänge aufzeichnen, einschließlich des Buches, das ausgeliehen wird, des:r Benutzer:in, der:die es ausleiht, und des Datums der Ausleihe. Eine weitere Tabelle kann die Bewertungen und Kommentare enthalten, die die Benutzenden zu jedem Buch abgeben können. Du kannst ähnliche Tabelle erstellen aber auch zusätzliche, um das Thema am umfangreichsten zu fassen. 

Dein Datenbank-Management-System muss entsprechend der folgenden drei Phasen aufgebaut, dokumentiert und bereitgestellt werden: 

### **1.1. Konzeptionsphase** 

Diese Phase des Datenbankentwurfs wird als **Datenmodellierung** bezeichnet und stellt den wichtigsten Teil des Datenbankdesigns dar. Alles, was in dieser Phase übersehen oder vergessen wird, hat später negative Auswirkungen auf die Umsetzung und führt im schlimmsten Fall zu einer nutzlosen Datenbank. 

Der **erste Schritt** besteht darin, eine Anforderungsspezifikation für die Buchtausch-App zu erstellen. Die Spezifikationen müssen eine Anforderungsanalyse enthalten, die folgende Aspekte detaillierter behandelt: 

- Welche Rollen (Personen/Benutzendengruppen) gibt es? 

- Welche Aktionen führen diese Rollen aus? 

- Welche Daten und Funktionen sind erforderlich? 

Die Anforderungsspezifikation sollte nicht mehr als **zwei Seiten** im 11-Punkt-Schriftgrad umfassen. 

Erstell aus Deiner Anforderungsspezifikation ein sinnvolles **Entity-Relationship-Modell (ERM)** . Die Anforderungen an das ER-Modell sind: 

- Das Modell sollte mindestens 10 Entitäten enthalten. 

- Das Modell sollte 2-3 Dreifachbeziehungen enthalten (Join über drei Tabellen). 

- Gib alle Kardinalitätsspezifikationen in einer von Dir gewählten Notation an (z. B. Chen-Notation). 

- Kurze Beschreibung Ihrer aktuellen Attribute in einem Datenwörterbuch (kurze Beschreibung der Datenattribute und Datentypen sind angemessen). 

Beachte, dass Dein ER-Modell konsistent mit den Rollen, Aktionen und Daten sein muss, die in der Anforderungsspezifikation beschrieben sind. 

Die Abgabe der ersten Phase umfasst **eine pdf-Datei in Schriftgröße 11 (max. 4 Seiten)** .  Diese besteht aus den Anforderungsspezifikation und einer kurzen Beschreibung des bestehenden Problems, Deiner Lösungsansätze im Hinblick auf die Datenbankentwicklung und deines ERMs. Das Textfeld der PebblePad Vorlage kann freigelassen werden. 

Während des gesamten Prozesses gibt es im Rahmen der Online-Veranstaltungen die Möglichkeit, über Ideen und Entwürfe zu sprechen und sich Feedback einzuholen. In den Online-Veranstaltungen werden exemplarisch Arbeiten besprochen, die den Tutor:innen zuvor übermittelt wurden. Hier besteht für alle die Möglichkeit, sich einzubringen und vom Feedback der Anderen zu lernen. **Es wird empfohlen, diese Kanäle zu nutzen, um Fehler zu** 

Seite 3 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0004-01.png)


### **vermeiden und Verbesserungen vorzunehmen. Erst danach sollen die Ergebnisse in der ersten Phase abge-** 

**geben werden.** Hier erfolgt ein abschließendes Feedback durch die Tutor:innen und die Arbeit in der zweiten Phase kann beginnen. 

### **1.2. Erarbeitungs-/ Reflexionsphase** 

In dieser Phase erfolgt die Implementierung der Datenbank auf Grundlage des erstellten ERM-Modells für die Ausleihe von Büchern. Stell sicher, dass jeder SQL-Statement in Deiner Datenbankdatei aufgezeichnet und gut dokumentiert ist. 

- Stell sicher, dass Du Tabellen und Beziehungen für die Datenbank in einer SQL-Daten-Datei lieferst, wie Du das Konzept in Deinem ER-Diagramm skizzierst. 

- Dokumentiere jeden SQL-Statement bezüglich des Erstellungsprozesses. 

- Stell sicher, dass jede Tabelle mindestens 10 Einträge hat. 

- Um Deine erste Entwicklung zu testen, stell sicher, dass Du mindestens einen Testfall für deine Datenbank bezüglich des ER-Modells hast. 

In dieser Phase musst Du eine **Erklärung** deines Datenbankdesigns und des **Implementierungsverfahrens** als Präsentations-PDF mit mindestens **15 Folien** (bezüglich deines ER-Modells) einreichen. Die Folien sollten die Dokumentation der **SQL-Statements** (für jede Entität eine Folie) mit dem entsprechenden Testfall (SQL-Statement) und einem Screenshot des Ergebnisses im Datenbankmanagementsystem enthalten. Bitte gib auch eine kurze **Zusammenfassung der Implementierung** (mindestens eine halbe Seite der 15 Seiten pdf Datei) an. Das Textfeld in der PebblePad Vorlage kann freigelassen werden. 

Während des gesamten Prozesses gibt es im Rahmen der Online-Veranstaltungen und der weiteren Kanäle die Möglichkeit, über Ideen und Entwürfe zu sprechen und sich ausreichend Rückmeldung, Tipps und Hinweise zu holen. **Es wird empfohlen, diese Kanäle zu nutzen, um Fehler zu vermeiden und Verbesserungen vorzunehmen. Erst danach sollen die Ergebnisse in der zweiten Phase abgegeben werden** . Nach dem folgenden abschließenden Feedback durch die Tutor:innen wird in der dritten Phase an dem finalen Entwurf weitergearbeitet. 

### **1.3. Finalisierungsphase** 

In dieser abschließenden Phase geht es darum, Dein Datenbankmanagementsystem zu verfeinern und zu verbessern. Nachdem Du Feedback von deinen Tutor:innen erhalten hast, wird Dein System für die endgültige Abgabe vorbereitet. Bestimmte Elemente müssen möglicherweise verbessert oder geändert werden, um die Aufgabe abzuschließen und diesen Portfolio-Kurs erfolgreich zu absolvieren. 

Als letzten Schritt erstellst Du ein **3-seitiges PDF-Dokument** , indem Du die Funktionalität deines Datenbankmanagementsystems hervorhebst, beschreibst und auch Metadaten speicherst, wie die Anzahl der Tabellen und entsprechenden Einträge sowie die Größe der Datenbank in Bezug auf ihr Volumen. 

In **GitHub** (https://github.com/) wird ein Repository erstellt und Dein Code und Deine Berichte zusammen mit einer README Datei hochgeladen. **Der Link zum Github Repository** wird auch in das finale PDF-Dokument eingefügt. Erstelle **eine ZIP-Datei** , die alle erforderlichen Dateien enthält, einschließlich der SQL-Dateien mit Dokumentation und Installationsanleitung sowie der Präsentationen und einem PDF-Dokument mit allen Ergebnissen aus jeder Phase einschließlich der Folien und Bildschirmfotos, die Du während der drei Phasen gemacht hast. 

Seite 4 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0005-01.png)


Auch in der Finalisierungsphase gibt es im Rahmen der Online-Veranstaltungen und der weiteren Kanäle die Möglichkeit, sich ausreichend Rückmeldung, Tipps und Hinweise zu holen, **bevor** das fertige Produkt final abgegeben wird. **Es wird empfohlen, diese Kanäle zu nutzen, um Fehler zu vermeiden und Verbesserungen vorzunehmen** . Das **fertige Produkt** wird mit den **Ergebnissen aus Phase 1 und Phase 2** sowie zusammen mit den **oben genannten Materialien** eingereicht. Gewünscht ist zusätzlich **ein Abstract (1-1,5 Seiten),** das die Lösung der Aufgabe inhaltlich und konzeptionell beschreibt und einen **kurzen Breakdown (making of)** über die technische Herangehensweise nüchtern und informativ darlegt. 

## **2. BETREUUNGSPROZESS** 

Bei der Betreuung der Portfolios stehen grundsätzlich mehrere Kanäle offen. Die jeweilige Inanspruchnahme liegt dabei im eigenen Verantwortungsbereich. Die eigenständige Erarbeitung eines Produktes und die Befüllung der jeweiligen Portfolioteile ist dabei Teil der zu erbringenden Prüfungsleistung und fließt in die Gesamtbewertung mit ein. 

Zum einen sieht die tutorielle Betreuung Feedbackschleifen zu den einzureichenden Portfolioteilen im Rahmen der Konzeptions- sowie der Erarbeitungs- und Reflexionsphase vor. Das Feedback erfolgt im Rahmen einer Einreichung des jeweiligen Portfolioteils. Des Weiteren werden regelmäßige Online-Tutorien angeboten, in denen Gelegenheit besteht, mit den Tutor: innen Fragen zur Bearbeitung des Portfolios zu besprechen. Die Tutor: innen stehen zusätzlich für fachliche Rücksprachen sowie für formale und allgemeine Fragen zum Vorgehen bei der Portfoliobearbeitung zur Verfügung. 

Technische Fragen zur Nutzung von PebblePad sind per Mail an das Prüfungsamt zu richten. 

Seite 5 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0006-01.png)


## **3. ZUSATZINFORMATIONEN ZUR BEWERTUNG** 

In die Bewertung des Portfolios fließen die folgenden Kriterien mit dem jeweils angegebenen Prozentsatz ein: 

|**Bewertungskriterien**|**Erläuterungen**|**Gewichtung**|
|---|---|---|
|Problemabgrenzung/Zielsetzung|*Erfassung des Problems<br>*Klare Problemabgrenzung/Zielsetzung<br>*Nachvollziehbares Konzept|10%|
|Methodik/Idee/Vorgehen|*Angemessener Transfer von Theorien/Modellen<br>*Klare Angaben zur gewählten Methodik/zur gewählten Idee/zum ge-<br>wählten Vorgehen|20%|
|Qualität der Umsetzung|*Qualität der Umsetzungund Dokumentation|40%|
|Kreativität/Richtigkeit|*Kreativität des Lösungsansatzes<br>*Umgesetzte Lösungerfüllt angestrebte Zielsetzung|20%|
|Formale Anforderungen|*Einhaltungder formalen Vorgaben.|10%|



Bei der Konzeption und Erstellung des Portfolios sollten die genannten Bewertungskriterien einschließlich der folgenden Erläuterungen berücksichtigt werden. 

**Problemabgrenzung/Zielsetzung:** Die Aufgabe besteht darin, eine Datenbankstruktur für eine Buchtausch-App zu entwickeln. Benutzende sollen auf dieser Plattform ihre Bücher zum Ausleihen anbieten und Bücher ausgeliehen bekommen können. Die Datenbank soll alle relevanten Informationen über die Bücher enthalten, wie Autor:in, Titel, Verlag, Genre, Jahr der Veröffentlichung, Sprache und Zustand des Buches, einschließlich wie lange die Bücher verliehen werden können, wo sie abgeholt werden können, Zeitslots und der Möglichkeit, sie per Post zu senden. Zusätzlich werden Informationen über die Benutzenden, die die Bücher einstellen und ausleihen, gespeichert, wie zum Beispiel Name, Adresse und Kontaktinformationen. Die Datenbank soll in angemessener Weise normalisiert werden, um nur notwendige Daten zu speichern, und mit Dummy-Daten gefüllt werden, um Tests und Ergebnisse anzuzeigen. Es wird empfohlen, jede Phase und jedes SQL-Statement zu dokumentieren, um eine angemessene Umsetzung der Datenbank zu gewährleisten. Das Datenbankschema soll relational sein und aus mehreren Tabellen bestehen. 

**Methodik/Idee/Vorgehen:** Diese Aufgabenstellung fordert die Studierenden auf, eine Datenbankstruktur und sinnvolle Dummy-Daten für eine Buchtausch-App zu definieren. Es kann jedes Datenbank-Management-System gewählt werden, das SQL als Basissprache verwendet. Es ist sicherzustellen, dass jeder Schritt und jedes geschriebene SQL-Statement dokumentiert wird. Die Datenbank sollte normalisiert werden, um nur notwendige Daten zu speichern. Zusätzlich sollten auch sinnvolle Dummy-Daten verwendet werden, um Tests und Ergebnisse zu erzeugen. Am Ende sollten die Studierenden eine Datenbankstruktur und einige realisierbare Abfragen in einem Dokument darstellen. Dafür muss SQL erfasst werden können. 

**Qualität der Umsetzung:** Die Bewertung der Qualität der Umsetzung umfasst folgende Punkte: 

- Erfüllung der Anforderungen: Wurden alle Anforderungen an die Datenbankumsetzung erfüllt? Sind alle relevanten Informationen über die Bücher und Benutzenden enthalten? Wurden die Beziehungen zwischen den Tabellen angemessen modelliert? 

- Datenbankdesign: Ist das Datenbankdesign angemessen und gut strukturiert? Sind die Tabellen normalisiert, um Redundanzen und Inkonsistenzen zu vermeiden? 

- Datenintegrität: Wurden geeignete Methoden zur Erhaltung der Datenintegrität implementiert, wie z.B. Fremdschlüsselbeschränkungen und eindeutige Schlüssel? 

Seite 6 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0007-01.png)


- Effizienz: Wurden geeignete Indizes und Abfragemethoden verwendet, um eine effiziente Abfrageleistung zu gewährleisten? 

- Dokumentation: Wurde die Umsetzung des Datenbankschemas und die implementierten SQL-Statements dokumentiert? 

- Dummy-Daten: Wurden sinnvolle Dummy-Daten verwendet, um die Funktionalität der Datenbank zu testen? 

### **Kreativität/Richtigkeit:** 

- Genauigkeit: Wurden die Aufgaben fehlerfrei und gemäß den Vorgaben erledigt? 

- Kreativität: Wie innovativ und originell war die Umsetzung? Gab es neue Ideen und Ansätze? 

**Formale Anforderungen:** Die Einreichung folgt den Akzeptanzkriterien aus Kapitel 1 und den formalen Richtlinien, die im nächsten Kapitel beschrieben werden. Es ist besonders wichtig, die formalen Einreichungsanforderungen, die in Kapitel 4 dargelegt sind, zu beachten. 

Seite 7 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0008-01.png)


## **4. FORMALIA UND VORGABEN ZUR ABGABE** 

### **4.1. Bestandteile der Prüfungsleistung** 

Im Folgenden befindet sich eine Übersicht der Prüfungsleistung Portfolio mit seinen einzelnen Phasen, einzureichenden Einzelleistungen und Feedbackrunden im Überblick. Für die Erarbeitung der Portfolioteile im Rahmen der Prüfungsleistung wird eine Vorlage in PebblePad zur Verfügung gestellt. Die Vorlage ist Bestandteil dieser Prüfungsleistung. 

|**Phase**|**Zwischenergebnis**|**Einzureichende Leistung**|
|---|---|---|
|Konzeptionsphase|Portfolioteil 1|•<br>Anforderungsspezifikation und Beschreibung der Arbeit<br>und Arbeitsschritte max. 4 Seiten als PDF|
|||Feedback|
|Erarbeitungsphase/<br>Reflexionsphase|Portfolioteil 2|•<br>Präsentations-PDF mit mind. 15 Folien einreichen. Diese<br>beinhaltet die Dokumentation der SQL-Statements (für<br>jede Entität eine Folie) mit Testfall und Screenshot sowie<br>die kurze Zusammenfassung der Implementierung (mind.<br>0,5 Seiten) und die .sql Datei(en).|
|||Feedback|
|Finalisierungsphase|Portfolioteil 3|•<br>Abgabe: Erstellung eines GitHub-Repositorien mit Code<br>und Berichten sowie einer README-Datei. Die Abgabe um-<br>fasst eine**ZIP-Datei**mit<br>`o`<br>Dateien von Phasen 1 und 2,<br>`o`<br>einschließlich SQL-Dateien mit Dokumentation<br>und Installationsanleitung,<br>`o`<br>**3-seitiges PDF-Dokument**<br>`o`<br>Abstract (min. 1 Seite, max. 1,5 Seiten)<br>`o`<br>einem Link zum GitHub-Repository.|



Feedback + Note 

Seite 8 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0009-01.png)


### **4.2. Formalia zur Abgabe digitaler Dateien** 

#### **Konzeptionsphase** 

|Empfohlene Hilfsmittel/Software zur<br>Bearbeitung|•<br>Word or LaTex (pdf-File for submission)<br>•<br>Tools to draw ER-Models (e. g. Visio, SmartDraw, Edraw)|
|---|---|
|Zugelassene Dateiformate|PDF|
|Dateigröße|möglichst gering/Preview|
|Weitere Formalien und Parameter|Dateien sind immer nachfolgendem Muster zu benennen:|
||**Für die prüfungsleistungsrelevanten Abgaben auf PebblePad:**<br>Nachname-Vorname_Matrikelnummer_Kurs_Phase_Typ<br>Typen:<br>•<br>**AB**= Anforderungsspezifikation und Beschreibung der Arbeit und Arbeits-<br>schritte max. 4 Seiten als PDF|
||Anforderungsspezifikation<br>Beispiel: Mustermann-Max_12345678_ DLBDSPBDM01_D_Konzeptionsphase_AB|



|**Erarbeitungs-/Reflexionsphase**||
|---|---|
|Empfohlene Hilfsmittel/Software zur<br>Bearbeitung|•<br>PowerPoint or LaTex (pdf-File for submission)<br>•<br>SQL data files (.sql-Data)|
|Zugelassene Dateiformate|PDF und(.sql-Dateien)|
|Dateigröße|möglichst gering/Preview|
|Weitere Formalien und Parameter|Dateien sind immer nachfolgendem Muster zu benennen:|
||**Für die prüfungsleistungsrelevanten Abgaben auf PebblePad:**<br>Nachname-Vorname_Matrikelnummer_Kurs_Phase_Typ<br>Typen:<br>•<br>**PR**= Präsentations-PDF mit mind. 15 Folien einreichen als PDF mit der Doku-<br>mentation der SQL-Statements (für jede Entität eine Folie) mit Testfall und<br>Screenshot<br>•<br>**KZ**= kurze Zusammenfassung der Implementierung (mind. 0,5 Seiten)<br>•<br>**SQL**=.sql Datei(en)|
||Anforderungsspezifikation<br>Beispiel: Mustermann-Max_12345678_ DLBDSPBDM01_D_ Berabeitungs-/Reflexions-<br>phase_KZ|



Seite 9 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0010-01.png)


|**Finalisierungsphase**<br>Empfohlene Hilfsmittel/Software zur<br>Bearbeitung|•<br>Word or LaTex (pdf-File for submission).|
|---|---|
|Zugelassene Dateiformate|PebblePad: PDF<br>− Zip folder: PDF oder .sql Format aus alle 3 Phasen.|
|Dateigröße|möglichst gering/Preview|
|Weitere Formalien und Parameter|WICHTIG ist das Einfügen eines eigens für die Abgabe erstellten zip-Ordners (hierzu<br>bitte Anleitung beachten). In diesem Ordner befinden sich alle Dateien, die Ihr zur Erar-<br>beitung der Aufgabe benutzt habt. Um eine bessere Übersichtlichkeit zu gewährleisten,<br>legt ihr hierzu bitte Unterverzeichnisse an.|
||Ordnerstruktur:<br>Name des Zip-Ordners -> Name: Nachname_Vorname_Matrikelnummer_Kurskürzel<br>o Unterordner-> Name: 01_Konzeptionsphase|
||•<br>Anforderungsspezifikation max. 2 Seiten als PDF<br>•<br>Beschreibung der Arbeit und Arbeitsschritte max. 2 Seiten als PDF<br>o Unterordner -> Name: 02_ Erarbeitungs-/Reflexionsphase|
||•<br>Präsentations-PDF mit mind. 15 Folien einreichen. Diese beinhaltet die Doku-<br>mentation der SQL-Statements (für jede Entität eine Folie) mit Testfall und<br>Screenshot<br>•<br>Kurze Zusammenfassung der Implementierung (mind. 0,5 Seiten)<br>•<br>.sql Datei(en)<br>o Unterordner -> Name: 03_ Finalisierungsphase|
||`o`<br>Dateien von Phasen 1 und 2 (PDF-Dateien)<br>`o`<br>einschließlich SQL-Dateien mit Dokumentation und Installations-<br>anleitung und Ergebnissen aus dieser Phase sowie (in einer PDF-Da-<br>tei).<br>`o`<br>3-seitiges PDF-Dokument (PDF-Datei)<br>`o`<br>Abstract (min. 1 Seite, max. 1,5 Seiten) (PDF-Datei)<br>`o`<br>einem Link zum GitHub-Repository (in einer PDF-Datei).<br>Dateien sind immer nachfolgendem Muster zu benennen:<br>Für die prüfungsleistungsrelevanten Abgaben auf PebblePad:<br>Nachname-Vorname_Matrikelnummer_Kurs_Phase_Typ<br>Typen:<br>`o`<br>SQL = einschließlich SQL-Dateien mit Dokumentation und Installa-<br>tionsanleitung und Ergebnissen aus dieser Phase sowie (in einer<br>PDF-Datei).<br>`o`<br>BE = 3-seitiges PDF-Dokument (PDF-Datei)<br>`o`<br>AB = Abstract (min. 1 Seite, max. 1,5 Seiten) (PDF-Datei)<br>`o`<br>GH = einem Link zum GitHub-Repository (in einer PDF-Datei).<br>Anforderungsspezifikation<br>Beispiel: Mustermann-Max_12345678_ DLBDSPBDM01_D_ Abschlussphase_BE|



Seite 10 von 11 

**PRÜFUNGSAMT IU.DE** 


![](images/Aufgabenstellung_DLBDSPBDM01_D.pdf-0011-01.png)


Achtet bitte bei den Bildern (und ggf. Schriften), die in Eurem Dokument verknüpft sind, darauf, dass Ihr diese entweder einbettet oder mit ins jeweilige Verzeichnis legt. Sonst sind Eure Dokumente nicht vollständig zu öffnen und damit auch nicht zu beurteilen! 

### **4.3. Formalia für das Abstract** 

|Umfang|1 – 1,5 Seiten Textteil|
|---|---|
|Papierformat|DIN A4|
|Seitenränder|Oben und unten 2cm; links 2cm; rechts 2cm|
|Schrifttyp|Allgemeiner Text – Arial 11Pkt; Überschriften – 12Pkt, Blocksatz|
|Zeilenabstand|1,5|
|Satz|Blocksatz und Silbentrennung|
|Fußnoten|Arial 10Pkt, Blocksatz|
|Absätze|Nach gedanklicher Gliederung – 6Pkt Abstand nach Zeilenumbruch|
|Eidesstattliche Erklärung|Die Abgabe der Eidesstattlichen Erklärung erfolgt in elektronischer Form über myCampus.<br>Davor ist keine Einreichung der Prüfungsleistung möglich.<br>Bitte beachtet hierzu die Anleitung für das Einreichen eines Portfolios in myCampus.|



Bei Fragen zur Abgabe des Portfolios wende Dich bitte per Mail an das Prüfungsamt. 

Beachte bitte zusätzlich die Nutzungsanleitung zu PebblePad & Atlas! 

**Viel Erfolg beim Erstellen des Portfolios!** 

Seite 11 von 11 

