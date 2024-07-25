ARG BASEIMAGE=
ARG GOIMAGE=
ARG OPENSSLIMAGE=
ARG TERRAFORMIMAGE=
ARG PYTHONIMAGE=
ARG GCPCLIIMAGE=

FROM ${OPENSSLIMAGE} AS openssl
FROM ${TERRAFORMIMAGE} AS terraform
FROM ${GCPCLIIMAGE} AS gcpcli
FROM ${PYTHONIMAGE} AS python

FROM ${GOIMAGE} AS build
ARG VERSION=latest

RUN apt-get update -qq && apt-get install -y -qq \
    git \
    libsqlite3-0

WORKDIR /usr/local/src
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/GoogleCloudPlatform/terraformer.git --branch master --single-branch; \
    else git clone https://github.com/GoogleCloudPlatform/terraformer.git --branch ${VERSION} --single-branch; \
    fi

WORKDIR /usr/local/src/terraformer
RUN go mod download && \
    go run build/main.go google

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
COPY --from=terraform /usr/local/bin/terraform .
COPY --from=openssl ${OPENSSLPATH} ${OPENSSLPATH}
COPY --from=python ${PYTHONPATH} ${PYTHONPATH}

WORKDIR /usr/lib/google-cloud-sdk
COPY --from=gcpcli /usr/lib/google-cloud-sdk/ .
RUN ln -s /usr/lib/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR /usr/local/src/terraformer
COPY --from=build /usr/local/src/terraformer/ .
RUN ln -s /usr/local/src/terraformer/terraformer-google /usr/local/bin/terraformer

WORKDIR /usr/lib/x86_64-linux-gnu/
COPY --from=build /usr/lib/x86_64-linux-gnu/ .

WORKDIR ${GOROOT}
COPY --from=build /usr/local/go/src ./src
COPY --from=build /usr/local/go/bin ./bin
COPY --from=build /usr/local/go/pkg ./pkg

WORKDIR /

ENV PYTHONWARNINGS="ignore"

ENTRYPOINT ["/bin/bash"]
