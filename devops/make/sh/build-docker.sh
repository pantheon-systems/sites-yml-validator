#! /bin/bash

set -eu -o pipefail

function log() {
    echo "(build-docker)" "$@"
}

function build() {
    local image
    local context
    local docker_build_args

    image=$1
    shift
    context=$1
    shift
    docker_build_args=("$@")
    log "building docker image $image"
    # shellcheck disable=SC2068
    docker build --pull ${docker_build_args[@]} -t "$image" "$context"
}

IMAGE="$1"
shift
CONTEXT="$1"
shift
DOCKER_BUILD_ARGS="$*"

if [[ -z $IMAGE ]]; then
    echo "Usage: $0 IMAGE"
    exit 1
fi
FORCE_BUILD=${FORCE_BUILD:-false}
TRY_PULL=${TRY_PULL:-false}
if [[ $FORCE_BUILD == true ]]; then
    log "forcing docker build, not checking existence"
    build "$IMAGE" "$CONTEXT" "$DOCKER_BUILD_ARGS"
    exit
fi
if [[ $(docker images -q "$IMAGE" | wc -l) -gt 0 ]]; then
    log "found $IMAGE locally, not building"
    exit
fi
if [[ $TRY_PULL == true ]]; then
    log "attempting to pull docker image $IMAGE"
    docker pull "$IMAGE" &>/dev/null && exit;
    log "unable to pull image, proceeding to build"
fi
build "$IMAGE" "$CONTEXT" "$DOCKER_BUILD_ARGS"
