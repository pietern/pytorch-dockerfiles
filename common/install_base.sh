#!/bin/bash

set -ex

# Use AWS mirror if running in EC2
if [ -n "${EC2:-}" ]; then
  A="archive.ubuntu.com"
  B="us-east-1.ec2.archive.ubuntu.com"
  perl -pi -e "s/${A}/${B}/g" /etc/apt/sources.list
fi

if [[ "$UBUNTU_VERSION" == "14.04" ]]; then
  # cmake 2 is too old
  cmake3=cmake3
else
  cmake3=cmake
fi

# Install common dependencies
apt-get update
# TODO: Some of these may not be necessary
# TODO: libiomp also gets installed by conda, aka there's a conflict
ccache_deps="asciidoc docbook-xml docbook-xsl xsltproc"
numpy_deps="gfortran"
apt-get install -y --no-install-recommends \
  $ccache_deps \
  $numpy_deps \
  ${cmake3}=3.5\* \
  apt-transport-https \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  curl \
  git \
  libatlas-base-dev \
  libiomp-dev \
  libyaml-dev \
  libz-dev \
  libjpeg-dev \
  python \
  python-dev \
  python-setuptools \
  python-wheel \
  software-properties-common \
  sudo \
  wget \
  valgrind \
  vim

# TODO: THIS IS A HACK!!!
# distributed nccl(2) tests are a bit busted, see https://github.com/pytorch/pytorch/issues/5877
if dpkg -s libnccl-dev; then
  apt-get remove -y libnccl-dev libnccl2
fi

# Cleanup package manager
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
