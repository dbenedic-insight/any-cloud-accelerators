ARG BASEIMAGE=
ARG GOIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} AS openssl

FROM ${GOIMAGE} AS build
ARG VERSION=latest

RUN apt-get update -qq && apt-get install -y -qq \
    git \
    build-essential \
    curl \
    apt-utils

WORKDIR /usr/local/src
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/hashicorp/hcp.git --branch main --single-branch; \
    else git clone https://github.com/hashicorp/hcp.git --branch v${VERSION} --single-branch; \
    fi

WORKDIR /usr/local/src/hcp
RUN make go/install

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
COPY --from=build ${GOPATH}/bin/hcp .

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
