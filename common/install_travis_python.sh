#!/bin/bash

set -ex

as_jenkins() {
  sudo -H -u jenkins $*
}

if [ -n "$TRAVIS_PYTHON_VERSION" ]; then

  mkdir /opt/python
  chown jenkins:jenkins /opt/python

  # Download Python binary from Travis
  pushd tmp
  as_jenkins wget https://s3.amazonaws.com/travis-python-archives/binaries/ubuntu/14.04/x86_64/python-$TRAVIS_PYTHON_VERSION.tar.bz2
  as_jenkins tar xjf python-$TRAVIS_PYTHON_VERSION.tar.bz2 --directory /
  popd
  export PATH=/opt/python/$TRAVIS_PYTHON_VERSION/bin:$PATH
  export LD_LIBRARY_PATH=/opt/python/$TRAVIS_PYTHON_VERSION/lib:$LD_LIBRARY_PATH

  apt-get update
  apt-get install -y gfortran

  # Install pip packages
  as_jenkins pip install --upgrade pip

  if [[ "$TRAVIS_PYTHON_VERSION" == nightly ]]; then
      # These two packages have broken Cythonizations uploaded
      # to PyPi, see:
      #
      #  - https://github.com/numpy/numpy/issues/10500
      #  - https://github.com/yaml/pyyaml/issues/117
      #
      # Furthermore, the released version of Cython does not
      # have these issues fixed.
      #
      # While we are waiting on fixes for these, we build
      # from Git for now.  Feel free to delete this conditional
      # branch if things start working again (you may need
      # to do this if these packages regress on Git HEAD.)
      as_jenkins pip install git+https://github.com/cython/cython.git
      as_jenkins pip install git+https://github.com/numpy/numpy.git
      as_jenkins pip install git+https://github.com/yaml/pyyaml.git
  else
      as_jenkins pip install numpy pyyaml
  fi

  as_jenkins pip install \
      future \
      hypothesis \
      protobuf \
      pytest \
      typing

  # MKL library from pip does not support Python 2.7.9
  if [[ "$TRAVIS_PYTHON_VERSION" != 2.7.9 ]]; then
      as_jenkins pip install mkl
  fi

  # SciPy does not support Python 3.7
  if [[ "$TRAVIS_PYTHON_VERSION" != nightly ]]; then
      as_jenkins pip install scipy==0.19.1 scikit-image
  fi

  # Install additional dependencies for CPU tests
  add-apt-repository -y ppa:george-edison55/cmake-3.x
  apt-add-repository -y ppa:ubuntu-toolchain-r/test
  apt-get update

  apt-get install -y cmake g++-$GCC_VERSION valgrind

  # Cleanup package manager
  apt-get autoclean && apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
fi
