ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.23
FROM $BUILD_FROM
 
# offizielles yggdrasil-network/yggdrasil-go Paket aus dem Alpine-Repo
# jq wird benoetigt, um die Addon-Optionen (/data/options.json) auszulesen
#
# WICHTIG: --no-scripts, weil das Post-Install-Skript des yggdrasil-Pakets per
# modprobe versucht, das tun-Kernelmodul zu laden. Das schlaegt in JEDER
# Docker-Build-Umgebung fehl (kein Zugriff auf den Host-Kernel) und wuerde den
# Build sonst immer abbrechen. Zur Laufzeit ist das irrelevant, da /dev/net/tun
# bereits ueber "devices:" in config.yaml bereitgestellt wird.
RUN apk add --no-cache --no-scripts yggdrasil jq
 
COPY run.sh /
RUN chmod a+x /run.sh
 
CMD [ "/run.sh" ]
