ARG BUILD_ID
FROM ci.pytorch.org/pytorch/pytorch-linux-xenial-cuda8-cudnn6:${BUILD_ID}

# Install Conda
ARG BUILD
ADD ./common/install_conda.sh install_conda.sh
RUN bash ./install_conda.sh && rm install_conda.sh

CMD ["bash"]
