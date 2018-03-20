#!/bin/bash

set -ex

# Use AWS mirror if running in EC2
if [ -n "${EC2:-}" ]; then
  A="archive.ubuntu.com"
  B="us-east-1.ec2.archive.ubuntu.com"
  perl -pi -e "s/${A}/${B}/g" /etc/apt/sources.list
fi

# Install common dependencies
apt-get update
# TODO: Some of these may not be necessary
apt-get install -y --no-install-recommends \
  apt-transport-https \
  asciidoc \
  autoconf \
  automake \
  build-essential \
  ca-certificates \
  cmake \
  curl \
  docbook-xml \
  docbook-xsl \
  git \
  gfortran \
  libatlas-base-dev \
  libiomp-dev \
  libyaml-dev \
  libz-dev \
  python \
  python-dev \
  python-setuptools \
  python-wheel \
  software-properties-common \
  sudo \
  wget \
  valgrind \
  xsltproc

# TODO: THIS IS A HACK!!!
# distributed nccl(2) tests are a bit busted, see https://github.com/pytorch/pytorch/issues/5877
if dpkg -s libnccl-dev; then
  apt-get remove -y libnccl-dev libnccl2
fi

# Cleanup package manager
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
