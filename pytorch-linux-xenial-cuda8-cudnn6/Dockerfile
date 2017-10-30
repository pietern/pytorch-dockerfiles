ARG BUILD_ID
FROM ci.pytorch.org/pytorch/pytorch-linux-xenial:${BUILD_ID}

# Install CUDA
ARG BUILD
ADD ./common/install_cuda.sh install_cuda.sh
RUN bash ./install_cuda.sh && rm install_cuda.sh

CMD ["bash"]
