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

FROM ${BASEIMAGE} as final

WORKDIR ${PYTHONMODULEPATH}
COPY --from=build ${PYTHONMODULEPATH} .
RUN export PYTHONPATH="${PYTHONPATH}:${PYTHONMODULEPATH}/lib/python$(python -c "import sys; print(f'{sys.version_info[0]}.{sys.version_info[1]}')")/site-packages"

WORKDIR /usr/local/bin
COPY --from=openssl ${OPENSSLPATH} ${OPENSSLPATH}
COPY --from=python ${PYTHONPATH} ${PYTHONPATH}
COPY --from=build /usr/local/src/aws-cli/bin .
COPY --from=build /usr/bin/groff .
RUN echo "complete -C '/usr/local/bin/aws_completer' aws" > ~/.bashrc

WORKDIR ${PYTHONPATH}/awscli
COPY --from=build /usr/local/src/aws-cli/awscli .


WORKDIR /
ENV PYTHONWARNINGS="ignore::DeprecationWarning"
ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
ENV AWS_CONFIG_FILE=
ENV AWS_PROFILE=
ENTRYPOINT ["/bin/bash"]
