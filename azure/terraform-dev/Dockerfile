ARG BASEIMAGE=
ARG TFIMAGE=
ARG PACKERIMAGE=
ARG JQIMAGE=
ARG AZAPIIMAGE=
ARG HCPCLI=

FROM ${TFIMAGE} AS tf
FROM ${PACKERIMAGE} AS packer
FROM ${JQIMAGE} AS jq
FROM ${AZAPIIMAGE} AS azapi
FROM ${HCPCLI} AS hcpcli

FROM ${BASEIMAGE} AS build

RUN apt-get update -qq && apt-get install -y -qq \
    git

WORKDIR /usr/local/bin
COPY --from=tf /usr/local/bin/terraform .
COPY --from=packer /usr/local/bin/packer .
COPY --from=jq /usr/local/bin/jq .
COPY --from=hcpcli /usr/local/bin/hcp .

RUN az extension add --name azure-devops

WORKDIR /root/.azure/azuredevops
ADD azuredevops/config .

ENV AZURE_DEVOPS_EXT_PAT=''

WORKDIR /usr/local/share/terraform/plugins
COPY --from=azapi /usr/local/share/terraform/plugins .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
