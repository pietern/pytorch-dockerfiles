#!/usr/bin/env groovy

node {
  checkout scm
  stash name: 'dockerfiles', includes: 'ci-ubuntu/'
}

def branches = [:]

def trusty_builds = [
  'linux-trusty',
  'linux-trusty-cuda8-cudnn6',
  'linux-trusty-mkl',
]

def xenial_builds = [
  'linux-xenial',
  'linux-xenial-cuda9-cudnn7',
  'linux-xenial-mkl',
]

for (build in trusty_builds) {
  // Define in local scope; "build" will be reused across iterations
  def build_name = build
  branches[build_name] = {
    node("docker") {
      deleteDir()
      unstash 'dockerfiles'
      dir("ci-ubuntu") {
        def image = docker.build(
          "ci.pytorch.org/caffe2/${build_name}:${env.BUILD_ID}",
          "--build-arg BUILD=${build_name} -f Dockerfile.trusty .",
        )

        image.push()
      }
    }
  }
}

for (build in xenial_builds) {
  // Define in local scope; "build" will be reused across iterations
  def build_name = build
  branches[build_name] = {
    node("docker") {
      deleteDir()
      unstash 'dockerfiles'
      dir("ci-ubuntu") {
        def image = docker.build(
          "ci.pytorch.org/caffe2/${build_name}:${env.BUILD_ID}",
          "--build-arg BUILD=${build_name} -f Dockerfile.xenial .",
        )

        image.push()
      }
    }
  }
}

parallel branches
