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

# Mirror jenkins user in container
echo "jenkins:x:1014:1014::/var/lib/jenkins:" >> /etc/passwd
echo "jenkins:x:1014:" >> /etc/group

# Create $HOME
mkdir -p /var/lib/jenkins
chown jenkins:jenkins /var/lib/jenkins
mkdir -p /var/lib/jenkins/.ccache
chown jenkins:jenkins /var/lib/jenkins/.ccache

# Allow writing to /usr/local (for make install)
chown jenkins:jenkins /usr/local

# Allow sudo
echo 'jenkins ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/jenkins
