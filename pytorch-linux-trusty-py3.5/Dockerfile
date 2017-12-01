ARG BUILD_ID
FROM ci.pytorch.org/pytorch/pytorch-linux-trusty:${BUILD_ID}

# Install Python stuff
ARG BUILD
ADD ./common/install_travis_python.sh install_travis_python.sh
RUN bash ./install_travis_python.sh && rm install_travis_python.sh

# Install user
ADD ./common/install_user.sh install_user.sh
RUN bash ./install_user.sh && rm install_user.sh

CMD ["bash"]
