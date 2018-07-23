#!/bin/bash

set -ex

# Optionally install conda
if [ -n "$ANACONDA_VERSION" ]; then
  BASE_URL="https://repo.continuum.io/miniconda"

  case "$ANACONDA_VERSION" in
    2)
      CONDA_FILE="Miniconda2-latest-Linux-x86_64.sh"
    ;;
    3)
      CONDA_FILE="Miniconda3-latest-Linux-x86_64.sh"
    ;;
    *)
      echo "Unsupported ANACONDA_VERSION: $ANACONDA_VERSION"
      exit 1
      ;;
  esac

  mkdir /opt/conda
  chown jenkins:jenkins /opt/conda

  as_jenkins() {
    # NB: unsetting the environment variables works around a conda bug
    # https://github.com/conda/conda/issues/6576
    # NB: Pass on PATH and LD_LIBRARY_PATH to sudo invocation
    sudo -H -u jenkins env -u SUDO_UID -u SUDO_GID -u SUDO_COMMAND -u SUDO_USER env "PATH=$PATH" "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" $*
  }

  pushd /tmp
  wget -q "${BASE_URL}/${CONDA_FILE}"
  chmod +x "${CONDA_FILE}"
  as_jenkins ./"${CONDA_FILE}" -b -f -p "/opt/conda"
  popd

  # NB: Don't do this, rely on the rpath to get it right
  #echo "/opt/conda/lib" > /etc/ld.so.conf.d/conda-python.conf
  #ldconfig
  sed -e 's|PATH="\(.*\)"|PATH="/opt/conda/bin:\1"|g' -i /etc/environment
  export PATH="/opt/conda/bin:$PATH"

  # Track latest conda update
  as_jenkins conda update -n base conda

  # Install PyTorch conda deps, as per https://github.com/pytorch/pytorch README
  # DO NOT install cmake here as it would install a version newer than 3.5, but
  # we want to pin to version 3.5.
  as_jenkins conda install -q -y numpy pyyaml mkl mkl-include setuptools cffi typing
  if [[ "$CUDA_VERSION" == 8.0* ]]; then
    as_jenkins conda install -q -y magma-cuda80 -c soumith
  elif [[ "$CUDA_VERSION" == 9.0* ]]; then
    as_jenkins conda install -q -y magma-cuda90 -c soumith
  fi

  # TODO: This isn't working atm
  as_jenkins conda install -q -y nnpack -c killeent

  # Install some other packages
  # TODO: Why is scipy pinned
  as_jenkins pip install -q pytest scipy==1.1.0 scikit-image librosa
fi
