node {
  checkout scm
  stash name: 'dockerfiles', includes: 'ci-ubuntu/'
}

def branches = [:]

def trusty_builds = [
  'linux-cuda8-cudnn5',
  'linux-cuda8-cudnn6',
]

def xenial_builds = [
  'linux-cuda8-cudnn5',
  'linux-cuda8-cudnn6',
  'linux-cuda9-cudnn7',
]

for (build in trusty_builds) {
  // Define in local scope; "build" will be reused across iterations
  def build_name = build
  branches["trusty-${build}"] = {
    node("docker") {
      deleteDir()
      unstash 'dockerfiles'
      dir("ci-ubuntu") {
        sh "docker build --build-arg BUILD=${build_name} -f Dockerfile.trusty ."
      }
    }
  }
}

for (build in xenial_builds) {
  // Define in local scope; "build" will be reused across iterations
  def build_name = build
  branches["xenial-${build}"] = {
    node("docker") {
      deleteDir()
      unstash 'dockerfiles'
      dir("ci-ubuntu") {
        sh "docker build --build-arg BUILD=${build_name} -f Dockerfile.xenial ."
      }
    }
  }
}

parallel branches
