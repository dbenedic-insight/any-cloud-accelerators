ARG BASEIMAGE=
ARG OPENSSLIMAGE=
ARG PYTHONIMAGE=

FROM ${OPENSSLIMAGE} AS openssl
FROM ${PYTHONIMAGE} AS python

FROM ${BASEIMAGE} AS build
ARG VERSION=
ARG APTPKG=${VERSION}-1

RUN apt-get update -qq && apt-get install -y -qq \
    curl \
    ca-certificates \
    apt-transport-https \
    lsb-release \
    gnupg

RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

RUN export AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" \
    | tee /etc/apt/sources.list.d/azure-cli.list

COPY --from=openssl ${OPENSSLPATH} ${OPENSSLPATH}
COPY --from=python ${PYTHONPATH} ${PYTHONPATH}

RUN export AZ_REPO=$(lsb_release -cs) \
    &&  apt-get update -qq && apt-get install -y -qq \
    azure-cli=${APTPKG}~$AZ_REPO

RUN az extension list-available --query "[? to_string(experimental) == 'false' && to_string(preview) == 'false' && !contains(name, 'batch')].name" -o tsv \
    | xargs -I % az extension add --name % -y

WORKDIR /var/log/az
ENV AZURE_CLOUD_LOGGING_ENABLE_LOG_FILE=true
ENV AZURE_CLOUD_LOGGING_LOG_DIR=/var/log/az

WORKDIR /
ENV AZURE_CORE_OUTPUT=jsonc
ENV AZURE_CORE_COLLECT_TELEMETRY=false
ENV AZURE_CLOUD_NAME=AzureCloud

ENTRYPOINT ["/bin/bash"]
