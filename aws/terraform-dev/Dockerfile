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
COPY --from=packer /usr/local/bin/packer .
COPY --from=jq /usr/local/bin/jq .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
