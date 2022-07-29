FROM ubuntu:22.04

ARG VERSION=2.1.0
ARG PLATFORM=linux

RUN \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        apache2 \
        apt-transport-https \
        git \
        wget \
    && mkdir -p /etc/apt/keyrings \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
        | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y temurin-11-jdk

COPY install_http_server.sh /

RUN \
    chmod +x /install_http_server.sh \
    && . /install_http_server.sh

WORKDIR /opensearch/source

ENV VERSION=${VERSION}
ENV PLATFORM=${PLATFORM}

# create an opensearch user/group, opensearch cannot run with root
CMD \
    find /opensearch/dist/${VERSION}-${PLATFORM}/ -type f -name "*.tar.gz" \
        | xargs basename \
        | ( \
          read -r name \

          && cp /opensearch/dist/${VERSION}-${PLATFORM}/${name} /var/www/localhost/ \
          && service apache2 restart \
          && service apache2 status \

          && ./gradlew clean \

          && groupadd -g 1000 opensearch \
          && adduser -uid 1000 -gid 1000 --home /opensearch/source --disabled-login --disabled-password --gecos "" opensearch \
          && chown -R 1000:1000 /opensearch/source \
          && chmod -R 0775 /opensearch/source \
          && find /opensearch/source -type f -name "*.java" -exec chmod 666 {} \; \

          && printf "\norg.gradle.daemon=false\n" >> ./gradle.properties \
          && sed -i -e 's/org.gradle.daemon=true/org.gradle.daemon=false/g' ./gradle.properties \
          && sed -i -e 's/org.gradle.parallel=true/org.gradle.parallel=false/g' ./gradle.properties \
          && sed -i -e 's/org.gradle.caching=true/org.gradle.caching=false/g' ./gradle.properties \

          && runuser -l opensearch -c './gradlew clean' \
          && runuser -l opensearch -c './gradlew integTest -PcustomDistributionUrl="https://localhost/${name}" --stacktrace' \

          && touch /opensearch/dist/${VERSION}-${PLATFORM}/SUCCESS \
          )
