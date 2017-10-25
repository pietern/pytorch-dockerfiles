#!/bin/bash

set -ex

APT_INSTALL_CMD="apt-get install -y --no-install-recommends"

source /etc/lsb-release

case "$BUILD" in
  linux-trusty)
    ;;
  linux-xenial)
    ;;
  *-cuda8-cudnn6)
    export CUDA_VERSION=8
    export CUDNN_VERSION=6
    ;;
  *-cuda9-cudnn7)
    export CUDA_VERSION=9
    export CUDNN_VERSION=7
    ;;
  *-mkl)
    export MKL=1
    ;;
  *-android)
    export ANDROID=1
    ;;
  *)
    echo "Unsupported BUILD: $BUILD"
    exit 1
    ;;
esac

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
    "cuda-driver-dev-${CUDA_PKG_VERSION}" \
    "cuda-nvrtc-dev-${CUDA_PKG_VERSION}"

  # Manually create CUDA symlink
  ln -sf "/usr/local/cuda-${CUDA_VERSION}" /usr/local/cuda

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

# Optionally install MKL
if [ -n "$MKL" ]; then
  key="https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB"
  curl "${key}" | apt-key add -
  echo 'deb http://apt.repos.intel.com/mkl all main' | \
    tee /etc/apt/sources.list.d/intel-mkl.list
  apt-get update
  $APT_INSTALL_CMD intel-mkl-64bit
fi

# Optionally install Android toolkit
if [ -n "$ANDROID" ]; then
  apt-get update
  $APT_INSTALL_CMD autotools-dev autoconf unzip
  pushd /tmp
  wget -q https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip
  popd
  _ndk_dir=/opt/ndk
  mkdir -p "$_ndk_dir"
  unzip -qo /tmp/android*.zip -d "$_ndk_dir"
  _versioned_dir=$(find "$_ndk_dir/" -mindepth 1 -maxdepth 1 -type d)
  mv "$_versioned_dir"/* "$_ndk_dir"/
  rmdir "$_versioned_dir"
fi

# Cleanup package manager
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
