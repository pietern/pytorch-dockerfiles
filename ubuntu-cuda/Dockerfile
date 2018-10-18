ARG UBUNTU_VERSION
ARG CUDA_VERSION
ARG CUDNN_VERSION

FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-ubuntu${UBUNTU_VERSION}

ARG UBUNTU_VERSION
ARG CUDA_VERSION
ARG CUDNN_VERSION

ENV DEBIAN_FRONTEND noninteractive

# Install common dependencies (so that this step can be cached separately)
ARG EC2
ADD ./common/install_base.sh install_base.sh
RUN bash ./install_base.sh && rm install_base.sh

# Install user
ADD ./common/install_user.sh install_user.sh
RUN bash ./install_user.sh && rm install_user.sh

# Install conda
ENV PATH /opt/conda/bin:$PATH
ARG ANACONDA_PYTHON_VERSION
ADD ./common/install_conda.sh install_conda.sh
RUN bash ./install_conda.sh && rm install_conda.sh

# Install gcc
ARG GCC_VERSION
ADD ./common/install_gcc.sh install_gcc.sh
RUN bash ./install_gcc.sh && rm install_gcc.sh

# Install non-standard Python versions (via Travis binaries)
ARG TRAVIS_PYTHON_VERSION
ENV PATH /opt/python/$TRAVIS_PYTHON_VERSION/bin:$PATH
ADD ./common/install_travis_python.sh install_travis_python.sh
RUN bash ./install_travis_python.sh && rm install_travis_python.sh

# Install ccache/sccache (do this last, so we get priority in PATH)
ADD ./common/install_cache.sh install_cache.sh
ENV PATH /opt/cache/bin:$PATH
RUN bash ./install_cache.sh && rm install_cache.sh
ENV CUDA_NVCC_EXECUTABLE=/opt/cache/lib/nvcc

# Include BUILD_ENVIRONMENT environment variable in image
ARG BUILD_ENVIRONMENT
ENV BUILD_ENVIRONMENT ${BUILD_ENVIRONMENT}

# AWS specific CUDA build guidance
ENV TORCH_CUDA_ARCH_LIST Maxwell
ENV TORCH_NVCC_FLAGS "-Xfatbin -compress-all"

USER jenkins
CMD ["bash"]
