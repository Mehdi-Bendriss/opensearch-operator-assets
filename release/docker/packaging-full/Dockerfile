FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

ARG VERSION=2.2.0
ARG PLATFORM=linux

RUN \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        apt-transport-https \
        git \
        openjdk-11-jdk-headless


WORKDIR /opensearch/dist/${VERSION}-${PLATFORM}


ENV VERSION=${VERSION}
ENV PLATFORM=${PLATFORM}
ENV DIST_DIR="/opensearch/dist/${VERSION}-${PLATFORM}"
ENV PLUGINS_DIR="/opensearch/plugins/dist"
ENV RELEASE_DIR="/opensearch/release"
CMD \
    ls -la \
    && tar -xzvf "${DIST_DIR}/opensearch-min-${VERSION}-${PLATFORM}.tar.gz" \
    && pushd "opensearch-${VERSION}" \
    && ( \
        for plugin in "${PLUGINS_DIR}"/*.zip; do \
            echo "Installing Plugin: ${plugin}" \
            && (echo y | bin/opensearch-plugin install "${plugin}") \
        done \
    ) \
    && popd \
    && tar -czvf opensearch-${VERSION}-${PLATFORM}.tar.gz "opensearch-${VERSION}"

