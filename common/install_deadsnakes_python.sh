#!/bin/bash

set -ex

if [ -n "$DEADSNAKES_PYTHON_VERSION" ]; then

  add-apt-repository ppa:deadsnakes/ppa
  apt-get update
  apt-get install -y python$DEADSNAKES_PYTHON_VERSION

  update-alternatives --install /usr/bin/python python /usr/bin/python"$DEADSNAKES_PYTHON_VERSION" 50

  # Cleanup package manager
  apt-get autoclean && apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

fi
