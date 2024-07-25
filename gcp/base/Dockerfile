ARG BASEIMAGE=

FROM ${BASEIMAGE} AS build
ARG VERSION=

ARG SDKPATH=/usr/lib/google-cloud-sdk
ENV SDKPATH="${SDKPATH}"
ENV GOOGLE_APPLICATION_CREDENTIALS="/root/.config/gcloud/"

ENTRYPOINT ["/bin/bash"]
