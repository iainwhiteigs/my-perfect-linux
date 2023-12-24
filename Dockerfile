# Use the latest version of Ubuntu Server as a base image
FROM ubuntu:latest AS setup

ARG USERNAME=whitenet
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo wget \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

FROM setup AS install

COPY .p10k.zsh /home/${USERNAME}/.p10k.zsh
COPY .aliases /home/${USERNAME}/.aliases

COPY setup.sh /tmp/setup.sh

RUN /tmp/setup.sh

ENTRYPOINT [ "/bin/zsh" ]

# Set tge defalt directory for the container
WORKDIR /home/${USERNAME}

CMD ["-l"]