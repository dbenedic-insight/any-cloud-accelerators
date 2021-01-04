ARG BASEIMAGE=

FROM ${BASEIMAGE} AS build
ARG VERSION=latest

RUN apt-get update -qq && apt-get install -y -qq \
    build-essential \
    autoconf \
    libtool \
    git

WORKDIR /usr/local/src
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/stedolan/jq.git --branch master --single-branch; \
    else git clone https://github.com/stedolan/jq.git --branch jq-${VERSION} --single-branch; \
    fi

WORKDIR /usr/local/src/jq
RUN git submodule update --init && \
    autoreconf -fi && \
    ./configure --with-oniguruma=builtin --disable-maintainer-mode && \
    make LDFLAGS=-all-static && \
    make install

FROM ${BASEIMAGE} as final

WORKDIR /usr/local/bin
COPY --from=build /usr/local/bin/jq .

WORKDIR /

ENTRYPOINT ["/bin/bash"]
