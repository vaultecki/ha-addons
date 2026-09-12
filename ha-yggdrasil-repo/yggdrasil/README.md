# Yggdrasil (persistent)

Verbindet Home Assistant mit dem [Yggdrasil](https://yggdrasil-network.github.io/)
Overlay-Netzwerk: feste IPv6-Adresse, eingehende Verbindungen, lokale
Peer-Discovery per Multicast.

## Unterschied zum Original-Addon (averyanalex/ha-addons)

Im Original wurde die Konfigurationsdatei bei **jedem Neustart** faktisch neu
erzeugt, weil folgende Zeile die Zieldatei leert, bevor yggdrasil sie einliest:

```sh
yggdrasil -normaliseconf -useconffile ${conf_file} > ${conf_file}
```

Die Shell setzt die `>`-Umleitung ein, bevor das Programm startet - die Datei
ist zum Zeitpunkt des Lesens durch yggdrasil bereits leer. yggdrasil generiert
daraufhin neue Default-Werte (inkl. neuem `PrivateKey`), was die IPv6-Adresse
bei jedem Neustart aendert.

Dieses Addon schreibt stattdessen in eine temporaere Datei und ersetzt die
eigentliche Config erst danach atomar per `mv`. Ausserdem nutzt es das fertige
`yggdrasil`-Paket aus dem Alpine-Repository statt eines eigenen Quellcode-Builds.

## Ersteinrichtung

1. Dieses Verzeichnis als lokales Addon-Repository hinzufuegen (Einstellungen ->
   Add-ons -> Add-on Store -> Drei-Punkte-Menue -> Repositories) oder direkt
   nach `/addons/local/yggdrasil_persistent` kopieren.
2. Addon installieren und starten.
3. In den Logs erscheint die dauerhafte IPv6-Adresse.

## Peers

Der offizielle `yggdrasil-go`-Binary unterstuetzt (anders als der im
Original genutzte Popura-Fork) kein automatisches `-autopeer`. Lokale Geraete
im selben Netzwerk werden weiterhin automatisch per Multicast gefunden. Fuer
eine Verbindung zum oeffentlichen Yggdrasil-Netz oeffne `/data/yggdrasil.conf`
(z.B. ueber den Samba- oder Terminal-Addon) und trage unter `Peers` ein oder
mehrere Eintraege aus der offiziellen Public-Peer-Liste ein:
https://publicpeers.neilalexander.dev/

## Konfiguration zuruecksetzen

Falls du wirklich eine neue Identitaet/IP brauchst: Addon-Option
`regenerate_config` auf `true` setzen, Addon neu starten, danach die Option
wieder auf `false` setzen (sonst wird bei jedem weiteren Neustart eine neue
IP erzeugt).

## Sicherheitshinweis

Alle Ports von Home Assistant sind fuer jeden im Yggdrasil-Netz erreichbar.
Verwende starke Passwoerter bzw. schuetze den Zugriff zusaetzlich (z.B. ueber
Home Assistants eingebaute IP-Filter/Trusted-Networks-Konfiguration).
