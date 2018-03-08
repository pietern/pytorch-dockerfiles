# Docker images for Jenkins

This directory contains everything needed to build the Docker images
that are used in our Jenkins setup.  This is based off a similar
setup in https://github.com/caffe2/caffe2/tree/master/docker/jenkins

The Dockerfiles located in subdirectories are parameterized to
conditionally run build stages depending on build arguments passed to
`docker build`. This lets us use only a few Dockerfiles for many
images. The different configurations are identified by a freeform
string that we call a _build environment_. This string is persisted in
each image as the `BUILD_ENVIRONMENT` environment variable.

Valid build environments:

* linux-artful-cuda9-cudnn7
* linux-trusty-py2.7
* linux-trusty-py3.5
* linux-trusty-py3.6-gcc4.8
* linux-trusty-py3.6-gcc5.4
* linux-trusty-py3.6-gcc7.2
* linux-trusty-pynightly
* linux-xenial-cuda8-cudnn6-py2
* linux-xenial-cuda8-cudnn6-py3
* linux-xenial-cuda9-cudnn7-py2
* linux-xenial-cuda9-cudnn7-py3
* linux-xenial-py3-clang5-asan

See `build.sh` for a full list of terms that are extracted from the
build environment into parameters for the image build.

## Contents

* `build.sh` -- dispatch script to launch all builds
* `common` -- scripts used to execute individual Docker build stages
* `ubuntu-cuda` -- Dockerfile for Ubuntu image with CUDA support for nvidia-docker
