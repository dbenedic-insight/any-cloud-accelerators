ARG BASEIMAGE=
ARG GOIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} AS openssl

FROM ${GOIMAGE} AS build
ARG VERSION=latest

RUN apt-get update -qq && apt-get install -y -qq \
    git \
    build-essential \
    autoconf \
    curl

WORKDIR /usr/local/src
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/Azure/terraform-provider-azapi.git --branch main --single-branch; \
    else git clone https://github.com/Azure/terraform-provider-azapi --branch v${VERSION} --single-branch; \
    fi

WORKDIR /usr/local/src/terraform-provider-azapi
RUN make tools && make build

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/share/terraform/plugins
COPY --from=build ${GOPATH}/bin/terraform-provider-azapi .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
