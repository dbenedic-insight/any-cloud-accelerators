ARG BASEIMAGE=
ARG TFIMAGE=

FROM ${TFIMAGE} AS tf

FROM ${BASEIMAGE} AS build

RUN apt-get update -qq && apt-get install -y -qq \
    curl

FROM ${BASEIMAGE} AS final

WORKDIR /usr/local/bin
copy --from=build /usr/bin/curl .
COPY --from=tf /usr/local/bin/terraform .
COPY --from=tf /usr/local/bin/terraform-bundle .

WORKDIR /

ENTRYPOINT ["/usr/local/bin/vault", "server", "-dev"]
