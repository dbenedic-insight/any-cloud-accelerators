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
    gnupg

COPY --from=openssl ${OPENSSLPATH} ${OPENSSLPATH}
COPY --from=python ${PYTHONPATH} ${PYTHONPATH}

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    | curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
    && apt-get update -qq && apt-get install -y \
    google-cloud-sdk=${APTPKG}

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
COPY --from=build ${SDKPATH} ${SDKPATH}
RUN ln -s gcloud ${SDKPATH}/bin/gcloud \
    && ln -s bq ${SDKPATH}/bin/bq \
    && ln -s git-credential-gcloud.sh ${SDKPATH}/bin/git-credential-gcloud.sh \
    && ln -s gsutil ${SDKPATH}/bin/gsutil \
    && ln -s anthoscli ${SDKPATH}/bin/anthoscli \

WORKDIR /

ENTRYPOINT ["/bin/bash"]
