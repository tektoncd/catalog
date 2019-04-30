FROM docker.io/centos:7 as base
RUN \
  yum -y install epel-release && \
  # Install buildah dependencies.
  yum -y install \
    make \
    golang \
    bats \
    btrfs-progs-devel \
    device-mapper-devel \
    glib2-devel \
    gpgme-devel \
    libassuan-devel \
    libseccomp-devel \
    ostree-devel \
    git \
    bzip2

FROM base as runc
ARG RUNC_REVISION="master"
RUN yum -y install runc
RUN mkdir ~/runc && \
  cd ~/runc && \
  export GOPATH=`pwd` && \
  git clone https://github.com/opencontainers/runc ./src/github.com/opencontainers/runc && \
  cd $GOPATH/src/github.com/opencontainers/runc && \
  git checkout "${RUNC_REVISION}" && \
  git log -1 --oneline > /.version.runc && \
  make runc && \
  mv runc /usr/bin/runc

FROM base as buildah
ARG BUILDAH_REVISION="master"
RUN yum -y install \
    go-md2man \
    runc \
    skopeo-containers
RUN mkdir ~/buildah && \
  cd ~/buildah && \
  export GOPATH=`pwd` && \
  cd $GOPATH/ && \
  git clone https://github.com/containers/buildah ./src/github.com/containers/buildah && \
  cd $GOPATH/src/github.com/containers/buildah && \
  git checkout "${BUILDAH_REVISION}" && \
  make && \
  make install

FROM docker.io/centos:7
RUN yum -y install libarchive ostree lzo libseccomp libedit gpgme && \
  yum update -y && \
  yum clean all && \
  rm -rf \
    /var/cache/yum \
    /usr/share/doc \
    /usr/share/man \
    /usr/share/info \
    /usr/share/locale \
    /var/log/*
COPY --from=runc /usr/bin/runc /usr/bin/runc
COPY --from=runc /.version.runc /.version.runc
COPY --from=buildah /usr/local/bin/buildah /usr/bin/buildah
COPY --from=buildah /etc/containers /etc/containers
ENV BUILDAH_ISOLATION chroot
ENV STORAGE_DRIVER vfs
ENTRYPOINT ["buildah"]
