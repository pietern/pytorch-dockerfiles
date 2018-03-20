#!/bin/bash

set -ex

# NB: It is critical that we only install this symlink when
# CUDA really is available, as PyTorch uses nvcc presence to detect
# where CUDA is installed

# TODO: use sccache instead
pushd /usr/local/bin
ln -sf "$(which ccache)" nvcc
popd
