ARG BASEIMAGE=
ARG TFIMAGE=
ARG PACKERIMAGE=
ARG JQIMAGE=
ARG HCPCLI=

FROM ${TFIMAGE} AS tf
FROM ${PACKERIMAGE} AS packer
FROM ${JQIMAGE} AS jq
FROM ${HCPCLI} AS hcpcli

FROM ${BASEIMAGE} AS build

RUN apt-get update -qq && apt-get install -y -qq \
    git

WORKDIR /usr/local/bin
COPY --from=tf /usr/local/bin/terraform .
COPY --from=packer /usr/local/bin/packer .
COPY --from=jq /usr/local/bin/jq .
COPY --from=hcpcli /usr/local/bin/hcp .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
