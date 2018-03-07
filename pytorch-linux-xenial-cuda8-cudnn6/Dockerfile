ARG BUILD_ID
FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

ENV DEBIAN_FRONTEND noninteractive

# Install common dependencies (so that this step can be cached separately)
ADD ./common/install_base.sh install_base.sh
RUN bash ./install_base.sh && rm install_base.sh

# Install Python stuff
ADD ./common/install_python.sh install_python.sh
RUN bash ./install_python.sh && rm install_python.sh

# Install user
ADD ./common/install_user.sh install_user.sh
RUN bash ./install_user.sh && rm install_user.sh

CMD ["bash"]
