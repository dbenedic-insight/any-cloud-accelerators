ARG BASEIMAGE=
ARG GOIMAGE=

FROM ${GOIMAGE} AS build
ARG VERSION=latest
ARG MODULE=github.com/hashicorp/packer

RUN apt-get update -qq && apt-get install -y \
    git \
    build-essential

WORKDIR ${GOPATH}
RUN if [ "$VERSION" = "latest" ]; \
    then go get ${MODULE}; \
    else go get ${MODULE}@v${VERSION}; \
    fi
RUN make help

ENTRYPOINT ["/bin/bash"]
