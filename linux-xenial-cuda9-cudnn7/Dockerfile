ARG BUILD_ID
FROM ci.pytorch.org/caffe2/linux-xenial:${BUILD_ID}

# Install build specific dependencies
ARG BUILD
ADD ./common/install_build.sh install_build.sh
RUN bash ./install_build.sh && rm install_build.sh

CMD ["bash"]
