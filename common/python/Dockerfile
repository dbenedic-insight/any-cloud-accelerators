ARG BASEIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} AS openssl

FROM ${BASEIMAGE} AS build
ARG VERSION=
ARG ARCHIVE=Python-${VERSION}.tgz
ARG SHASUM=a7c10a2ac9d62de75a0ca5204e2e7d07

RUN apt-get update -qq && apt-get install -y -qq \
  curl \
  build-essential \
  zlib1g-dev

WORKDIR /usr/local/src
RUN curl -L -O https://www.python.org/ftp/python/${VERSION}/$ARCHIVE
RUN echo "$SHASUM  $ARCHIVE" > MD5SUM.txt # two spaces between the sum and filename
RUN grep ${ARCHIVE} MD5SUM.txt | md5sum -c -
RUN mkdir python-build \
    && tar xzf $ARCHIVE -C python-build --strip-components 1

WORKDIR /usr/local/src/python-build
COPY --from=openssl ${OPENSSLPATH} ${OPENSSLPATH}
ENV LDFLAGS="-L$OPENSSLPATH/lib"
ENV CPPFLAGS="-I$OPENSSLPATH/include"
RUN ./configure --enable-optimizations --with-ensurepip=install --prefix=${PYTHONPATH} --with-openssl=${OPENSSLPATH} \
    && make \
    && make install

FROM ${BASEIMAGE} as final

WORKDIR /usr/local/bin
COPY --from=build ${PYTHONPATH} ${PYTHONPATH}
RUN ln -s ${BUILDPATH}/python ${BUILDPATH}/python3 \
    && ln -s ${BUILDPATH}/pip ${BUILDPATH}/pip3 \

WORKDIR /

ENTRYPOINT ["/bin/bash"]
