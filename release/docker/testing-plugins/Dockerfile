FROM ubuntu:22.04

ARG VERSION=2.2.0
ARG PLUGINS=security

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

ENV PLUGINS=${PLUGINS}
ENV BASE_PLUGINS_DIR="/opensearch/plugins"
CMD \
    readarray -td, plugins <<<"${PLUGINS}" \
    && declare -p plugins \
    && { \
        for plugin in ${plugins}; do \
            echo "Testing plugin: opensearch-${plugin}" \

            && read integTestsCmd < <(echo $(jq -r ".[\"${plugin}\"].integrationTestsCmd" /tmp/plugins.json)) \

            && pushd "${BASE_PLUGINS_DIR}/sources/${plugin}/" \

            && echo "Running: ${integTestsCmd}" \
            && eval "${integTestsCmd}" \

            && popd; \
        done \
    }



