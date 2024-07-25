ARG BASEIMAGE=
ARG OPENSSLIMAGE=
ARG GOIMAGE=
ARG VAULTIMAGE=

FROM ${GOIMAGE} AS go
FROM ${VAULTIMAGE} AS vault
FROM ${OPENSSLIMAGE} AS openssl

FROM ${BASEIMAGE} as build
RUN apt-get update -qq && apt-get install -y -qq \
    build-essential

FROM ${BASEIMAGE} as final

WORKDIR /usr/local/bin
COPY --from=build /usr/bin/make .

COPY --from=vault /usr/local/bin/vault .
RUN vault -autocomplete-install

WORKDIR ${GOROOT}
COPY --from=go ${GOROOT} .

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
