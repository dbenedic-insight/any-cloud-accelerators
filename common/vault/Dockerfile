ARG BASEIMAGE=
ARG GOIMAGE
ARG NODEIMAGE
ARG JQIMAGE
ARG OPENSSLIMAGE=

FROM ${GOIMAGE} AS go
FROM ${NODEIMAGE} AS node
FROM ${JQIMAGE} AS jq
FROM ${OPENSSLIMAGE} AS openssl

FROM ${BASEIMAGE} AS build
ARG VERSION=latest
ARG MODE=

RUN apt-get update -qq && apt-get install -y -qq \
    git \
    build-essential \
    curl \
    apt-utils

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
    tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y -qq \
    yarn

WORKDIR ${GOROOT}
COPY --from=go ${GOROOT} ${GOROOT}

WORKDIR ${NODEPATH}
COPY --from=node ${NODEPATH} ${NODEPATH}

WORKDIR /usr/local/src
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/hashicorp/vault.git --branch master --single-branch; \
    else git clone https://github.com/hashicorp/vault.git --branch v${VERSION} --single-branch; \
    fi

WORKDIR /usr/local/src/vault
RUN make bootstrap
RUN if [ "MODE" = "ui" ]; \
    then make static-dist dev-ui; \
    else make dev; \
    fi

FROM ${BASEIMAGE} as final

WORKDIR /usr/local/bin
COPY --from=build /usr/local/src/vault/bin/vault .
RUN vault -autocomplete-install

COPY --from=jq /usr/local/bin/jq .

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
