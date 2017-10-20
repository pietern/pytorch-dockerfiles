#!/bin/bash

set -e

APT_INSTALL_CMD="apt-get install -y --no-install-recommends"

source /etc/lsb-release

case "$BUILD" in
  linux)
    :
    ;;
  linux-gcc5)
    export GCC_VERSION=5
    ;;
  linux-cuda)
    export CUDA_VERSION=8
    ;;
  linux-cuda8-cudnn5)
    export CUDA_VERSION=8
    export CUDNN_VERSION=5
    ;;
  linux-cuda8-cudnn6)
    export CUDA_VERSION=8
    export CUDNN_VERSION=6
    ;;
  linux-cuda9-cudnn7)
    export CUDA_VERSION=9
    export CUDNN_VERSION=7
    ;;
  linux-mkl)
    export MKL=1
    ;;
  linux-android)
    export ANDROID=1
    ;;
  *)
    echo "Unsupported BUILD: $BUILD"
    exit 1
    ;;
esac


# Optionally install GCC 5
if [ -n "$GCC_VERSION" ] && [ "$GCC_VERSION" -eq 5 ]; then
  add-apt-repository -y ppa:ubuntu-toolchain-r/test
  apt-get update
  $APT_INSTALL_CMD g++-5
  update-alternatives \
    --install /usr/bin/gcc gcc /usr/bin/gcc-5 60 \
    --slave /usr/bin/g++ g++ /usr/bin/g++-5
fi

# Optionally install CUDA
if [ -n "$CUDA_VERSION" ]; then
  case "$DISTRIB_RELEASE" in
    14.04)
      CUDA_REPO_PATH="ubuntu1404"
      case "$CUDA_VERSION" in
        8)
          CUDA_REPO_PKG="cuda-repo-ubuntu1404_8.0.61-1_amd64.deb"
          CUDA_PKG_VERSION="8-0"
          CUDA_VERSION="8.0"
        ;;
        *)
          echo "Unsupported CUDA_VERSION: $CUDA_VERSION"
          exit 1
          ;;
      esac
      ;;
    16.04)
      CUDA_REPO_PATH="ubuntu1604"
      case "$CUDA_VERSION" in
        8)
          CUDA_REPO_PKG="cuda-repo-${CUDA_REPO_PATH}_8.0.61-1_amd64.deb"
          CUDA_PKG_VERSION="8-0"
          CUDA_VERSION="8.0"
          ;;
        9)
          CUDA_REPO_PKG="cuda-repo-${CUDA_REPO_PATH}_9.0.176-1_amd64.deb"
          CUDA_PKG_VERSION="9-0"
          CUDA_VERSION="9.0"
          ;;
        *)
          echo "Unsupported CUDA_VERSION: $CUDA_VERSION"
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Unsupported DISTRIB_RELEASE: $DISTRIB_RELEASE"
      exit 1
      ;;
  esac

  # Install NVIDIA key on 16.04 before installing packages
  if [ "$DISTRIB_RELEASE" == "16.04" ]; then
    apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
  fi

  CUDA_BASE_URL="https://developer.download.nvidia.com/compute/cuda/repos"

  pushd /tmp
  wget "${CUDA_BASE_URL}/${CUDA_REPO_PATH}/x86_64/${CUDA_REPO_PKG}"
  dpkg -i "$CUDA_REPO_PKG"
  rm -f "$CUDA_REPO_PKG"
  popd

  apt-get update
  $APT_INSTALL_CMD \
    "cuda-core-${CUDA_PKG_VERSION}" \
    "cuda-cublas-dev-${CUDA_PKG_VERSION}" \
    "cuda-cudart-dev-${CUDA_PKG_VERSION}" \
    "cuda-curand-dev-${CUDA_PKG_VERSION}" \
    "cuda-driver-dev-${CUDA_PKG_VERSION}" \
    "cuda-nvrtc-dev-${CUDA_PKG_VERSION}"

  # Manually create CUDA symlink
  ln -sf "/usr/local/cuda-${CUDA_VERSION}" /usr/local/cuda
fi

# Cleanup package manager
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
