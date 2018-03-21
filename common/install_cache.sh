#!/bin/bash

set -ex

mkdir -p /opt/cache/bin
mkdir -p /opt/cache/lib
sed -e 's|PATH="\(.*\)"|PATH="/opt/cache/bin:\1"|g' -i /etc/environment
export PATH="/opt/cache/bin:$PATH"

# Setup compiler cache
if [ -n "$CUDA_VERSION" ]; then
  # If CUDA is installed, we must use ccache, as sccache doesn't support
  # caching nvcc yet

  # Install ccache from source.
  # Needs 3.4 or later for ccbin support
  pushd /tmp
  git clone https://github.com/ccache/ccache -b v3.4.1
  pushd ccache
  # Disable developer mode, so we squelch -Werror
  ./autogen.sh
  ./configure --prefix=/opt/cache
  make "-j$(nproc)" install
  popd
  popd

  # Install ccache symlink wrappers
  pushd /opt/cache/bin
  ln -sf "$(which ccache)" cc
  ln -sf "$(which ccache)" c++
  ln -sf "$(which ccache)" gcc
  ln -sf "$(which ccache)" g++
  ln -sf "$(which ccache)" clang
  ln -sf "$(which ccache)" clang++
  popd

  pushd /opt/cache/lib
  # TODO: This is a workaround for the fact that PyTorch's FindCUDA
  # implementation cannot find nvcc if it is setup this way, because it
  # appears to search for the nvcc in PATH, and use its path to infer
  # where CUDA is installed.  Instead, we install an nvcc symlink outside
  # of the PATH, and set CUDA_NVCC_EXECUTABLE so that we make use of it.
  ln -sf "$(which ccache)" nvcc
  popd

else
  # We prefer sccache because we don't have to have a warm local ccache
  # to use it

  pushd /tmp
  SCCACHE_BASE_URL="https://github.com/mozilla/sccache/releases/download/"
  SCCACHE_VERSION="0.2.5"
  SCCACHE_BASE="sccache-${SCCACHE_VERSION}-x86_64-unknown-linux-musl"
  SCCACHE_FILE="$SCCACHE_BASE.tar.gz"
  wget -q "$SCCACHE_BASE_URL/$SCCACHE_VERSION/$SCCACHE_FILE"
  tar xzf $SCCACHE_FILE
  mv "$SCCACHE_BASE/sccache" /opt/cache/bin
  popd

  function write_sccache_stub() {
    printf "#!/bin/sh\nexec sccache $(which $1) \$*" > "/opt/cache/bin/$1"
    chmod a+x "/opt/cache/bin/$1"
  }

  write_sccache_stub cc
  write_sccache_stub c++
  write_sccache_stub gcc
  write_sccache_stub g++
  write_sccache_stub clang
  write_sccache_stub clang++

  # NB: When you add nvcc support, please see the notes in ccache about
  # what you have to be careful about.

fi
