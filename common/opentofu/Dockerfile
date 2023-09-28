ARG BASEIMAGE=
ARG GOIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} AS openssl

FROM ${GOIMAGE} AS build
ARG VERSION=latest

RUN apt-get update -qq && apt-get install -y -qq \
    git \
    curl

WORKDIR /usr/local/src
WORKDIR /usr/local/src/opentofu
RUN go install github.com/opentofu/opentofu@${VERSION}

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
COPY --from=build ${GOPATH}/bin/opentf .

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
