FROM ubuntu:22.04

ARG VERSION=2.2.0
ARG PLATFORM=linux

RUN \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        apt-transport-https \
        git \
        openjdk-11-jdk-headless \
        rename \
        wget

WORKDIR /opensearch/source

ADD \
    https://github.com/opensearch-project/OpenSearch/archive/refs/tags/${VERSION}.tar.gz \
    /tmp/${VERSION}.tar.gz

ENV VERSION=${VERSION}
ENV PLATFORM=${PLATFORM}
ENV BUILD_DIR="distribution/archives/${PLATFORM}-tar/build/distributions"
ENV DIST_DIR="/opensearch/dist/${VERSION}-${PLATFORM}"
CMD \
    tar -xzf /tmp/${VERSION}.tar.gz --strip-components 1 -C . \
    && ./gradlew clean :distribution:archives:${PLATFORM}-tar:assemble -Dopensearch.version=${VERSION} -Dbuild.snapshot=false \
    && mkdir -p ${DIST_DIR}/ \
    && mv ${BUILD_DIR}/*.tar.gz ${DIST_DIR}/opensearch-min-${VERSION}-${PLATFORM}.tar.gz
