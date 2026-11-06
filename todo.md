
#701 BCC für Rechnungsmails: eine Einstellung und zwei Attribute. (S)
#703 Fokus im Editor: Der focusin-Listener läuft in der Capture-Phase und fängt die Events ab, die Hugerte selbst braucht. Außerdem wird hugerte.init pro Element aufgerufen statt einmal. Muss im Browser getestet werden. (S–M)
#598 Standard-Reihenfolge der Widgets: Migration für intPrio plus ORDER BY. (S–M)
#552 Kundendetail lädt langsam: Die Tabs Pläne, Module und Rechnungen per Ajax nachladen. Die Bremse sind checkBooking-Aufrufe in Schleifen. (M)
Nächstes Release nach dem Scheduler-Umbau (V23): Migration V25 (V24 ist durch #689 belegt) löscht scheduler_01 bis scheduler_20. Erst ausliefern, wenn V23 überall läuft. Danach den Abschnitt „Update from the shard tables“ in scheduletasks/readme.txt kürzen. (S)
Neu: Positionstitel einer Buchung enthalten den Zeitraum im Datumsformat der Session (book.cfc, lsDateFormat) statt der Rechnungssprache. (S)
Neu: Übersetzung txtPayInvoice (DE) lautet „Rechnug bezahlen“ – Tippfehler, Migration oder Sysadmin-Übersetzung korrigieren. (S)
Neu: tasks.cfm schreibt bei einem falschen Passwort das eingegebene Passwort ins Log („Password was: …“). Nur IP und Zeit loggen. (S)
Neu: Test-DB – der Volltextindex der Kundentabelle war nach vielen Testläufen veraltet (am 23.10. zum zweiten Mal aufgetreten) (Suchtest rot, nach ALTER TABLE … ENGINE=InnoDB wieder grün). Falls es wieder auftritt: Rebuild in bin/reset_test_db.sh einbauen. (S)
Neu: Andere Entwickler müssen den Lucee-Container einmal neu erstellen (docker compose -f compose-dev.yml up -d lucee), damit der Mount config/db für den Migrations-Spec greift. Im Commit-/Release-Text erwähnen. (S)
P4: Struktur (am besten gemeinsam angehen)

#474 + #527 Zugriff und Rechte zentralisieren: Es gibt 67 verstreute Prüfungen auf session.admin/superadmin/sysadmin in 26 Dateien. Die neue Rollenlogik in user.cfc deckt bisher nur die Benutzerverwaltung ab. Ziel ist ein zentrales can(actor, "tenant.create"); damit wäre auch eine Lücke wie Punkt 1 strukturell verhindert. (M–L)
#346 Font Awesome durch Tabler-Icons ersetzen: 231 Icons in 46 Dateien, die Arbeit ist mechanisch. Passt zum Tabler-Update. (M)
#628 Sprach-Slugs: navSlugs existiert, es fehlen ein Helfer wie getLink() und dessen Einsatz in den Themes. (S–M)
P5: Neue Features (Produktentscheid nötig)

Eher bald: #670 Module pausieren (M), #398 Konto-Löschung erst nach 30 Tagen (M), #508 Erinnerung an ablaufende Kreditkarte (M, das Feld in der Payrexx-API ist noch zu klären), #671 Suche in den Logs (S–M).
Später:
#241 Jahrespreis pro Monat (S–M)
#188 Währungswahl: halb vorhanden, das Frontend zeigt immer die Standardwährung (M)
#225 Gutscheine (L)
#143 Mandanten nur in bestimmten Plänen: zuerst entscheiden
Groß, eher als Modul: #305 Social Login, #324 Ticketsystem, #659 Affiliate (je L, nichts vorhanden).
Neu definieren oder schließen:
#165 Struct statt Query: 74 Funktionen, sehr breiter Umbau mit wenig Nutzen. Besser als Regel für neuen Code festhalten.
