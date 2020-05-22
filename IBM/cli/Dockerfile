ARG BASEIMAGE=
ARG OPENSSLIMAGE=

FROM ${OPENSSLIMAGE} AS openssl

FROM ${BASEIMAGE} AS build
ARG VERSION=
ARG ARCHIVE=IBM_Cloud_CLI_${VERSION}_linux_amd64.tgz
ARG BINPATH=/usr/local/src/ibm-cli

RUN apt-get update -qq && apt-get install -y -qq \
    curl

COPY --from=openssl ${OPENSSLPATH} ${OPENSSLPATH}

WORKDIR /usr/local/src
RUN curl -L -O https://public.dhe.ibm.com/cloud/bluemix/cli/bluemix-cli/${VERSION}/binaries/${ARCHIVE}
RUN mkdir ${BINPATH} \
    && tar xf ${ARCHIVE} -C ${BINPATH} --strip-components 1

WORKDIR ${BINPATH}
RUN curl -O https://public.dhe.ibm.com/cloud/bluemix/cli/bluemix-cli/keys/ibmcloud-cli.pub | tee > ibmcloud-cli.pub
RUN openssl dgst -sha256 -verify ibmcloud-cli.pub -signature ibmcloud.sig ibmcloud
RUN openssl dgst -sha256 -verify ibmcloud-cli.pub -signature ibmcloud-analytics.sig ibmcloud-analytics

RUN ln -s ${BINPATH}/ibmcloud /usr/local/bin/ibmcloud \
    && ln -s ${BINPATH}/ibmcloud-analytics /usr/local/bin/ibmcloud-analytics \
    && echo "alias ic='ibmcloud'" >> /root/.bashrc \
    && echo "alias ica='ibmcloud-analytics'" >> /root/.bashrc

RUN ibmcloud plugin repo-plugins -r 'IBM Cloud' | awk '{if(NR>4)print $3}' | head -n-4 | xargs -I % ibmcloud plugin install % | 2>&1

WORKDIR /
ENV IBMCLOUD_COLOR=true
ENV IBMCLOUD_ANALYTICS=false
ENV IBMCLOUD_VERSION_CHECK=false
ENV IBMCLOUD_HTTP_TIMEOUT=5
ENV IBMCLOUD_API_KEY=
ENV IBMCLOUD_TRACE=false

ENTRYPOINT ["/bin/bash"]
