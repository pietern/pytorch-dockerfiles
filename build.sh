#!/bin/bash

set -ex

image="$1"
shift

if [ -z "${image}" ]; then
  echo "Usage: $0 IMAGE"
  exit 1
fi

# TODO: Generalize
OS="ubuntu"

if [[ "$image" == *-trusty* ]]; then
  UBUNTU_VERSION=14.04
elif [[ "$image" == *-xenial* ]]; then
  UBUNTU_VERSION=16.04
elif [[ "$image" == *-artful* ]]; then
  UBUNTU_VERSION=17.10
fi

DOCKERFILE="${OS}/Dockerfile"

if [[ "$image" == *-cuda* ]]; then
  CUDA_VERSION="$(echo "${image}" | perl -n -e'/-cuda(\d+(?:\.\d+)?)/ && print $1')"
  CUDNN_VERSION="$(echo "${image}" | perl -n -e'/-cudnn(\d+)/ && print $1')"
  DOCKERFILE="${OS}-cuda/Dockerfile"

  if [[ "$CUDA_VERSION" == "8" ]]; then
    CUDA_VERSION=8.0
  elif [[ "$CUDA_VERSION" == "9" ]]; then
    CUDA_VERSION=9.0
  fi
fi

if [[ "$image" == *xenial* ]]; then
  # MANDATORY
  ANACONDA_VERSION="$(echo "${image}" | perl -n -e'/-py(\d)/ && print $1')"
else
  if [[ "$image" == *-py* ]]; then
    TRAVIS_PYTHON_VERSION="$(echo "${image}" | perl -n -e'/-py([^-]+)/ && print $1')"
  fi
  GCC_VERSION=5
  if [[ "$image" == *-gcc* ]]; then
    GCC_VERSION="$(echo "${image}" | perl -n -e'/-gcc([^-]+)/ && print $1')"
  fi
  if [[ "$GCC_VERSION" == 5.4 ]]; then
    GCC_VERSION=5
  fi
  if [[ "$GCC_VERSION" == 7.2 ]]; then
    GCC_VERSION=7
  fi
fi

if [[ "$image" == *-clang* ]]; then
  CLANG_VERSION="$(echo "${image}" | perl -n -e'/-clang(\d+(?:\.\d+)?)/ && print $1')"

  if [[ "$CLANG_VERSION" == "5" ]]; then
    CLANG_VERSION=5.0
  fi
fi

# Set Jenkins UID and GID if running Jenkins
if [ -n "${JENKINS:-}" ]; then
  JENKINS_UID=$(id -u jenkins)
  JENKINS_GID=$(id -g jenkins)
fi

# Build image
docker build \
       --no-cache \
       --build-arg "BUILD_ENVIRONMENT=${image}" \
       --build-arg "EC2=${EC2:-}" \
       --build-arg "JENKINS=${JENKINS:-}" \
       --build-arg "JENKINS_UID=${JENKINS_UID:-}" \
       --build-arg "JENKINS_GID=${JENKINS_GID:-}" \
       --build-arg "UBUNTU_VERSION=${UBUNTU_VERSION}" \
       --build-arg "ANACONDA_VERSION=${ANACONDA_VERSION}" \
       --build-arg "CLANG_VERSION=${CLANG_VERSION}" \
       --build-arg "TRAVIS_PYTHON_VERSION=${TRAVIS_PYTHON_VERSION}" \
       --build-arg "GCC_VERSION=${GCC_VERSION}" \
       --build-arg "CUDA_VERSION=${CUDA_VERSION}" \
       --build-arg "CUDNN_VERSION=${CUDNN_VERSION}" \
       -f $(dirname ${DOCKERFILE})/Dockerfile \
       "$@" \
       .
