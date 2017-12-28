#!/bin/bash

set -ex

if [[ "$BUILD" == *py2.7* ]]; then
  export PYTHON_VERSION=2.7
fi

if [[ "$BUILD" == *py2.7.9* ]]; then
  export PYTHON_VERSION=2.7.9
fi

if [[ "$BUILD" == *py3.5* ]]; then
  export PYTHON_VERSION=3.5
fi

if [[ "$BUILD" == *py3.6* ]]; then
  export PYTHON_VERSION=3.6
fi

if [[ "$BUILD" == *pynightly* ]]; then
  export PYTHON_VERSION=nightly
fi

export GCC_VERSION=5

if [[ "$BUILD" == *gcc4.8* ]]; then
  export GCC_VERSION=4.8
fi

if [[ "$BUILD" == *gcc7.2* ]]; then
  export GCC_VERSION=7
fi

# Download Python binary from Travis
wget https://s3.amazonaws.com/travis-python-archives/binaries/ubuntu/14.04/x86_64/python-$PYTHON_VERSION.tar.bz2
tar xjf python-$PYTHON_VERSION.tar.bz2 --directory /
export PATH=/opt/python/$PYTHON_VERSION/bin:$PATH
export LD_LIBRARY_PATH=/opt/python/$PYTHON_VERSION/lib:$LD_LIBRARY_PATH

apt-get update
apt-get install -y gfortran

# Install pip packages
pip install --upgrade pip

pip install \
    numpy \
    future \
    hypothesis \
    protobuf \
    pytest \
    pyyaml

# MKL library from pip does not support Python 2.7.9
if [[ "$BUILD" != *py2.7.9* ]]; then
    pip install mkl
fi

# SciPy does not support Python 3.7
if [[ "$BUILD" != *pynightly* ]]; then
    pip install scipy==0.19.1 scikit-image
fi

# Install additional dependencies for CPU tests
add-apt-repository -y ppa:george-edison55/cmake-3.x
apt-add-repository -y ppa:ubuntu-toolchain-r/test
apt-get update
apt-get install -y cmake g++-$GCC_VERSION valgrind
