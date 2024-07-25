ARG BASEIMAGE=
ARG TFIMAGE=
ARG PACKERIMAGE=
ARG JQIMAGE=
ARG ANSIBLEIMAGE=
ARG HCPCLI=

FROM ${TFIMAGE} AS tf
FROM ${PACKERIMAGE} AS packer
FROM ${JQIMAGE} AS jq
FROM ${ANSIBLEIMAGE} AS ansible
FROM ${HCPCLI} AS hcpcli

FROM ${BASEIMAGE} AS build
RUN apt-get update -qq && apt-get install -y -qq \
    git-core

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
COPY --from=tf /usr/local/bin/terraform .
COPY --from=packer /usr/local/bin/packer .
COPY --from=jq /usr/local/bin/jq .
COPY --from=ansible ${PYTHONPATH}/. ${PYTHONPATH}
COPY --from=build /usr/bin/git .
COPY --from=hcpcli /usr/local/bin/hcp .

WORKDIR /usr/lib/git-core
COPY --from=build /usr/lib/git-core .

#WORKDIR /usr/lib/x86_64-linux-gnu
#COPY --from=build /usr/lib/x86_64-linux-gnu .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
