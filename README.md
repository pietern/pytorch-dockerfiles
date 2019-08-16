# Docker images for Jenkins

This directory contains everything needed to build the Docker images
that are used in our Jenkins setup.  This is based off a similar
setup in https://github.com/pytorch/pytorch/tree/master/docker/caffe2/jenkins
that will soon be deprecated and removed.

The Dockerfiles located in subdirectories are parameterized to
conditionally run build stages depending on build arguments passed to
`docker build`. This lets us use only a few Dockerfiles for many
images. The different configurations are identified by a freeform
string that we call a _build environment_. This string is persisted in
each image as the `BUILD_ENVIRONMENT` environment variable.

See `build.sh` for valid build environments (it's the giant switch).

## Contents

* `build.sh` -- dispatch script to launch all builds
* `common` -- scripts used to execute individual Docker build stages
* `ubuntu-cuda` -- Dockerfile for Ubuntu image with CUDA support for nvidia-docker
