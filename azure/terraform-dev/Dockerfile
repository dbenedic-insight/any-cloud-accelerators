ARG BASEIMAGE=
ARG TFIMAGE=
ARG PACKERIMAGE=
ARG JQIMAGE=

FROM ${TFIMAGE} AS tf
FROM ${PACKERIMAGE} AS packer
FROM ${JQIMAGE} AS jq

FROM ${BASEIMAGE} AS build

RUN apt-get update -qq && apt-get install -y -qq \
    git

WORKDIR /usr/local/bin
COPY --from=tf /usr/local/bin/terraform .
COPY --from=tf /usr/local/bin/terraform-bundle .
COPY --from=packer /usr/local/bin/packer .
COPY --from=jq /usr/local/bin/jq .

RUN az extension add --name azure-devops

WORKDIR /root/.azure/azuredevops
ADD azuredevops/config .

ENV AZURE_DEVOPS_EXT_PAT=''

WORKDIR /

ENTRYPOINT ["/bin/bash"]
