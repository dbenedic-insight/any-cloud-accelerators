ARG BASEIMAGE=
ARG GOIMAGE=
ARG OPENSSLIMAGE=
ARG TERRAFORMIMAGE=

FROM ${OPENSSLIMAGE} AS openssl
FROM ${TERRAFORMIMAGE} AS terraform

FROM ${GOIMAGE} AS build
ARG VERSION=latest

RUN apt-get update -qq && apt-get install -y -qq \
    git

WORKDIR /usr/local/src
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/GoogleCloudPlatform/terraformer.git --branch master --single-branch; \
    else git clone https://github.com/GoogleCloudPlatform/terraformer.git --tag ${VERSION} --single-branch; \
    fi

WORKDIR /usr/local/src/${VERSION}
RUN go mod download

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
COPY --from=terraform /usr/local/bin/terraform .

WORKDIR /usr/local/src/terraformer
COPY --from=build /usr/local/src/${VERSION}/ .

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR ${GOROOT}
COPY --from=build /usr/local/go/src ./src
COPY --from=build /usr/local/go/bin ./bin
COPY --from=build /usr/local/go/pkg ./pkg

WORKDIR /

ENTRYPOINT ["/bin/bash"]
