ARG BASEIMAGE=
ARG OPENSSLIMAGE=
ARG PYTHONIMAGE=

FROM ${OPENSSLIMAGE} AS openssl
FROM ${PYTHONIMAGE} AS python

FROM ${BASEIMAGE} AS build
ARG VERSION=
ARG APTPKG=${VERSION}-0

RUN apt-get update -qq && apt-get install -y -qq \
    curl \
    gnupg \
    libsqlite3-0

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .
COPY --from=python ${PYTHONPATH} ${PYTHONPATH}

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    | curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
    && apt-get update -qq

ENV CLOUDSDK_PYTHON=${PYTHONPATH}/bin/python3

RUN if [ "$VERSION" = "latest" ]; \
    then apt-get install -y google-cloud-cli; \
    else apt-get install -y google-cloud-cli=${APTPK}; \
    fi

ENV PYTHONWARNINGS="ignore"

WORKDIR /

ENTRYPOINT ["/bin/bash"]
