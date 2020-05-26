ARG BASEIMAGE=

FROM ${BASEIMAGE} AS build
ARG VERSION=
ARG ARCHIVE=go${VERSION}.linux-amd64.tar.gz
ARG GOSHASUM=1c39eac4ae95781b066c144c58e45d6859652247f7515f0d2cba7be7d57d2226

RUN apt-get update && apt-get install -y -qq \
  curl \
  git

WORKDIR /usr/local/src
RUN curl -L -O https://dl.google.com/go/$ARCHIVE
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
