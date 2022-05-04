ARG BASEIMAGE=
ARG GOIMAGE
ARG JQIMAGE
ARG OPENSSLIMAGE=

FROM ${GOIMAGE} AS go
FROM ${JQIMAGE} AS jq
FROM ${OPENSSLIMAGE} AS openssl

FROM ${BASEIMAGE} AS build
ARG VERSION=latest

RUN apt-get update -qq && apt-get install -y -qq \
    git \
    build-essential \
    curl \
    apt-utils

WORKDIR ${GOROOT}
COPY --from=go ${GOROOT} ${GOROOT}

WORKDIR /usr/local/src
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/hashicorp/consul.git --branch master --single-branch; \
    else git clone https://github.com/hashicorp/consul.git --branch v${VERSION} --single-branch; \
    fi

WORKDIR /usr/local/src/consul
RUN make dev

FROM ${BASEIMAGE} as final

WORKDIR /usr/local/bin
COPY --from=build /usr/local/src/consul/bin/consul .

COPY --from=jq /usr/local/bin/jq .

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
