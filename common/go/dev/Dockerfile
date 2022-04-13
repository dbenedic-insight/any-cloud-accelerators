ARG BASEIMAGE=
ARG OPENSSLIMAGE=
ARG GOIMAGE=
ARG VAULTIMAGE=

FROM ${GOIMAGE} AS go
FROM ${VAULTIMAGE} AS vault
FROM ${OPENSSLIMAGE} AS openssl

FROM ${BASEIMAGE} as final

WORKDIR /usr/local/bin
COPY --from=vault /usr/local/bin/vault .
RUN vault -autocomplete-install

WORKDIR ${GOROOT}
COPY --from=go ${GOROOT} .

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
