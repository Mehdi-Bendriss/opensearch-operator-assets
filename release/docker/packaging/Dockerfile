FROM ubuntu:22.04

ARG VERSION=2.1.0
ARG PLATFORM=linux

RUN \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        apt-transport-https \
        git \
        rename \
        wget \
    && mkdir -p /etc/apt/keyrings \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
        | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y temurin-11-jdk

WORKDIR /opensearch/source

ADD \
    https://github.com/opensearch-project/OpenSearch/archive/refs/tags/${VERSION}.tar.gz \
    /tmp/${VERSION}.tar.gz

ENV BUILD_DIR="distribution/archives/${PLATFORM}-tar/build"
ENV VERSION=${VERSION}
ENV PLATFORM=${PLATFORM}
CMD \
    tar -xzf /tmp/${VERSION}.tar.gz --strip-components 1 -C . \
    && ./gradlew :distribution:archives:${PLATFORM}-tar:assemble \
    && mkdir -p /opensearch/dist/${VERSION}-${PLATFORM}/ \
    && basename ${BUILD_DIR}/distributions/*.tar.gz \
        | sed "s/-min//g; s/SNAPSHOT-//g; s/.tar.gz//g" \
        | ( \
          read -r name \
          && find ${BUILD_DIR}/install/ -maxdepth 2 -mindepth 2 -exec mv {} ${BUILD_DIR}/install/"${name}" \; \
          && tar -C ${BUILD_DIR}/install/ -czf /opensearch/dist/${VERSION}-${PLATFORM}/"${name}".tar.gz "${name}" \
          )
