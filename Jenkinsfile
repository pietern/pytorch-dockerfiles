node('docker') {
    checkout scm

    def trusty_builds = [
      'linux-cuda8-cudnn5',
      'linux-cuda8-cudnn6',
    ]

    def xenial_builds = [
      'linux-cuda8-cudnn5',
      'linux-cuda8-cudnn6',
      'linux-cuda9-cudnn7',
    ]

    dir('ci-ubuntu') {
        for (build in trusty_builds) {
          sh "docker build --build-arg BUILD=${build} -f Dockerfile.trusty ."
        }
        for (build in xenial_builds) {
          sh "docker build --build-arg BUILD=${build} -f Dockerfile.xenial ."
        }
    }
}
