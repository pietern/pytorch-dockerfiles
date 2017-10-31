#!/bin/bash

set -ex

APT_INSTALL_CMD="apt-get install -y --no-install-recommends"

source /etc/lsb-release

if [[ "$BUILD" == *cuda8-cudnn6* ]]; then
  export CUDA_VERSION=8
  export CUDNN_VERSION=6
fi

if [[ "$BUILD" == *cuda9-cudnn7* ]]; then
  export CUDA_VERSION=9
  export CUDNN_VERSION=7
fi

# Optionally install CUDA
if [ -n "$CUDA_VERSION" ]; then
  CUDA_BASE_URL="https://developer.download.nvidia.com/compute/cuda/repos"
  ML_BASE_URL="https://developer.download.nvidia.com/compute/machine-learning/repos"

  case "$DISTRIB_RELEASE" in
    14.04)
      CUDA_REPO_PATH="ubuntu1404"
      ML_REPO_PKG="nvidia-machine-learning-repo-${CUDA_REPO_PATH}_4.0-2_amd64.deb"
      case "$CUDA_VERSION" in
        8)
          CUDA_REPO_PKG="cuda-repo-${CUDA_REPO_PATH}_8.0.61-1_amd64.deb"
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
      ML_REPO_PKG="nvidia-machine-learning-repo-${CUDA_REPO_PATH}_1.0.0-1_amd64.deb"
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
    "cuda-cusparse-dev-${CUDA_PKG_VERSION}" \
    "cuda-driver-dev-${CUDA_PKG_VERSION}" \
    "cuda-nvrtc-dev-${CUDA_PKG_VERSION}"

  # Manually create CUDA symlink
  ln -sf "/usr/local/cuda-${CUDA_VERSION}" /usr/local/cuda

  # Install ccache wrapper for nvcc
  # Must happen after installing CUDA itself because it looks
  # like installing CUDA nukes existing nvcc symlinks.
  pushd /usr/local/bin
  ln -sf "$(which ccache)" nvcc
  popd

  # Install cuDNN
  pushd /tmp
  wget "${ML_BASE_URL}/${CUDA_REPO_PATH}/x86_64/${ML_REPO_PKG}"
  dpkg -i "$ML_REPO_PKG"
  rm -f "$ML_REPO_PKG"
  popd

  case "$CUDNN_VERSION" in
    5)
      CUDNN_PKG_VERSION="5.1.10-1+cuda8.0"
    ;;
    6)
      CUDNN_PKG_VERSION="6.0.21-1+cuda8.0"
    ;;
    7)
      CUDNN_PKG_VERSION="7.0.3.11-1+cuda${CUDA_VERSION}"
    ;;
    *)
      echo "Unsupported CUDNN_VERSION: $CUDNN_VERSION"
      exit 1
      ;;
  esac

  apt-get update
  $APT_INSTALL_CMD \
    "libcudnn${CUDNN_VERSION}=${CUDNN_PKG_VERSION}" \
    "libcudnn${CUDNN_VERSION}-dev=${CUDNN_PKG_VERSION}"
fi


# Cleanup package manager
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
