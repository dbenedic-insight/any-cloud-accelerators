ARG BASEIMAGE=
ARG GOIMAGE=

FROM ${GOIMAGE} as build
ARG VERSION=latest

RUN apt-get update && apt-get install -y -qq \
    git

WORKDIR /usr/local/src
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/hashicorp/terraform.git --branch master --single-branch; \
    else git clone https://github.com/hashicorp/terraform.git --branch v${VERSION} --single-branch; \
    fi

WORKDIR /usr/local/src/terraform
RUN go install .

FROM ${BASEIMAGE} as final

WORKDIR /usr/local/bin
COPY --from=build ${GOPATH}/bin/terraform .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
