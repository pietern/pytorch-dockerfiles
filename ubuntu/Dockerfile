ARG UBUNTU_VERSION

FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND noninteractive

# Install common dependencies (so that this step can be cached separately)
ADD ./common/install_base.sh install_base.sh
RUN bash ./install_base.sh && rm install_base.sh

# Install user
ADD ./common/install_user.sh install_user.sh
RUN bash ./install_user.sh && rm install_user.sh

# Install conda
ARG ANACONDA_VERSION
ADD ./common/install_conda.sh install_conda.sh
RUN bash ./install_conda.sh && rm install_conda.sh

# Install clang
ARG CLANG_VERSION
ADD ./common/install_clang.sh install_clang.sh
RUN bash ./install_clang.sh && rm install_clang.sh

ARG TRAVIS_PYTHON_VERSION
ARG GCC_VERSION
ADD ./common/install_travis_python.sh install_travis_python.sh
RUN bash ./install_travis_python.sh && rm install_travis_python.sh

# Include BUILD_ENVIRONMENT environment variable in image
ARG BUILD_ENVIRONMENT
ENV BUILD_ENVIRONMENT ${BUILD_ENVIRONMENT}

CMD ["bash"]
