FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

ARG VERSION=2.2.0
ARG PLATFORM=linux

RUN \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        apache2 \
        apt-transport-https \
        git \
        openjdk-11-jdk-headless

COPY install_http_server.sh /

RUN \
    chmod +x /install_http_server.sh \
    && . /install_http_server.sh \
    && echo y | keytool -importcert -trustcacerts -cacerts -file /etc/ssl/certs/apache-selfsigned.crt -alias apache2 -storepass changeit


WORKDIR /opensearch/dist/${VERSION}-${PLATFORM}


ENV VERSION=${VERSION}
ENV PLATFORM=${PLATFORM}
ENV DIST_DIR="/opensearch/dist/${VERSION}-${PLATFORM}"
ENV PLUGINS_DIR="/opensearch/plugins/dist"
ENV RELEASE_DIR="/opensearch/release"

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
ENV OPENSEARCH_JAVA_OPTS="-Djavax.net.ssl.trustStore=${JAVA_HOME}/lib/security/cacerts"

CMD \
    cp "${PLUGINS_DIR}"/*.zip /var/www/localhost/ \
    && service apache2 restart \
    && service apache2 status \

    && tar -xzvf "${DIST_DIR}/opensearch-min-${VERSION}-${PLATFORM}.tar.gz" \
    && pushd "opensearch-${VERSION}" \

    && ( \
        for plugin in "${PLUGINS_DIR}"/*.zip; do \
            fname=$(basename "${plugin}") \
            name=$(echo "${fname}" | sed -e "s/-${VERSION}.zip//") \
            && echo "Installing Plugin: ${fname}" \
            && (echo y | bin/opensearch-plugin remove "${name}") || true \
            && (echo y | bin/opensearch-plugin install "https://localhost/${fname}")  \
        done \
    ) \
    && popd \
    && tar -czvf opensearch-${VERSION}-${PLATFORM}.tar.gz "opensearch-${VERSION}"
