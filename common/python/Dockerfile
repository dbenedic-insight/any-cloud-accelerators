ARG BASEIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} AS openssl

FROM ${BASEIMAGE} AS build
ARG VERSION=
ARG ARCHIVE=Python-${VERSION}.tgz
ARG TMPSHA=/tmp/pythonshasum

RUN apt-get update -qq && apt-get install -y -qq \
  curl \
  build-essential \
  zlib1g-dev \
  libsqlite3-dev \
  libffi-dev \
  gcc

# Scrapes python dl page - BRITTLE
RUN miniversion=$(echo $VERSION | sed -e 's/\.//g') \
    && url="https://www.python.org/downloads/release/python-${miniversion}/" \
    && curl $url \
    | sed -n "/<a href=\".*Python-${VERSION}.tgz\">/,/<\/tr>/p" \
    | sed -n "s:.*<td>\(.*\)</td.*:\1:p" \
    | awk 'length($0) > 25 && length($0) < 35' \
    > $TMPSHA

WORKDIR /usr/local/src
RUN curl -L -O https://www.python.org/ftp/python/${VERSION}/$ARCHIVE
RUN export SHASUM=$(cat $TMPSHA) \
    && echo "$SHASUM  $ARCHIVE" > MD5SUM.txt # two spaces between the sum and filename
RUN grep ${ARCHIVE} MD5SUM.txt | md5sum -c -
RUN mkdir python-build \
    && tar xzf $ARCHIVE -C python-build --strip-components 1

WORKDIR /usr/local/src/python-build
COPY --from=openssl ${OPENSSLPATH} ${OPENSSLPATH}
ENV LDFLAGS="-L$OPENSSLPATH/lib"
ENV CPPFLAGS="-I$OPENSSLPATH/include"
RUN ./configure --enable-optimizations --with-ensurepip=install --prefix=${PYTHONPATH} --with-openssl=${OPENSSLPATH} --with-pydebug \
    && make \
    && make install

RUN pip3 install --upgrade pip

FROM ${BASEIMAGE} as final

WORKDIR ${PYTHONPATH}/bin
COPY --from=build ${PYTHONPATH} ${PYTHONPATH}
RUN ln -s ${PYTHONPATH}/bin/python3 ${PYTHONPATH}/bin/python

WORKDIR /

ENTRYPOINT ["/bin/bash"]
