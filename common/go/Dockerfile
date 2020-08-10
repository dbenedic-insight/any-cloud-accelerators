ARG BASEIMAGE=

FROM ${BASEIMAGE} AS build
ARG VERSION=
ARG ARCHIVE=go${VERSION}.linux-amd64.tar.gz
ARG GOSHASUM=4a7fa60f323ee1416a4b1425aefc37ea359e9d64df19c326a58953a97ad41ea5

RUN apt-get update && apt-get install -y -qq \
  curl \
  git

WORKDIR /usr/local/src
RUN curl -L -O --insecure https://dl.google.com/go/$ARCHIVE
RUN echo "$GOSHASUM  $ARCHIVE" > SHA256SUM.txt # two spaces between the sum and filename
RUN grep ${ARCHIVE} SHA256SUM.txt | sha256sum -c -
RUN tar xzf $ARCHIVE

FROM ${BASEIMAGE} AS final

WORKDIR ${GOROOT}
COPY --from=build /usr/local/src/go/src ./src
COPY --from=build /usr/local/src/go/bin ./bin
COPY --from=build /usr/local/src/go/pkg ./pkg

WORKDIR /

ENTRYPOINT ["/bin/bash"]
