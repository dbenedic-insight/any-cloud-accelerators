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
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/hashicorp/terraform.git --branch master --single-branch; \
    else git clone https://github.com/hashicorp/terraform.git --branch v${VERSION} --single-branch; \
    fi

WORKDIR /usr/local/src/terraform
RUN go install .

# terraform-bundle was removed from 1.0.0 release. Using https://github.com/hashicorp-services/terraform-bundle-binary
WORKDIR /usr/local/src/terraform-bundle
RUN version="0.1.0" && \
    curl -L -o terraform-bundle "https://github.com/hashicorp-services/terraform-bundle-binary/releases/download/${version}/terraform_bundle_linux_amd64_v0.15.4" && \
    chmod +x terraform-bundle

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
COPY --from=build ${GOPATH}/bin/terraform .
COPY --from=build /usr/local/src/terraform-bundle/terraform-bundle .

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
