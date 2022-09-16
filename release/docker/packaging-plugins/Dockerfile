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

            && PLUGIN_NAME=$(awk -F: '{print $1}' <<< "${plugin}") \
            && TAG_VERSION=$(awk -F: '{print $2==""?"0":$2}' <<< "${plugin}") \

            && read repo buildCmd < <(echo $(jq -r ".[\"${PLUGIN_NAME}\"].repo, .[\"${PLUGIN_NAME}\"].buildCmd" /tmp/plugins.json)) \
            && rm -rf "${BASE_PLUGINS_DIR}/sources/${PLUGIN_NAME}" \
            && git clone -b "${VERSION}.${TAG_VERSION}" --single-branch "${repo}" "${BASE_PLUGINS_DIR}/sources/${PLUGIN_NAME}" \

            && pushd "${BASE_PLUGINS_DIR}/sources/${PLUGIN_NAME}/" \

            && echo "Running: ${buildCmd/VERSION/$VERSION}" \
            && eval "${buildCmd/VERSION/$VERSION}" \

            && mkdir -p "${BASE_PLUGINS_DIR}/dist/" \
            && mv build/distributions/opensearch-${PLUGIN_NAME}-${VERSION}.${TAG_VERSION}.zip "${BASE_PLUGINS_DIR}/dist/opensearch-${PLUGIN_NAME}-${VERSION}.zip" \

            && popd; \
        done \
    }

