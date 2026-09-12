#!/bin/sh
set -e

CONF_FILE=/data/yggdrasil.conf
OPTIONS_FILE=/data/options.json

echo "[yggdrasil] Starte Addon..."

# Addon-Option auslesen: darf die Config per Schalter in der UI zurueckgesetzt werden?
REGENERATE="false"
if [ -f "${OPTIONS_FILE}" ]; then
    REGENERATE="$(jq -r '.regenerate_config // false' "${OPTIONS_FILE}" 2>/dev/null || echo false)"
fi

if [ "${REGENERATE}" = "true" ]; then
    echo "[yggdrasil] Option 'regenerate_config' ist aktiviert -> bestehende Konfiguration wird verworfen."
    echo "[yggdrasil] ACHTUNG: Die IPv6-Adresse aendert sich dadurch. Schalte die Option danach wieder aus."
    rm -f "${CONF_FILE}"
fi

if [ ! -s "${CONF_FILE}" ]; then
    echo "[yggdrasil] Keine bestehende Konfiguration in ${CONF_FILE} gefunden - generiere neue Konfiguration."
    yggdrasil -genconf > "${CONF_FILE}"
else
    echo "[yggdrasil] Bestehende Konfiguration gefunden, wird beibehalten."
fi

# WICHTIG, DER EIGENTLICHE FIX:
# "yggdrasil -useconffile ${CONF_FILE} > ${CONF_FILE}" darf NIE so geschrieben werden.
# Die Shell richtet die ">"-Umleitung ein und leert die Zieldatei, BEVOR yggdrasil
# ueberhaupt startet und die Datei einliest. yggdrasil bekommt dadurch eine leere
# Konfiguration, generiert daraus neue Default-Werte (inkl. neuem PrivateKey) und
# schreibt DAS zurueck - bei jedem einzelnen Neustart. Genau das war die Ursache
# fuer die sich staendig aendernde IP im Original-Addon.
#
# Fix: in eine Temp-Datei schreiben, erst danach atomar ueber die Zieldatei verschieben.
TMP_FILE="$(mktemp /data/yggdrasil.conf.XXXXXX)"
yggdrasil -normaliseconf -useconffile "${CONF_FILE}" > "${TMP_FILE}"

if [ -s "${TMP_FILE}" ]; then
    mv "${TMP_FILE}" "${CONF_FILE}"
else
    echo "[yggdrasil] WARNUNG: Normalisierung hat eine leere Ausgabe erzeugt."
    echo "[yggdrasil] Die bestehende Konfiguration wird zur Sicherheit NICHT ueberschrieben."
    rm -f "${TMP_FILE}"
fi

echo "[yggdrasil] Yggdrasil IPv6-Adresse (bleibt jetzt dauerhaft erhalten):"
yggdrasil -address -useconffile "${CONF_FILE}"

echo "[yggdrasil] Starte Yggdrasil..."
exec yggdrasil -useconffile "${CONF_FILE}"
