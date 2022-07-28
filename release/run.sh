#!/usr/bin/env bash

set -e

pushd docker

# --------------------------------------------------------------------------------
# Command line args parsing
printf "\n ------------- \n Command line parsing... \n ------------- \n"

version=${version:-2.1.0}
platform=${platform:-linux}

while [ $# -gt 0 ]; do
    if [[ $1 == "--help" ]]; then
        usage
        exit 0
    elif [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare "$param"="$2"
    fi
    shift
done

printf "\t Version: %s" "${version}"
printf "\t Platform: %s" "${platform}"

# --------------------------------------------------------------------------------
# Packaging
printf "\n ------------- \n Packaging... \n ------------- \n"

pushd packaging

# Create local volume where to store the tarballs
docker volume create opensearch
docker volume inspect opensearch

# Build the Image for packaging a platform specific tarball
IMAGE_NAME_PACKAGING=opensearch-packaging-"${version}"-"${platform}"

docker build \
    -t "${IMAGE_NAME_PACKAGING}" \
    --build-arg VERSION="${version}" \
    --build-arg PLATFORM="${platform}" \
    --no-cache \
    --progress=plain .

# Store the platform-specific tarball in the local volume
docker run \
    -d \
    -v opensearch:/opensearch \
    "${IMAGE_NAME_PACKAGING}"

popd

# --------------------------------------------------------------------------------
# Testing
printf "\n ------------- \n Testing... \n ------------- \n"

pushd testing

# Build the Image for running integration tests against the generated platform-specific tarball
IMAGE_NAME_TESTING=opensearch-testing-"${version}"-"${platform}"

docker build \
    -t "${IMAGE_NAME_TESTING}" \
    --build-arg VERSION="${version}" \
    --build-arg PLATFORM="${platform}" \
    --no-cache \
    --progress=plain .

# Run the integration tests and store a success file upon success
docker run \
    -d \
    -v opensearch:/opensearch \
    "${IMAGE_NAME_TESTING}"

popd
# --------------------------------------------------------------------------------

popd
