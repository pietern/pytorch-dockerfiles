#!/usr/bin/env groovy

node {
  checkout scm
  stash name: 'dockerfiles', includes: '**/*'
}

def build_name_to_job(build_name) {
  return {
    node("docker") {
      deleteDir()
      unstash 'dockerfiles'

      def image = docker.build(
        "ci.pytorch.org/caffe2/${build_name}:${env.BUILD_ID}",
        "--build-arg BUILD=${build_name} --build-arg BUILD_ID=${env.BUILD_ID} -f ./${build_name}/Dockerfile .",
      )

      image.push()
    }
  }
}

def base_images = [
  "linux-trusty",
  "linux-xenial",
]

// First build base images
parallel(base_images.collectEntries { ["Build image ${it}", build_name_to_job(it)]})

def derived_images = [
  "linux-trusty-cuda8-cudnn6",
  "linux-trusty-mkl",
  "linux-xenial-cuda9-cudnn7",
  "linux-xenial-mkl",
]

// Then build derived images
parallel(derived_images.collectEntries { ["Build image ${it}", build_name_to_job(it)]})
