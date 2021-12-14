ARG BASEIMAGE=
ARG GOIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} AS openssl

FROM ${GOIMAGE} AS build
ARG VERSION=latest
ARG MODULE=github.com/hashicorp/packer

RUN apt-get update -qq && apt-get install -y \
    git \
    build-essential

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR ${GOPATH}
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/hashicorp/packer.git --branch master --single-branch; \
    else git clone https://github.com/hashicorp/packer.git --branch v${VERSION} --single-branch; \
    fi

WORKDIR ${GOPATH}/packer
RUN go install # Make sure your container has memory headroom to build this! > 4GB

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
COPY --from=build ${GOPATH}/bin/packer .

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
