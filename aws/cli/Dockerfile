ARG BASEIMAGE=
ARG OPENSSLIMAGE=
ARG PYTHONIMAGE=

FROM ${OPENSSLIMAGE} AS openssl
FROM ${PYTHONIMAGE} AS python

FROM ${BASEIMAGE} AS build
ARG VERSION=

RUN apt-get update -qq && apt-get install -y -qq \
    git \
    gcc \
    libffi-dev \
    groff

COPY --from=openssl ${OPENSSLPATH} ${OPENSSLPATH}
COPY --from=python ${PYTHONPATH} ${PYTHONPATH}

WORKDIR /usr/local/src
RUN if [ "$VERSION" = "latest" ]; \
    then git clone https://github.com/aws/aws-cli.git --branch master --single-branch; \
    else git clone https://github.com/aws/aws-cli.git --branch ${VERSION} --single-branch; \
    fi

WORKDIR ${PYTHONMODULEPATH}
RUN python -m pip install --install-option="--prefix=${PYTHONMODULEPATH}" botocore \
    && python -m pip install --install-option="--prefix=${PYTHONMODULEPATH}" jmespath

WORKDIR /usr/local/src/aws-cli
RUN python -m pip install -r requirements.txt \
    && python -m pip install -e .

WORKDIR /
ENV PYTHONWARNINGS="ignore::DeprecationWarning"
ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
ENTRYPOINT ["/bin/bash"]
