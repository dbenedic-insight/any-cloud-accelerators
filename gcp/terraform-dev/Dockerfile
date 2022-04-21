ARG BASEIMAGE=
ARG TFIMAGE=
ARG PACKERIMAGE=
ARG JQIMAGE=
ARG ANSIBLEIMAGE=

FROM ${TFIMAGE} AS tf
FROM ${PACKERIMAGE} AS packer
FROM ${JQIMAGE} AS jq
FROM ${ANSIBLEIMAGE} AS ansible

FROM ${BASEIMAGE} AS build
RUN apt-get update -qq && apt-get install -y -qq \
    git-all

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
COPY --from=tf /usr/local/bin/terraform .
COPY --from=tf /usr/local/bin/terraform-bundle .
COPY --from=packer /usr/local/bin/packer .
COPY --from=jq /usr/local/bin/jq .
COPY --from=ansible ${PYTHONPATH}/. ${PYTHONPATH}
COPY --from=build /usr/bin/git .

WORKDIR /usr/lib/git-core
COPY --from=build /usr/lib/git-core .

WORKDIR /usr/lib/x86_64-linux-gnu
COPY --from=build /usr/lib/x86_64-linux-gnu .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
