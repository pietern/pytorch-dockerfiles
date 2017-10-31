#!/bin/bash

set -ex

if [[ "$BUILD" == *py2* ]]; then
  export CONDA_VERSION=2
fi

if [[ "$BUILD" == *py3* ]]; then
  export CONDA_VERSION=3
fi

# Optionally install conda
if [ -n "$CONDA_VERSION" ]; then
  BASE_URL="https://repo.continuum.io/miniconda"

  case "$CONDA_VERSION" in
    2)
      CONDA_FILE="Miniconda2-latest-Linux-x86_64.sh"
    ;;
    3)
      CONDA_FILE="Miniconda3-latest-Linux-x86_64.sh"
    ;;
    *)
      echo "Unsupported CONDA_VERSION: $CONDA_VERSION"
      exit 1
      ;;
  esac

  mkdir /opt/conda
  chown jenkins:jenkins /opt/conda

  pushd /tmp
  wget -q "${BASE_URL}/${CONDA_FILE}"
  chmod +x "${CONDA_FILE}"
  sudo -u jenkins ./"${CONDA_FILE}" -b -f -p "/opt/conda"
  popd
fi

# Cleanup package manager
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
