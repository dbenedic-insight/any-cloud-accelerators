ARG VERSION=latest
ARG JQIMAGE=

FROM ${JQIMAGE} AS jq

FROM ubuntu:${VERSION}
LABEL description = "This image is the shared base image for all other images in this repo. Please refer to README for usage"
LABEL source="https://github.com/dbenedic-insight/any-cloud-accelerators"

ARG GOROOT=/usr/local/go
ARG GOPATH=/usr/local/src/go
ARG NODEPATH=/usr/local/src/node
ARG PYTHONPATH=/usr/local/src/python
ARG PYTHONMODULEPATH=/usr/local/src/python-modules
ARG OPENSSLPATH=/usr/local/src/openssl
ARG JQPATH=/usr/local/bin/jq

WORKDIR ${GOPATH}
ENV GOPATH="${GOPATH}"
WORKDIR ${GOROOT}
ENV GOROOT="${GOROOT}"
ENV PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
WORKDIR ${NODEPATH}
ENV NODEPATH=${NODEPATH}
ENV PATH="${NODEPATH}/bin:${PATH}"
WORKDIR ${PYTHONMODULEPATH}
ENV PYTHONMODULEPATH=${PYTHONMODULEPATH}
WORKDIR ${PYTHONPATH}
ENV PYTHONPATH=${PYTHONPATH}
ENV PATH="${PYTHONPATH}/bin:${PATH}"
WORKDIR ${OPENSSLPATH}
ENV OPENSSLPATH=${OPENSSLPATH}
ENV PATH="${OPENSSLPATH}/bin:${PATH}"
ENV LD_LIBRARY_PATH=${OPENSSLPATH}/lib
RUN echo "export PATH='${PATH}'" >> ~/.profile

COPY --from=jq ${JQPATH} ${JQPATH}

WORKDIR /
ENV DEBIAN_FRONTEND=noninteractive

ENTRYPOINT ["/bin/bash"]
