#!/usr/bin/env bash

set -e

# --------------------------------------------------------------------------------

function build_image () {
    docker build \
        -t "$3" \
        --build-arg VERSION="$1" \
        --build-arg PLATFORM="$2" \
        --no-cache \
        --progress=plain .
}

function run_container () {
    docker run \
        -d \
        -v opensearch:/opensearch \
        --name "$1" \
        "$2"
}

function wait_until_container_exists () {
    printf "Container '%s': \n" "$1"

    while [ -z "$(docker ps --filter "status=exited" --filter "name=$1" --format '{"ID":"{{ .ID }}"}' | jq .ID)" ]; do
        printf "\t running... \n"
        sleep 45s
    done

    exit_code=$(docker inspect "$1" --format='{{.State.ExitCode}}')
    if [[ $exit_code -ne 0 ]]; then
        printf "\t failed. \n"
        exit 1
    fi

    printf "\t --- \n\t succeeded... \n"
}

# --------------------------------------------------------------------------------

pushd docker

# --------------------------------------------------------------------------------
# ------------------------- Command line args parsing ----------------------------
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
# ------------- Create local volume where to store the tarballs ------------------
printf "\n ------------- \n Creating local volumes... \n ------------- \n"

docker volume create opensearch
docker volume inspect opensearch

# --------------------------------------------------------------------------------
# ---------------------------------- Packaging -----------------------------------
printf "\n ------------- \n Packaging... \n ------------- \n"

pushd packaging

# Build the Image for packaging a platform specific tarball
IMAGE_NAME_PACKAGING=opensearch-packaging-"${version}"-"${platform}"
build_image "${version}" "${platform}" "${IMAGE_NAME_PACKAGING}"

# Store the platform-specific tarball in the local volume
run_container "packaging" "${IMAGE_NAME_PACKAGING}"

popd

# --------------------------------------------------------------------------------

wait_until_container_exists "packaging"

# --------------------------------------------------------------------------------
# ---------------------------------- Testing -------------------------------------
printf "\n ------------- \n Testing... \n ------------- \n"

pushd testing

# Build the Image for running integration tests against the generated platform-specific tarball
IMAGE_NAME_TESTING=opensearch-testing-"${version}"-"${platform}"
build_image "${version}" "${platform}" "${IMAGE_NAME_TESTING}"

# Run the integration tests and store a success file upon success
run_container "testing" "${IMAGE_NAME_TESTING}"

popd

# --------------------------------------------------------------------------------

wait_until_container_exists "testing"

# --------------------------------------------------------------------------------

popd
