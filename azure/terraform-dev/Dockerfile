ARG BASEIMAGE=
ARG TFIMAGE=
ARG JQIMAGE=

FROM ${TFIMAGE} AS tf
FROM ${JQIMAGE} AS jq

FROM ${BASEIMAGE} AS build

WORKDIR /usr/local/bin
COPY --from=tf /usr/local/bin/terraform .
COPY --from=tf /usr/local/bin/terraform-bundle .
COPY --from=jq /usr/local/bin/jq .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
