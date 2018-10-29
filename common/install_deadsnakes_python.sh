#!/bin/bash

set -ex

if [ -n "$DEADSNAKES_PYTHON_VERSION" ]; then

  add-apt-repository ppa:deadsnakes/ppa
  apt-get update
  apt-get install -y python$DEADSNAKES_PYTHON_VERSION python$DEADSNAKES_PYTHON_VERSION-dev

  update-alternatives --install /usr/bin/python python /usr/bin/python"$DEADSNAKES_PYTHON_VERSION" 50

  # Bootstrap pip
  curl https://bootstrap.pypa.io/get-pip.py | python

  # Install basic dependencies
  pip install numpy pyyaml future hypothesis protobuf pytest pillow typing mkl mkl-devel
  if [[ "$DEADSNAKES_PYTHON_VERSION" != "3.7" ]]; then
    pip install scipy==1.1.0 scikit-image
  fi

  # Cleanup package manager
  apt-get autoclean && apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

fi
