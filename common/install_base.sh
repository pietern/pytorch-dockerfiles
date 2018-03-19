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

# Experiment to see if libnccl is to blame for our troubles
if dpkg -s libnccl-dev; then
  apt-get remove -y libnccl-dev libnccl2
fi

# Install ccache from source.
# Needs 3.4 or later for ccbin support
pushd /tmp
git clone https://github.com/ccache/ccache -b v3.4.1
pushd ccache
# Disable developer mode, so we squelch -Werror
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
