FROM ubuntu:22.04

ARG VERSION=2.1.0
ARG PLATFORM=linux

RUN \
    apt update \
    && apt upgrade -y \
    && apt install -y \
        apt-transport-https \
        curl \
        g++ \
        gcc \
        git \
        gnupg2 \
        make \
        ruby-full \
        wget \
    && mkdir -p /etc/apt/keyrings \
    && curl -sL https://deb.nodesource.com/setup_lts.x | bash - \
    && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" \
        | tee /etc/apt/sources.list.d/yarn.list \
    && wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc \
    && echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" \
        | tee /etc/apt/sources.list.d/adoptium.list \
    && apt update \
    && apt install -y \
        nodejs \
        temurin-17-jdk \
        yarn

WORKDIR /opensearch/source

ENV VERSION=$VERSION
ENV PLATFORM=$PLATFORM

CMD \
    && rm -f "/opensearch/dist/${VERSION}-${PLATFORM}/SUCCESS" \
    && ls -la /opensearch/dist/${VERSION}-${PLATFORM} \
    && nohup ruby -run -ehttpd /opensearch/dist/${VERSION}-${PLATFORM} -p3000 & \
    && sleep 3s \
    && wget -qO- http://localhost:3000 \
    && find /opensearch/dist/ -type f -name "*.tar.gz" \
        | xargs basename \
        | ( \
          read -r name \
          && ./gradlew integTest -PcustomDistributionUrl="http://localhost:3000/${name}" \
          && touch /opensearch/dist/${VERSION}-${PLATFORM}/SUCCESS \
          )


