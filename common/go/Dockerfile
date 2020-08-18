ARG BASEIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} as openssl

FROM ${BASEIMAGE} AS build
ARG VERSION=
ARG ARCHIVE=go${VERSION}.linux-amd64.tar.gz
ARG TMPSHA=/tmp/goshasum

RUN apt-get update && apt-get install -y -qq \
  curl \
  git

# Scrapes golang dl page - BRITTLE
RUN curl https://golang.org/dl/ \
    | sed -n "/<a class=\"download\" href=\".*${ARCHIVE}\">/,/<\/tr>/p" \
    | sed -n "s:.*<tt>\(.*\)</tt.*:\1:p" \
    > $TMPSHA

WORKDIR /usr/local/src
RUN curl -L -O --insecure https://dl.google.com/go/$ARCHIVE
RUN export GOSHASUM=$(cat $TMPSHA) \
    && echo "$GOSHASUM  $ARCHIVE" > SHA256SUM.txt # two spaces between the sum and filename
RUN grep ${ARCHIVE} SHA256SUM.txt | sha256sum -c -
RUN tar xzf $ARCHIVE

FROM ${BASEIMAGE} AS final

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR ${GOROOT}
COPY --from=build /usr/local/src/go/src ./src
COPY --from=build /usr/local/src/go/bin ./bin
COPY --from=build /usr/local/src/go/pkg ./pkg

WORKDIR /

ENTRYPOINT ["/bin/bash"]
