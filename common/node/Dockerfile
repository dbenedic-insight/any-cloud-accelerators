ARG BASEIMAGE=

FROM ${BASEIMAGE} AS build
ARG VERSION=12.16.3
ARG ARCH=linux-x64
ARG ARCHIVE=node-v${VERSION}-${ARCH}.tar.gz

RUN apt-get update -qq && apt-get install -y -qq \
  curl \
  gnupg

WORKDIR /usr/local/src
RUN curl -L -O https://nodejs.org/dist/v${VERSION}/${ARCHIVE}
RUN curl -O https://nodejs.org/dist/v${VERSION}/SHASUMS256.txt
RUN grep ${ARCHIVE} SHASUMS256.txt | sha256sum -c -
RUN tar xzf ${ARCHIVE} -C node --strip-components 1

FROM ${BASEIMAGE} AS final
ARG NODEPATH=/usr/local/src/node

WORKDIR ${NODEPATH}
COPY --from=build /usr/local/src/node ${NODEPATH}

WORKDIR /

ENTRYPOINT ["/bin/bash"]
