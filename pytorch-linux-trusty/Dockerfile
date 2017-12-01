FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

# Install common dependencies (so that this step can be cached separately)
ADD ./common/install_base.sh install_base.sh
RUN bash ./install_base.sh && rm install_base.sh

CMD ["bash"]
