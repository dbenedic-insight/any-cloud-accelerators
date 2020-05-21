ARG BASEIMAGE=

FROM ${BASEIMAGE} as build
ARG VERSION=
ARG ARCHIVE=go${VERSION}.linux-amd64.tar.gz
ARG GOSHASUM=a53dd476129d496047487bfd53d021dd17e0c96895865a0e7d0469ce3db8c8d2

RUN apt-get update && apt-get install -y \
  curl \
  git

WORKDIR /usr/local/src
RUN curl -L -O https://dl.google.com/go/$ARCHIVE
RUN echo "$GOSHASUM  $ARCHIVE" > SHA256SUM.txt # two spaces between the sum and filename
RUN grep ${ARCHIVE} SHA256SUM.txt | sha256sum -c -
RUN tar xzf $ARCHIVE

FROM ${BASEIMAGE} as final

WORKDIR ${GOROOT}
COPY --from=build /usr/local/src/go/src ./src
COPY --from=build /usr/local/src/go/bin ./bin
COPY --from=build /usr/local/src/go/pkg ./pkg

WORKDIR /

ENTRYPOINT ["/bin/bash"]
