#!/bin/bash

set -ex

# Install ccache wrapper for nvcc
# Tired: Must happen after installing CUDA itself because it looks
# like installing CUDA nukes existing nvcc symlinks.
# Wired: We're using the NVIDIA image, so of course this is true
pushd /usr/local/bin
ln -sf "$(which ccache)" nvcc
popd
