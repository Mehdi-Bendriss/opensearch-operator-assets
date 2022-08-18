FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

ARG VERSION="2.2.0"
ARG PLUGINS="security"

RUN \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        apt-transport-https \
        git \
        jq \
        openjdk-11-jdk-headless

WORKDIR /opensearch/plugins

COPY plugins.json /tmp/plugins.json

ENV VERSION=${VERSION}
ENV PLUGINS=${PLUGINS}
ENV BASE_PLUGINS_DIR="/opensearch/plugins"
CMD \
    git config --global advice.detachedHead false \
    && readarray -td, plugins <<<"${PLUGINS}" \
    && declare -p plugins \
    && { \
        for plugin in ${plugins}; do \
            echo "Building plugin: opensearch-${plugin}" \

            && read repo buildCmd < <(echo $(jq -r ".[\"${plugin}\"].repo, .[\"${plugin}\"].buildCmd" /tmp/plugins.json)) \
            && rm -rf "${BASE_PLUGINS_DIR}/sources/${plugin}" \
            && git clone -b "${VERSION}.0" --single-branch "${repo}" "${BASE_PLUGINS_DIR}/sources/${plugin}" \

            && pushd "${BASE_PLUGINS_DIR}/sources/${plugin}/" \

            && echo "Running: ${buildCmd/VERSION/$VERSION}" \
            && eval "${buildCmd/VERSION/$VERSION}" \

            && mkdir -p "${BASE_PLUGINS_DIR}/dist/" \
            && mv build/distributions/opensearch-${plugin}-${VERSION}.0.zip "${BASE_PLUGINS_DIR}/dist/opensearch-${plugin}-${VERSION}.zip" \

            && popd; \
        done \
    }

