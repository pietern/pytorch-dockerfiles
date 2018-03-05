#!/bin/bash

set -ex

if [ -n "$CLANG_VERSION" ]; then

  apt-get update
  apt-get install -y --no-install-recommends clang-"$CLANG_VERSION"

  # Cleanup package manager
  apt-get autoclean && apt-get clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

  # NB: Caffe2's version makes clang the default compiler.  We don't
  # apply this change (yet)

fi
