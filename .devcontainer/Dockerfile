FROM fedora:40

ARG USERNAME=avojak
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install system tools
RUN dnf install -y git wget xz

# Install base development libraries
RUN dnf install -y \
        gtk4-devel \
        libvala-devel \
        libadwaita-devel \
        libgee-devel \
        libsoup3-devel \
        meson \
        ninja-build \
        vala

# Install vala-language-server from source due to runtime error
RUN dnf install -y json-glib-devel && \
    wget https://github.com/vala-lang/vala-language-server/releases/download/0.48.7/vala-language-server-0.48.7.tar.xz && \
    tar -xf vala-language-server-0.48.7.tar.xz && \
    pushd vala-language-server-0.48.7 && \
    meson -Dprefix=/usr build && \
    ninja -C build && \
    ninja -C build install && \
    popd && \
    rm -rf vala-language-server-0.48.7.tar.xz vala-language-server-0.48.7

#
# Install project dependencies
#

RUN dnf install -y \
    libsecret-devel \
    rest-devel

# Setup non-root user
RUN groupadd -g $USER_GID $USERNAME && \
    useradd -u $USER_UID -g $USER_GID -m $USERNAME

ENTRYPOINT [ "/bin/bash" ]