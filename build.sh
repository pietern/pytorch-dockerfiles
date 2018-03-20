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
DOCKERFILE="${OS}/Dockerfile"
if [[ "$image" == *-cuda* ]]; then
  DOCKERFILE="${OS}-cuda/Dockerfile"
fi

if [[ "$image" == *-trusty* ]]; then
  UBUNTU_VERSION=14.04
elif [[ "$image" == *-xenial* ]]; then
  UBUNTU_VERSION=16.04
elif [[ "$image" == *-artful* ]]; then
  UBUNTU_VERSION=17.10
fi

# It's annoying to rename jobs every time you want to rewrite a
# configuration, so we hardcode everything here rather than do it
# from scratch
case "$image" in
  pytorch-linux-trusty-py2.7)
    TRAVIS_PYTHON_VERSION=2.7
    ;;
  pytorch-linux-trusty-py3.5)
    TRAVIS_PYTHON_VERSION=3.5
    ;;
  pytorch-linux-trusty-py3.6-gcc4.8)
    ANACONDA_VERSION=3
    GCC_VERSION=4.8
    ;;
  pytorch-linux-trusty-py3.6-gcc5.4)
    ANACONDA_VERSION=3
    GCC_VERSION=5
    ;;
  pytorch-linux-trusty-py3.6-gcc7.2)
    ANACONDA_VERSION=3
    GCC_VERSION=7
    ;;
  pytorch-linux-trusty-pynightly)
    TRAVIS_PYTHON_VERSION=nightly
    ;;
  pytorch-linux-xenial-cuda8-cudnn6-py2)
    CUDA_VERSION=8.0
    CUDNN_VERSION=6
    ANACONDA_VERSION=2
    ;;
  pytorch-linux-xenial-cuda8-cudnn6-py3)
    CUDA_VERSION=8.0
    CUDNN_VERSION=6
    ANACONDA_VERSION=3
    ;;
  pytorch-linux-xenial-cuda9-cudnn7-py2)
    CUDA_VERSION=9.0
    CUDNN_VERSION=7
    ANACONDA_VERSION=2
    ;;
  pytorch-linux-xenial-cuda9-cudnn7-py3)
    CUDA_VERSION=9.0
    CUDNN_VERSION=7
    ANACONDA_VERSION=3
    ;;
  pytorch-linux-xenial-py3-clang5-asan)
    ANACONDA_VERSION=3
    CLANG_VERSION=5.0
    ;;
esac

# Set Jenkins UID and GID if running Jenkins
if [ -n "${JENKINS:-}" ]; then
  JENKINS_UID=$(id -u jenkins)
  JENKINS_GID=$(id -g jenkins)
fi

# Build image
docker build \
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
