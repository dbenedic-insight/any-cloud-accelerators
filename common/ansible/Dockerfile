ARG BASEIMAGE=
ARG PYTHONIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} AS openssl

FROM ${PYTHONIMAGE} AS build
ARG VERSION=latest

COPY --from=openssl ${OPENSSLPATH} ${OPENSSLPATH}

RUN pip3 install --upgrade pip
RUN if [ "$VERSION" = "latest" ]; \
      then pip3 install ansible; \
      else pip3 install ansible==${VERSION}; \
    fi

WORKDIR /

ENV PYTHONWARNINGS="ignore"

ENTRYPOINT ["/bin/bash"]
