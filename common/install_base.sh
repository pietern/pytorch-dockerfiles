#!/bin/bash

set -ex

# Install common dependencies
apt-get update
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
  gperf \
  libatlas-base-dev \
  libgoogle-glog-dev \
  libiomp-dev \
  libleveldb-dev \
  liblmdb-dev \
  libopencv-dev \
  libprotobuf-dev \
  libpthread-stubs0-dev \
  libsnappy-dev \
  libyaml-dev \
  protobuf-compiler \
  python \
  python-dev \
  python-setuptools \
  python-wheel \
  software-properties-common \
  sudo \
  wget \
  xsltproc

# Install ccache from source.
# Needs specific branch to work with nvcc (ccache/ccache#145)
pushd /tmp
git clone https://github.com/colesbury/ccache -b ccbin
pushd ccache
./autogen.sh
./configure --prefix=/usr/local
make "-j$(nproc)" install
popd
popd

# Install ccache symlink wrappers
pushd /usr/local/bin
ln -sf "$(which ccache)" cc
ln -sf "$(which ccache)" c++
ln -sf "$(which ccache)" gcc
ln -sf "$(which ccache)" g++
popd

# Install sccache binaries
pushd /tmp
SCCACHE_BASE_URL="https://github.com/mozilla/sccache/releases/download/"
SCCACHE_VERSION="0.2.5"
SCCACHE_BASE="sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl"
SCCACHE_FILE="$SCCACHE_BASE.tar.gz"
wget -q "$SCCACHE_BASE_URL/$SCCACHE_VERSION/$SCCACHE_FILE"
tar xzf $SCCACHE_FILE
mv "$SCCACHE_BASE/sccache" /usr/local/bin
popd

# Cleanup package manager
apt-get autoclean && apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
