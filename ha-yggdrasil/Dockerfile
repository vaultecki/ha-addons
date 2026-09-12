ARG BUILD_FROM
FROM $BUILD_FROM

# offizielles yggdrasil-network/yggdrasil-go Paket aus dem Alpine-Repo
# jq wird benoetigt, um die Addon-Optionen (/data/options.json) auszulesen
RUN apk add --no-cache yggdrasil jq

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
