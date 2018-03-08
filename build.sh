#!/bin/bash

set -ex

image="$1"
shift

if [ -z "${image}" ]; then
  echo "Usage: $0 IMAGE"
  exit 1
fi

# NB: adhoc builds don't work with this
docker build \
  --build-arg BUILD=${image} \
  --build-arg BUILD_ID=${UPSTREAM_BUILD_ID} \
  "$@" \
  -f "${image}/Dockerfile" \
  .
