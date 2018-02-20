ARG BUILD_ID
FROM registry.pytorch.org/pytorch/pytorch-linux-xenial:${BUILD_ID}

# Install Conda
ARG BUILD
ADD ./common/install_conda.sh install_conda.sh
RUN bash ./install_conda.sh && rm install_conda.sh

# Install Clang
ADD ./common/install_clang.sh install_clang.sh
RUN bash ./install_clang.sh && rm install_clang.sh

CMD ["bash"]
