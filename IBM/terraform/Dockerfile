ARG BASEIMAGE=
ARG TFIMAGE=
ARG GOIMAGE=

FROM ${TFIMAGE} AS tf
FROM ${GOIMAGE} AS go

FROM ${BASEIMAGE} AS build
ARG VERSION=latest

RUN apt-get update -qq && apt-get install -y -qq \
    git \
    build-essential \
    zip

WORKDIR ${GOROOT}
COPY --from=go ${GOROOT} ${GOROOT}

WORKDIR ${GOPATH}/src/github.com/IBM-Cloud
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/IBM-Cloud/terraform-provider-ibm --branch master --single-branch; \
    else git clone https://github.com/IBM-Cloud/terraform-provider-ibm --branch v${VERSION} --single-branch; \
    fi

WORKDIR ${GOPATH}/src/github.com/IBM-Cloud/terraform-provider-ibm
RUN make build
RUN ./scripts/build.sh

FROM ${BASEIMAGE} as final
WORKDIR /usr/local/bin
COPY --from=tf /usr/local/bin/terraform .

WORKDIR /root/.terraform.d/plugins
COPY --from=build ${GOPATH}/bin/terraform-provider-ibm .

WORKDIR /
ENV IC_API_KEY=
ENV IAAS_CLASSIC_API_KEY=
ENV IAAS_CLASSIC_USERNAME=

ENTRYPOINT ["/bin/bash"]
