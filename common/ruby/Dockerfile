ARG BASEIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} AS openssl

FROM ${BASEIMAGE} as build
ARG VERSION=latest
ARG BUILDPATH=/usr/local/src/build

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

# ruby needs ruby to compile! derp.
RUN apt-get update && apt-get install -y -qq \
  git \
  build-essential \
  autoconf \
  ruby \
  flex \
  bison \
  curl

WORKDIR ${BUILDPATH}
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/ruby/ruby.git --branch master --single-branch $BUILDPATH; \
    else git clone https://github.com/ruby/ruby.git --branch v$(echo $VERSION | sed -e 's/\./\_/g') --single-branch $BUILDPATH; \
    fi

WORKDIR ${BUILDPATH}
RUN ./autogen.sh \
    && ./configure --prefix=/usr/local/src/ruby \
    && make \
    && make install

FROM ${BASEIMAGE} AS final

WORKDIR /etc/ssl/certs
COPY --from=openssl /etc/ssl/certs/ca-certificates.crt .

WORKDIR ${RUBYPATH}
COPY --from=build /usr/local/src/ruby/bin ./bin
COPY --from=build /usr/local/src/ruby/include ./include
COPY --from=build /usr/local/src/ruby/share ./share
COPY --from=build /usr/local/src/ruby/lib ./lib

WORKDIR /

ENTRYPOINT ["/bin/bash"]
