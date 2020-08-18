ARG BASEIMAGE=
ARG PYTHONIMAGE=
ARG OPENSSL=

FROM ${PYTHONIMAGE} AS build
ARG VERSION=latest

RUN pip3 install --upgrade pip
RUN pip3 install ansible==${VERSION}

WORKDIR /

ENV PYTHONWARNINGS="ignore"

ENTRYPOINT ["/bin/bash"]
